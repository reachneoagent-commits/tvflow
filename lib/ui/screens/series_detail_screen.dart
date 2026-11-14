import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/schema.dart';
import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../navigation.dart';
import '../theme.dart';
import '../widgets.dart';
import 'detail_common.dart';

class SeriesDetailScreen extends StatefulWidget {
  const SeriesDetailScreen({super.key, required this.item});
  final ItemView item;
  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  late final AppState state = AppScope.read(context);
  SeriesDetail? detail;
  String? error;
  int? season;
  Map<String, WatchRow> progress = {};
  bool loading = true;

  @override
  void initState() {
    super.initState();
    state.revision.addListener(_loadProgress);
    _load();
  }

  @override
  void dispose() {
    state.revision.removeListener(_loadProgress);
    super.dispose();
  }

  Future<void> _load({bool force = false}) async {
    setState(() {
      loading = true;
      error = null;
    });
    await _loadProgress();
    try {
      final src = await state.repo.source(widget.item.sourceId);
      if (src == null) throw StateError('Playlist was removed.');
      final d = await state.catalog.seriesDetail(src, widget.item, force: force);
      if (!mounted) return;
      final last = _lastWatched();
      final ep = last == null ? null : d.episodes.where((e) => e.id == last.itemId).firstOrNull;
      setState(() {
        detail = d;
        season = ep?.season ?? (d.seasons.isEmpty ? null : d.seasons.first);
        loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          loading = false;
        });
      }
    }
  }

  Future<void> _loadProgress() async {
    final m = await state.repo.seriesProgress(widget.item.sourceId, widget.item.id);
    if (mounted) setState(() => progress = m);
  }

  WatchRow? _lastWatched() {
    if (progress.isEmpty) return null;
    return progress.values.reduce((a, b) => a.watchedAt >= b.watchedAt ? a : b);
  }

  /// The episode to continue with: the last one if unfinished, else the next.
  (EpisodeInfo, bool)? _continueTarget(SeriesDetail d) {
    final last = _lastWatched();
    final eps = [...d.episodes]
      ..sort((a, b) => a.season != b.season ? a.season - b.season : a.episode - b.episode);
    if (eps.isEmpty) return null;
    if (last == null) return (eps.first, false);
    final i = eps.indexWhere((e) => e.id == last.itemId);
    if (i < 0) return (eps.first, false);
    if (!last.finished) return (eps[i], true);
    return i + 1 < eps.length ? (eps[i + 1], false) : null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final d = detail;
    final target = d == null ? null : _continueTarget(d);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          BackBar(title: widget.item.name, trailing: [
            IconBtn(LucideIcons.rotateCcw, tooltip: 'Reload episodes', onTap: () => _load(force: true)),
          ]),
          Expanded(
            child: LiveItem(
              item: widget.item,
              builder: (context, it) => CustomScrollView(slivers: [
                SliverToBoxAdapter(
                  child: DetailHeader(
                    item: it,
                    backdrop: d?.backdrop,
                    plot: d?.plot ?? it.plot,
                    rating: d?.rating ?? it.rating,
                    facts: [
                      if (d?.genre != null) ('Genre', d!.genre!),
                      if (d?.releaseDate != null) ('Released', d!.releaseDate!),
                      if (d?.director != null) ('Director', d!.director!),
                      if (d?.cast != null) ('Cast', d!.cast!),
                    ],
                    actions: [
                      if (target != null)
                        PrimaryButton(
                          autofocus: true,
                          label: target.$2
                              ? 'Resume S${target.$1.season} E${target.$1.episode}'
                              : (progress.isEmpty
                                  ? 'Play S${target.$1.season} E${target.$1.episode}'
                                  : 'Next: S${target.$1.season} E${target.$1.episode}'),
                          icon: LucideIcons.play,
                          onPressed: () => playEpisode(context, it, d!, target.$1),
                        ),
                    ],
                  ),
                ),
                if (loading)
                  const SliverToBoxAdapter(
                      child: Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))),
                if (error != null)
                  SliverToBoxAdapter(
                    child: EmptyState(
                      icon: LucideIcons.cloudOff,
                      title: 'Episodes could not be loaded',
                      message: error,
                      action: PrimaryButton(label: 'Retry', icon: LucideIcons.rotateCcw, onPressed: () => _load(force: true)),
                    ),
                  ),
                if (d != null && d.episodes.isEmpty)
                  const SliverToBoxAdapter(
                      child: EmptyState(icon: LucideIcons.library, title: 'No episodes available')),
                if (d != null && d.seasons.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(context.compact ? 16 : 36, 12, context.compact ? 16 : 36, 12),
                      child: SizedBox(
                        height: 32,
                        child: ListView(scrollDirection: Axis.horizontal, children: [
                          for (final s in d.seasons) ...[
                            OutlineBox(
                              selected: s == season,
                              onTap: () => setState(() => season = s),
                              child: Text(s == 0 ? 'Specials' : 'Season $s'),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ]),
                      ),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: d.episodes.where((e) => e.season == season).length,
                    itemBuilder: (_, i) {
                      final eps = d.episodes.where((e) => e.season == season).toList()
                        ..sort((a, b) => a.episode - b.episode);
                      final e = eps[i];
                      final w = progress[e.id];
                      final frac = w == null
                          ? null
                          : w.finished
                              ? 1.0
                              : (w.durationMs > 0 ? w.positionMs / w.durationMs : null);
                      return Pressable(
                        radius: 12,
                        onTap: () => playEpisode(context, it, d, e),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: context.compact ? 8 : 24),
                          padding: EdgeInsets.symmetric(horizontal: context.compact ? 6 : 12, vertical: 10),
                          child: Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: context.compact ? 120 : 192,
                                height: context.compact ? 68 : 108,
                                child: Stack(fit: StackFit.expand, children: [
                                  NetImage(e.image ?? it.icon, cacheWidth: 352, placeholderIcon: LucideIcons.clapperboard),
                                  const Center(
                                      child: Icon(LucideIcons.circlePlay, color: Colors.white70, size: 34)),
                                  if (frac != null)
                                    Positioned(
                                      left: 8,
                                      right: 8,
                                      bottom: 8,
                                      child: ThinBar(frac, height: 4, color: Colors.white, track: Colors.white30),
                                    ),
                                ]),
                              ),
                            ),
                            SizedBox(width: context.compact ? 12 : 18),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(
                                      '${e.episode}. ${e.title.isEmpty ? 'Episode ${e.episode}' : e.title}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                  ),
                                  if (w?.finished == true)
                                    Tooltip(message: 'Watched', child: Icon(LucideIcons.circleCheck, size: 18, color: p.ink2)),
                                ]),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (e.durationSecs != null && e.durationSecs! > 0)
                                      fmtDuration(Duration(seconds: e.durationSecs!)),
                                    if (e.airDate != null && e.airDate!.isNotEmpty) e.airDate!,
                                    if (w != null && !w.finished && w.positionMs > 0)
                                      'stopped at ${fmtDuration(Duration(milliseconds: w.positionMs))}',
                                  ].join('  ·  '),
                                  style: TextStyle(color: p.ink2, fontSize: 12.5),
                                ),
                                if (e.plot != null && e.plot!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(e.plot!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: p.ink2, fontSize: 13, height: 1.35)),
                                ],
                              ]),
                            ),
                            if (w != null)
                              PopupMenuButton<String>(
                                tooltip: 'More',
                                icon: Icon(LucideIcons.ellipsis, color: p.ink2),
                                onSelected: (v) async {
                                  if (v == 'restart') {
                                    await playEpisode(context, it, d, e, ask: false);
                                  } else if (v == 'unwatch') {
                                    await state.repo.removeWatch(it.sourceId, 'episode', e.id);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'restart', child: Text('Play from start')),
                                  PopupMenuItem(value: 'unwatch', child: Text('Mark as unwatched')),
                                ],
                              ),
                          ]),
                        ),
                      );
                    },
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
