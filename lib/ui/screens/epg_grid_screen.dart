import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../theme.dart';
import '../widgets.dart';
import 'detail_common.dart';

/// TV guide grid: channels down the side, time across the top.
class EpgGridScreen extends StatefulWidget {
  const EpgGridScreen({super.key, this.categoryId});
  final String? categoryId;
  @override
  State<EpgGridScreen> createState() => _EpgGridScreenState();
}

class _EpgGridScreenState extends State<EpgGridScreen> {
  static const ppm = 4.0; // pixels per minute
  static const labelW = 220.0;
  static const rowH = 62.0;
  static const _maxChannels = 400;

  late final AppState state = AppScope.read(context);
  final hctl = ScrollController();
  late DateTime from;
  late DateTime to;
  String? categoryId;
  List<CategoryView> cats = [];
  List<ItemView> channels = [];
  Map<String, List<Programme>> progs = {};
  bool loading = true;
  bool favoritesOnly = false;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    categoryId = widget.categoryId;
    final now = DateTime.now();
    from = DateTime(now.year, now.month, now.day, now.hour).subtract(const Duration(hours: 3));
    to = from.add(const Duration(hours: 30));
    _tick = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
    _load();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToNow());
  }

  @override
  void dispose() {
    _tick?.cancel();
    hctl.dispose();
    super.dispose();
  }

  void _scrollToNow() {
    if (!hctl.hasClients) return;
    final x = DateTime.now().difference(from).inMinutes * ppm - 60 * ppm;
    hctl.jumpTo(x.clamp(0, hctl.position.maxScrollExtent));
  }

  Future<void> _load() async {
    final src = state.activeSource;
    if (src == null) return;
    setState(() => loading = true);
    cats = await state.repo.categories(src.id, ContentType.live);
    final q = BrowseQuery(
        sourceId: src.id, type: ContentType.live, categoryId: categoryId, favoritesOnly: favoritesOnly);
    final ch = await state.repo.browse(q, limit: _maxChannels);
    final ids = {for (final c in ch) if (c.epgId != null) c.epgId!}.toList();
    final p = await state.repo.programmes(src.id, ids, from, to, offsetMin: src.epgOffsetMin);
    if (!mounted) return;
    setState(() {
      channels = ch;
      progs = p;
      loading = false;
    });
  }

  double _x(DateTime t) => labelW + t.difference(from).inSeconds / 60 * ppm;

  void _tapProgramme(ItemView ch, Programme pr) {
    final now = DateTime.now();
    final src = state.activeSource!;
    if (pr.isLiveAt(now)) {
      openPlayer(context, PlayRequest.live(ch, channels: channels));
      return;
    }
    final canReplay = pr.stop.isBefore(now) &&
        now.difference(pr.start).inDays < ch.archiveDays &&
        state.catalog.catchupUrl(src, ch, pr) != null;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(pr.title),
        content: SizedBox(
          width: 460,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${ch.name} · ${fmtDateTime(pr.start)}–${fmtTime(pr.stop)}', style: TextStyle(color: c.pal.ink2)),
            if (pr.description != null) ...[const SizedBox(height: 12), Text(pr.description!)],
            if (pr.stop.isBefore(now) && !canReplay) ...[
              const SizedBox(height: 12),
              Text('Replay is not available for this programme.', style: TextStyle(color: c.pal.ink3)),
            ],
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close')),
          if (canReplay)
            TextButton(
                onPressed: () {
                  Navigator.pop(c);
                  openPlayer(context, PlayRequest.catchup(ch, pr));
                },
                child: const Text('Watch replay')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final now = DateTime.now();
    final width = labelW + to.difference(from).inMinutes * ppm;
    final catName = categoryId == null ? 'All channels' : cats.where((c) => c.id == categoryId).firstOrNull?.name ?? 'Category';
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          BackBar(title: 'TV guide', trailing: [
            OutlineBox(
              selected: favoritesOnly,
              tooltip: 'Favorites only',
              onTap: () {
                favoritesOnly = !favoritesOnly;
                _load();
              },
              child: const Icon(LucideIcons.heart, size: 18),
            ),
            const SizedBox(width: 10),
            PopupMenuButton<String?>(
              tooltip: 'Category',
              onSelected: (v) {
                categoryId = v == '' ? null : v;
                _load();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: '', child: Text('All channels')),
                for (final c in cats) PopupMenuItem(value: c.id, child: Text(c.name)),
              ],
              child: OutlineBox(
                child: Row(children: [
                  ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(catName, overflow: TextOverflow.ellipsis)),
                  const Icon(LucideIcons.chevronDown),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            OutlineBox(onTap: _scrollToNow, child: const Text('Now')),
          ]),
          if (loading) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: channels.isEmpty && !loading
                ? const EmptyState(icon: LucideIcons.tv, title: 'No channels')
                : progs.isEmpty && !loading
                    ? EmptyState(
                        icon: LucideIcons.calendarX,
                        title: 'No guide data',
                        message: 'Load the TV guide from Menu → Manage playlists → ${state.activeSource?.name ?? 'playlist'}.',
                      )
                    : Scrollbar(
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
      ),
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
          decoration: BoxDecoration(border: Border(left: BorderSide(color: p.border))),
          alignment: Alignment.centerLeft,
          child: Text(t.minute == 0 && t.hour == 0 ? '${fmtTime(t)}  ${t.day}/${t.month}' : fmtTime(t),
              style: TextStyle(fontSize: 12, color: p.ink2, fontWeight: t.minute == 0 ? FontWeight.w600 : FontWeight.w400)),
        ),
      ));
    }
    return SizedBox(
      height: 34,
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
            child: Container(color: p.bg),
          ),
        ),
      ]),
    );
  }

  Widget _row(Palette p, ItemView ch, DateTime now) {
    final list = ch.epgId == null ? const <Programme>[] : (progs[ch.epgId] ?? const []);
    return Stack(children: [
      Positioned.fill(
        child: Container(decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.border)))),
      ),
      for (final pr in list)
        if (pr.stop.isAfter(from) && pr.start.isBefore(to))
          Positioned(
            left: _x(pr.start.isBefore(from) ? from : pr.start) + 1,
            width: ((pr.stop.isAfter(to) ? to : pr.stop).difference(pr.start.isBefore(from) ? from : pr.start).inSeconds / 60 * ppm - 2)
                .clamp(2, double.infinity),
            top: 4,
            bottom: 4,
            child: Pressable(
              radius: 6,
              tooltip: '${fmtTime(pr.start)}–${fmtTime(pr.stop)}  ${pr.title}',
              onTap: () => _tapProgramme(ch, pr),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: pr.isLiveAt(now) ? p.cardHover : p.card,
                  borderRadius: BorderRadius.circular(6),
                  border: pr.isLiveAt(now) ? Border.all(color: p.ink2) : null,
                ),
                alignment: Alignment.centerLeft,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(pr.title,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: pr.isLiveAt(now) ? FontWeight.w700 : FontWeight.w500,
                          color: pr.stop.isBefore(now) ? p.ink2 : p.ink)),
                  Text(fmtTime(pr.start), maxLines: 1, overflow: TextOverflow.clip, style: TextStyle(fontSize: 11, color: p.ink3)),
                ]),
              ),
            ),
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
            onTap: () => openPlayer(context, PlayRequest.live(ch, channels: channels)),
            child: Container(
              color: p.bg,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                SizedBox(width: 48, height: 32, child: NetImage(ch.icon, fit: BoxFit.contain, cacheWidth: 100)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(ch.name.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: Fonts.condensed, fontSize: 13.5, fontWeight: FontWeight.w500)),
                ),
                if (ch.archiveDays > 0) Icon(LucideIcons.history, size: 14, color: p.ink3),
              ]),
            ),
          ),
        ),
      ),
    ]);
  }
}
