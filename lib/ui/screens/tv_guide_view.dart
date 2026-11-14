import '../../core/platform.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../cards.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../theme.dart';
import '../widgets.dart';
import 'guide_sheet.dart';

/// TV guide grid inside Live TV: channels down the side, time across the top.
/// Uses the same filters as the channel list (category, ♥, replay, language, search).
class TvGuideView extends StatefulWidget {
  const TvGuideView({super.key, required this.query});
  final BrowseQuery query;
  @override
  State<TvGuideView> createState() => _TvGuideViewState();
}

class _TvGuideViewState extends State<TvGuideView> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    labelW = context.compact ? 112.0 : 210.0;
  }

  static const ppm = 4.0; // pixels per minute
  double labelW = 210.0;
  static const rowH = 56.0;
  static const _maxChannels = 400;

  /// Channels checked for guide data before the list is cut to [_maxChannels].
  static const _scanChannels = 4000;

  /// A guide id shared by more channels than this is treated as a placeholder.
  static const _maxSharedGuide = 25;

  late final AppState state = AppScope.read(context);
  final hctl = ScrollController();
  late DateTime from;
  late DateTime to;
  List<ItemView> channels = [];
  Map<String, List<Programme>> progs = {};
  bool loading = true;
  bool onlyWithGuide = true;
  int withoutGuide = 0;
  (ItemView, Programme)? picked;
  Timer? _tick;
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    from = DateTime(now.year, now.month, now.day, now.hour).subtract(const Duration(hours: 3));
    to = from.add(const Duration(hours: 30));
    _tick = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
    state.revision.addListener(_load);
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void didUpdateWidget(TvGuideView old) {
    super.didUpdateWidget(old);
    final a = old.query, b = widget.query;
    if (a.sourceId != b.sourceId ||
        a.categoryId != b.categoryId ||
        a.favoritesOnly != b.favoritesOnly ||
        a.archiveOnly != b.archiveOnly ||
        a.lang != b.lang ||
        a.search != b.search ||
        a.sort != b.sort) {
      _load();
    }
  }

  @override
  void dispose() {
    state.revision.removeListener(_load);
    _tick?.cancel();
    hctl.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!hctl.hasClients) return;
    final x = DateTime.now().difference(from).inMinutes * ppm - 45 * ppm;
    hctl.animateTo(x.clamp(0, hctl.position.maxScrollExtent),
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  Future<void> _load() async {
    final src = state.activeSource;
    if (src == null) return;
    final gen = ++_gen;
    setState(() => loading = true);
    // Many playlists list hundreds of channels that have no guide at all (sports
    // events, radio…). Look at a large slice, then show the ones with a guide first.
    final all = await state.repo.browse(widget.query, limit: _scanChannels);
    final ids = {for (final c in all) if (c.epgId != null) c.epgId!}.toList();
    final p = await state.repo.programmes(src.id, ids, from, to, offsetMin: src.epgOffsetMin);
    // Some providers give hundreds of placeholder channels ("NO MATCH", "NO EVENT")
    // the same guide id as one real channel. A guide id used that often is not a real
    // guide for each of them, so those channels count as having none.
    final uses = <String, int>{};
    for (final c in all) {
      if (c.epgId != null) uses[c.epgId!] = (uses[c.epgId!] ?? 0) + 1;
    }
    bool real(ItemView c) => c.epgId != null && (uses[c.epgId!] ?? 0) <= _maxSharedGuide && (p[c.epgId!]?.isNotEmpty ?? false);
    final withData = [for (final c in all) if (real(c)) c];
    final without = [for (final c in all) if (!real(c)) c];
    final shown = (onlyWithGuide && withData.isNotEmpty ? withData : [...withData, ...without]).take(_maxChannels).toList();
    if (!mounted || gen != _gen) return;
    setState(() {
      channels = shown;
      progs = p;
      withoutGuide = without.length;
      loading = false;
    });
  }

  double _x(DateTime t) => labelW + t.difference(from).inSeconds / 60 * ppm;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final now = DateTime.now();
    final width = labelW + to.difference(from).inMinutes * ppm;
    if (channels.isEmpty && !loading) {
      return const EmptyState(icon: LucideIcons.tv, title: 'No channels match these filters');
    }
    if (progs.isEmpty && !loading) {
      return EmptyState(
        icon: LucideIcons.calendarX,
        title: 'No TV guide for these channels',
        message: 'Try another category, or load the TV guide in Settings → Manage playlists → '
            '${state.activeSource?.name ?? 'your playlist'}.',
      );
    }
    return Container(
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        Column(children: [
          if (loading) const LinearProgressIndicator(minHeight: 2),
          if (!loading && withoutGuide > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 8, 0),
              child: Row(children: [
                Icon(LucideIcons.info, size: 15, color: p.ink3),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    onlyWithGuide
                        ? 'Showing channels that have a TV guide. $withoutGuide channels here have none.'
                        : 'Showing all channels, guide channels first. $withoutGuide have no TV guide.',
                    style: TextStyle(fontSize: 12.5, color: p.ink3),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => onlyWithGuide = !onlyWithGuide);
                    _load();
                  },
                  child: Text(onlyWithGuide ? 'Show all channels' : 'Only with a guide'),
                ),
              ]),
            ),
          Expanded(
            child: Scrollbar(
              controller: hctl,
              child: SingleChildScrollView(
                controller: hctl,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(children: [
                    _ruler(p, width),
                    Expanded(
                      child: Stack(children: [
                        ListView.builder(
                          padding: EdgeInsets.only(bottom: picked == null ? 12 : 150),
                          itemExtent: rowH,
                          itemCount: channels.length,
                          itemBuilder: (_, i) => _row(p, channels[i], now),
                        ),
                        Positioned(
                          left: _x(now),
                          top: 0,
                          bottom: 0,
                          child: IgnorePointer(child: Container(width: 2, color: p.live)),
                        ),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ]),
        if (picked != null) Positioned(left: 14, right: 14, bottom: 14, child: _details(p, picked!.$1, picked!.$2, now)),
      ]),
    );
  }

  Widget _details(Palette p, ItemView ch, Programme pr, DateTime now) {
    final live = pr.isLiveAt(now);
    final replay = canReplay(state, ch, pr, now);
    final ended = pr.stop.isBefore(now);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.raised,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (!context.compact) ...[ChannelLogo(ch.icon, width: 64, height: 42), const SizedBox(width: 14)],
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Flexible(
                child: Text(pr.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              if (live) ...[const SizedBox(width: 8), const LiveBadge()],
            ]),
            const SizedBox(height: 2),
            Text('${ch.name} · ${fmtDateTime(pr.start)}–${fmtTime(pr.stop)}', style: TextStyle(fontSize: 12, color: p.ink2)),
            if (pr.description != null && pr.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(pr.description!.trim(),
                  maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: p.ink2, height: 1.4)),
            ],
            if (ended && !replay) ...[
              const SizedBox(height: 6),
              Text('Replay is not available for this programme.', style: TextStyle(fontSize: 12, color: p.ink3)),
            ],
            if (pr.start.isAfter(now)) ...[
              const SizedBox(height: 6),
              Text('Starts at ${fmtTime(pr.start)}', style: TextStyle(fontSize: 12, color: p.ink3)),
            ],
          ]),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (live)
            PrimaryButton(
                label: 'Watch live',
                icon: LucideIcons.play,
                height: 34,
                onPressed: () => openPlayer(context, PlayRequest.live(ch, channels: channels))),
          if (replay)
            PrimaryButton(
                label: 'Watch replay',
                icon: LucideIcons.history,
                height: 34,
                onPressed: () => openPlayer(context, PlayRequest.catchup(ch, pr))),
          const SizedBox(height: 8),
          GhostButton(label: 'Close', height: 32, onPressed: () => setState(() => picked = null)),
        ]),
      ]),
    );
  }

  Widget _ruler(Palette p, double width) {
    final marks = <Widget>[];
    for (var t = from; t.isBefore(to); t = t.add(const Duration(minutes: 30))) {
      marks.add(Positioned(
        left: _x(t),
        top: 0,
        bottom: 0,
        child: Container(
          padding: const EdgeInsets.only(left: 6),
          alignment: Alignment.centerLeft,
          child: Text(t.minute == 0 && t.hour == 0 ? '${fmtTime(t)}  ${t.day}/${t.month}' : fmtTime(t),
              style: TextStyle(fontSize: 12, color: p.ink2, fontWeight: t.minute == 0 ? FontWeight.w600 : FontWeight.w400)),
        ),
      ));
    }
    return SizedBox(
      height: 38,
      width: width,
      child: Stack(children: [
        ...marks,
        AnimatedBuilder(
          animation: hctl,
          builder: (_, _) => Positioned(
            left: hctl.hasClients ? hctl.offset : 0,
            width: labelW,
            top: 0,
            bottom: 0,
            child: Container(
              color: p.card,
              padding: const EdgeInsets.only(left: 12),
              alignment: Alignment.centerLeft,
              child: OutlineBox(height: 26, onTap: _scrollToNow, tooltip: 'Jump to now', child: const Text('Now')),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _row(Palette p, ItemView ch, DateTime now) {
    final list = ch.epgId == null ? const <Programme>[] : (progs[ch.epgId] ?? const []);
    return Stack(children: [
      Positioned.fill(
        child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: p.border, width: 0.5)))),
      ),
      for (final pr in list)
        if (pr.stop.isAfter(from) && pr.start.isBefore(to))
          Positioned(
            left: _x(pr.start.isBefore(from) ? from : pr.start) + 1,
            width: ((pr.stop.isAfter(to) ? to : pr.stop).difference(pr.start.isBefore(from) ? from : pr.start).inSeconds / 60 * ppm - 3)
                .clamp(2, double.infinity),
            top: 5,
            bottom: 5,
            child: _block(p, ch, pr, now),
          ),
      AnimatedBuilder(
        animation: hctl,
        builder: (_, _) => Positioned(
          left: hctl.hasClients ? hctl.offset : 0,
          width: labelW,
          top: 0,
          bottom: 0,
          child: Pressable(
            radius: 0,
            tooltip: 'Watch ${ch.name}',
            onTap: () => openPlayer(context, PlayRequest.live(ch, channels: channels)),
            child: Container(
              color: p.card,
              padding: EdgeInsets.symmetric(horizontal: context.compact ? 6 : 12),
              child: Row(children: [
                ChannelLogo(ch.icon, width: context.compact ? 30 : 46, height: context.compact ? 24 : 30),
                SizedBox(width: context.compact ? 6 : 10),
                Expanded(
                  child: Text(ch.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: context.compact ? 11.5 : 12.5, fontWeight: FontWeight.w600, height: 1.2)),
                ),
                if (ch.isFavorite) FilledHeart(size: 12, color: p.live),
                if (ch.archiveDays > 0) ...[const SizedBox(width: 4), Icon(LucideIcons.history, size: 13, color: p.ink3)],
              ]),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _block(Palette p, ItemView ch, Programme pr, DateTime now) {
    final live = pr.isLiveAt(now);
    final sel = picked != null && picked!.$1.key == ch.key && identical(picked!.$2, pr);
    final past = pr.stop.isBefore(now);
    return Pressable(
      radius: 8,
      tooltip: '${fmtTime(pr.start)}–${fmtTime(pr.stop)}  ${pr.title}',
      onTap: () => setState(() => picked = (ch, pr)),
      onDoubleTap: live ? () => openPlayer(context, PlayRequest.live(ch, channels: channels)) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: sel ? p.pill : (live ? p.cardHover : p.ghost),
          borderRadius: BorderRadius.circular(8),
          border: live && !sel ? Border.all(color: p.ink3, width: 0.8) : null,
        ),
        alignment: Alignment.centerLeft,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pr.title,
              maxLines: 1,
              overflow: TextOverflow.clip,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: live ? FontWeight.w700 : FontWeight.w500,
                  color: sel ? p.onPill : (past ? p.ink2 : p.ink))),
          Text(fmtTime(pr.start),
              maxLines: 1, overflow: TextOverflow.clip, style: TextStyle(fontSize: 11, color: sel ? p.onPill : p.ink3)),
        ]),
      ),
    );
  }
}
