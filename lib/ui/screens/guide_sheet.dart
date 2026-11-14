import '../../core/platform.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../cards.dart';
import '../item_actions.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../theme.dart';
import '../widgets.dart';

/// Loads one channel's programmes (past ones too when the channel has replay).
class _GuideLoader {
  static Future<List<Programme>> load(AppState state, ItemView ch) async {
    final src = state.activeSource ?? (await state.repo.source(ch.sourceId));
    if (src == null) return const [];
    final back = Duration(days: ch.archiveDays.clamp(0, 7), hours: 2);
    return state.catalog.channelGuide(src, ch, back: back, ahead: const Duration(hours: 36));
  }
}

/// True when [pr] has ended and the provider can replay it.
bool canReplay(AppState state, ItemView ch, Programme pr, DateTime now) {
  final src = state.activeSource;
  if (src == null || !pr.stop.isBefore(now)) return false;
  if (now.difference(pr.start).inDays >= ch.archiveDays) return false;
  return state.catalog.catchupUrl(src, ch, pr) != null;
}

/// The programme list of one channel. Live programme plays live, past
/// programmes with replay play the recording.
class ChannelGuideList extends StatelessWidget {
  const ChannelGuideList({
    super.key,
    required this.channel,
    required this.programmes,
    this.channels,
    this.onBeforePlay,
    this.controller,
    this.skipLive = false,
  });
  final ItemView channel;
  final List<Programme> programmes;
  final List<ItemView>? channels;
  final VoidCallback? onBeforePlay;
  final ScrollController? controller;

  /// Leave out the live programme (shown separately above the list).
  final bool skipLive;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final state = AppScope.read(context);
    final now = DateTime.now();
    final list = skipLive ? programmes.where((pr) => !pr.isLiveAt(now)).toList() : programmes;
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.zero,
      itemCount: list.length,
      itemExtent: 52,
      itemBuilder: (_, i) {
        final pr = list[i];
        final live = pr.isLiveAt(now);
        final past = pr.stop.isBefore(now);
        final replay = canReplay(state, channel, pr, now);
        return Pressable(
          radius: 8,
          tooltip: replay ? 'Watch replay' : (live ? 'Watch live' : null),
          onTap: live
              ? () {
                  onBeforePlay?.call();
                  openPlayer(context, PlayRequest.live(channel, channels: channels));
                }
              : replay
                  ? () {
                      onBeforePlay?.call();
                      openPlayer(context, PlayRequest.catchup(channel, pr));
                    }
                  : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border, width: 0.5))),
            child: Row(children: [
              SizedBox(
                width: 46,
                child: Text(fmtTime(pr.start),
                    style: TextStyle(
                        fontSize: 12.5,
                        color: past ? p.ink3 : p.ink2,
                        fontFeatures: const [FontFeature.tabularFigures()])),
              ),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pr.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: live ? FontWeight.w600 : FontWeight.w500,
                          color: past && !replay ? p.ink3 : p.ink)),
                  if (pr.start.day != now.day || pr.start.difference(now).inHours.abs() > 20)
                    Text(_day(pr.start, now), style: TextStyle(fontSize: 11, color: p.ink3)),
                ]),
              ),
              if (live) const LiveBadge(),
              if (replay) Icon(LucideIcons.history, size: 16, color: p.ink2),
            ]),
          ),
        );
      },
    );
  }

  static String _day(DateTime t, DateTime now) {
    final d = DateTime(t.year, t.month, t.day).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (d == 0) return 'Today';
    if (d == -1) return 'Yesterday';
    if (d == 1) return 'Tomorrow';
    return '${two(t.day)}/${two(t.month)}';
  }
}

/// Right-hand panel on Live TV: the selected channel, what's on now and its guide.
class ChannelPanel extends StatefulWidget {
  const ChannelPanel({super.key, required this.channel, this.channels, this.onBeforePlay});
  final ItemView channel;
  final List<ItemView>? channels;

  /// Called before playback starts (the dialog version closes itself).
  final VoidCallback? onBeforePlay;
  @override
  State<ChannelPanel> createState() => _ChannelPanelState();
}

class _ChannelPanelState extends State<ChannelPanel> {
  late final AppState state = AppScope.read(context);
  List<Programme>? progs;
  final scroll = ScrollController();
  Timer? _tick;
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(ChannelPanel old) {
    super.didUpdateWidget(old);
    if (old.channel.key != widget.channel.key) _load();
  }

  @override
  void dispose() {
    _tick?.cancel();
    scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final gen = ++_gen;
    setState(() => progs = null);
    final list = await _GuideLoader.load(state, widget.channel);
    if (!mounted || gen != _gen) return;
    setState(() => progs = list);
    // Start the list just before now.
    final now = DateTime.now();
    final idx = list.where((pr) => !pr.isLiveAt(now)).toList().indexWhere((pr) => pr.stop.isAfter(now));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients && idx > 2) {
        scroll.jumpTo(((idx - 2) * 52.0).clamp(0, scroll.position.maxScrollExtent));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final ch = widget.channel;
    final now = DateTime.now();
    final list = progs;
    final live = list?.where((pr) => pr.isLiveAt(now)).firstOrNull;
    final next = list?.where((pr) => pr.start.isAfter(now)).firstOrNull;
    return Container(
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 10, 0),
          child: Row(children: [
            ChannelLogo(ch.icon, width: 64, height: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ch.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.2)),
                if (ch.archiveDays > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('Replay ${ch.archiveDays} ${ch.archiveDays == 1 ? 'day' : 'days'}',
                        style: TextStyle(fontSize: 12, color: p.ink2)),
                  ),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Expanded(
              child: PrimaryButton(
                label: 'Watch live',
                icon: LucideIcons.play,
                height: 36,
                onPressed: () {
                  widget.onBeforePlay?.call();
                  openPlayer(context, PlayRequest.live(ch, channels: widget.channels));
                },
              ),
            ),
            const SizedBox(width: 8),
            RoundIconButton(LucideIcons.heart,
                size: 36,
                filled: ch.isFavorite,
                color: ch.isFavorite ? p.live : null,
                tooltip: ch.isFavorite ? 'Remove from favourites' : 'Add to favourites',
                onTap: () => state.repo.toggleFavorite(ch.sourceId, ch.type, ch.id)),
            const SizedBox(width: 6),
            Builder(
              builder: (c) => RoundIconButton(LucideIcons.ellipsis, size: 36, tooltip: 'More', onTap: () {
                final box = c.findRenderObject() as RenderBox;
                showItemMenu(context, ch, box.localToGlobal(box.size.bottomLeft(Offset.zero)));
              }),
            ),
          ]),
        ),
        if (list == null)
          const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
        else if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
            child: Text('No TV guide for this channel. Check the TV guide settings of the playlist.',
                style: TextStyle(color: p.ink2, fontSize: 12.5, height: 1.4)),
          )
        else ...[
          if (live != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const LiveBadge(),
                  const SizedBox(width: 8),
                  Text('${fmtTime(live.start)}–${fmtTime(live.stop)}', style: TextStyle(fontSize: 12, color: p.ink2)),
                  const Spacer(),
                  Text('${live.stop.difference(now).inMinutes} min left', style: TextStyle(fontSize: 12, color: p.ink3)),
                ]),
                const SizedBox(height: 6),
                Text(live.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.25)),
                if (live.description != null && live.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(live.description!.trim(),
                      maxLines: 4, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: p.ink2, height: 1.4)),
                ],
                const SizedBox(height: 10),
                ThinBar(live.progressAt(now), height: 4),
                if (next != null) ...[
                  const SizedBox(height: 10),
                  Text('Next  ${fmtTime(next.start)}  ${next.title}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: p.ink2)),
                ],
              ]),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            child: Text('Channel guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink3)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ChannelGuideList(
                  channel: ch,
                  programmes: list,
                  channels: widget.channels,
                  controller: scroll,
                  skipLive: live != null,
                  onBeforePlay: widget.onBeforePlay),
            ),
          ),
        ],
        if (list == null || list.isEmpty) const Spacer(),
      ]),
    );
  }
}

/// The same guide as a dialog (from menus and search results).
class GuideSheet extends StatefulWidget {
  const GuideSheet({super.key, required this.channel});
  final ItemView channel;
  @override
  State<GuideSheet> createState() => _GuideSheetState();
}

class _GuideSheetState extends State<GuideSheet> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: context.dialogW(460),
        height: (MediaQuery.sizeOf(context).height - 80).clamp(0.0, 640.0),
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: LiveItemPanel(channel: widget.channel, onBeforePlay: () => Navigator.pop(context)),
          ),
          Positioned(
            right: 10,
            top: 10,
            child: IconBtn(LucideIcons.x, tooltip: 'Close', onTap: () => Navigator.pop(context)),
          ),
        ]),
      ),
    );
  }
}

/// [ChannelPanel] that follows ♥ changes of its channel.
class LiveItemPanel extends StatelessWidget {
  const LiveItemPanel({super.key, required this.channel, this.channels, this.onBeforePlay});
  final ItemView channel;
  final List<ItemView>? channels;
  final VoidCallback? onBeforePlay;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: state.revision,
      builder: (context, _, _) => FutureBuilder<ItemView?>(
        future: state.repo.item(channel.sourceId, channel.type, channel.id),
        initialData: channel,
        builder: (context, snap) =>
            ChannelPanel(channel: snap.data ?? channel, channels: channels, onBeforePlay: onBeforePlay),
      ),
    );
  }
}
