import 'phone_setup_screen.dart';
import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/schema.dart';
import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../cards.dart';
import '../item_actions.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../theme.dart';
import '../widgets.dart';
import 'add_source_screen.dart';

/// Home: Continue watching, then favourite channels, movies and TV shows.
/// Everything here comes from what the person watched or favourited, so a new
/// install shows an illustrated empty state that explains how it fills up.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// One Continue watching entry: the saved position plus the item it belongs to.
class _Resume {
  _Resume(this.watch, this.item);
  final WatchRow watch;
  final ItemView item;
  double get fraction => watch.durationMs > 0 ? (watch.positionMs / watch.durationMs).clamp(0.0, 1.0) : 0;
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppState state = AppScope.read(context);
  static const _rowLimit = 15;

  bool loaded = false;
  List<_Resume> resume = [];
  List<ItemView> channels = [], movies = [], shows = [];

  @override
  void initState() {
    super.initState();
    state.revision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    state.revision.removeListener(_load);
    super.dispose();
  }

  bool _resumable(WatchRow r) => !r.finished && r.durationMs > 0 && r.positionMs >= 15000;

  Future<void> _load() async {
    final src = state.activeSource;
    if (src == null) {
      if (mounted) setState(() { loaded = true; resume = []; channels = []; movies = []; shows = []; });
      return;
    }
    final repo = state.repo;
    final rows = <WatchRow>[
      ...(await repo.recent(src.id, 'movie', limit: 40)).where(_resumable),
      // Only the latest episode of each series.
      ...(await repo.recentSeries(src.id, limit: 40)).where(_resumable),
    ]..sort((a, b) => b.watchedAt.compareTo(a.watchedAt));
    final cont = <_Resume>[];
    for (final r in rows) {
      if (cont.length >= _rowLimit) break;
      final it = r.type == 'movie'
          ? await repo.item(r.sourceId, ContentType.movie, r.itemId)
          : await repo.item(r.sourceId, ContentType.series, r.seriesId ?? '');
      if (it != null) cont.add(_Resume(r, it));
    }
    Future<List<ItemView>> favs(ContentType t) async =>
        (await repo.itemsByIds(src.id, t, await repo.favoriteIds(src.id, t))).take(_rowLimit).toList();
    final c = await favs(ContentType.live);
    final m = await favs(ContentType.movie);
    final s = await favs(ContentType.series);
    if (!mounted) return;
    setState(() {
      loaded = true;
      resume = cont;
      channels = c;
      movies = m;
      shows = s;
    });
  }

  Future<void> _continue(_Resume r) async {
    final it = r.item;
    final start = Duration(milliseconds: r.watch.positionMs);
    if (it.type == ContentType.movie) {
      await openPlayer(context, PlayRequest.movie(it, start: start));
      return;
    }
    try {
      final src = await state.repo.source(it.sourceId);
      if (src == null || !mounted) return;
      final d = await state.catalog.seriesDetail(src, it);
      final ep = d.episodes.where((e) => e.id == r.watch.itemId).firstOrNull;
      if (!mounted) return;
      if (ep == null) {
        openItem(context, it);
        return;
      }
      await openPlayer(context, PlayRequest.episode(it, d, ep, start: start));
    } catch (e) {
      if (mounted) toast(context, 'Could not load the episodes: $e', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.sources.isEmpty) return const _NoPlaylist();
    if (!loaded) return const Center(child: CircularProgressIndicator());
    if (resume.isEmpty && channels.isEmpty && movies.isEmpty && shows.isEmpty) return const _EmptyHome();
    return ListView(padding: const EdgeInsets.only(bottom: 40), children: [
      if (resume.isNotEmpty) ...[
        const ShelfTitle('Continue watching'),
        _Shelf(
          height: 130 * 1.15 + 62,
          children: [for (final r in resume) _ContinueCard(r: r, onTap: () => _continue(r), onRemove: () => _remove(r))],
        ),
      ],
      if (channels.isNotEmpty) ...[
        const ShelfTitle('Favourite channels'),
        _Shelf(height: 96, children: [
          for (final c in channels)
            LogoTile(
              icon: c.icon,
              label: c.name,
              onTap: () => openItem(context, c, channels: channels),
              onMenu: (pos) => showItemMenu(context, c, pos,
                  onOpen: () => openItem(context, c, channels: channels), onGuide: () => openGuide(context, c)),
            ),
        ]),
      ],
      if (movies.isNotEmpty) ...[const ShelfTitle('Favourite movies'), _posters(movies)],
      if (shows.isNotEmpty) ...[const ShelfTitle('Favourite TV shows'), _posters(shows)],
    ]);
  }

  Future<void> _remove(_Resume r) => r.watch.type == 'episode'
      ? state.repo.removeSeriesWatch(r.watch.sourceId, r.watch.seriesId ?? r.item.id)
      : state.repo.removeWatch(r.watch.sourceId, r.watch.type, r.watch.itemId);

  Widget _posters(List<ItemView> list) {
    const w = 140.0;
    return _Shelf(
      height: w * 1.5 + PosterCard.captionHeight,
      gap: 16,
      children: [
        for (final it in list)
          SizedBox(
            width: w,
            child: PosterCard(
              item: it,
              onTap: () => openItem(context, it),
              onFavorite: () => state.repo.toggleFavorite(it.sourceId, it.type, it.id),
              onMenu: (pos) => showItemMenu(context, it, pos, onOpen: () => openItem(context, it), openLabel: 'Show details'),
            ),
          ),
      ],
    );
  }
}

/// A horizontally scrolling row.
class _Shelf extends StatelessWidget {
  const _Shelf({required this.height, required this.children, this.gap = 14});
  final double height, gap;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: context.gutter),
          itemCount: children.length,
          separatorBuilder: (_, _) => SizedBox(width: gap),
          itemBuilder: (_, i) => children[i],
        ),
      );
}

/// Wide 16:9 card with a type tag, a progress bar and "S2 E4, 23 min left".
class _ContinueCard extends StatefulWidget {
  const _ContinueCard({required this.r, required this.onTap, required this.onRemove});
  final _Resume r;
  final VoidCallback onTap, onRemove;

  @override
  State<_ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<_ContinueCard> {
  _Resume get r => widget.r;
  VoidCallback get onTap => widget.onTap;
  VoidCallback get onRemove => widget.onRemove;
  bool hover = false;

  static const double w = 260;

  String get _sub {
    final left = Duration(milliseconds: (r.watch.durationMs - r.watch.positionMs).clamp(0, 1 << 40));
    final mins = left.inMinutes;
    final time = mins >= 60 ? '${mins ~/ 60} h ${(mins % 60).toString().padLeft(2, '0')} min left' : '${mins < 1 ? 1 : mins} min left';
    return r.watch.type == 'episode' ? 'S${r.watch.season ?? 1} E${r.watch.episode ?? 1}, $time' : time;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final isEpisode = r.watch.type == 'episode';
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: SizedBox(
      width: w,
      child: Pressable(
        onTap: onTap,
        onSecondaryTapUp: (_) => onRemove(),
        radius: 14,
        tooltip: 'Continue watching',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: w,
              height: w * 9 / 16,
              child: Stack(fit: StackFit.expand, children: [
                ColoredBox(color: p.card, child: NetImage(r.watch.icon ?? r.item.icon, fit: BoxFit.cover)),
                Positioned(
                  left: 10,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: p.overlay, borderRadius: BorderRadius.circular(6)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(isEpisode ? LucideIcons.tvMinimalPlay : LucideIcons.clapperboard, size: 12, color: p.ink),
                      const SizedBox(width: 5),
                      Text(isEpisode ? 'Series' : 'Movie',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
                Positioned(left: 0, right: 0, bottom: 0, child: ThinBar(r.fraction)),
                if (hover) Positioned(right: 8, top: 8, child: RemoveChip(onTap: onRemove)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Text(r.item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(_sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, color: p.ink3)),
        ]),
      ),
      ),
    );
  }
}

/// No playlist added yet.
class _NoPlaylist extends StatelessWidget {
  const _NoPlaylist();

  @override
  Widget build(BuildContext context) => _Illustrated(
        title: 'Welcome to TVflow',
        message: 'Add an M3U playlist, Xtream Codes account or Stalker portal to start watching. Your playlists and '
            'credentials stay on this $deviceName.',
        actions: [
          PrimaryButton(label: 'Add playlist', icon: LucideIcons.plus, onPressed: () => openAddSource(context)),
          if (isTv)
            GhostButton(
              label: 'Add from phone',
              icon: LucideIcons.smartphone,
              onPressed: () => Navigator.of(context).push(fadeRoute(const PhoneSetupScreen())),
            ),
          GhostButton(
            label: 'Local file',
            icon: LucideIcons.folderOpen,
            onPressed: () => Navigator.of(context).push(fadeRoute(const AddSourceScreen(initialKind: SourceKind.file))),
          ),
        ],
      );
}

/// A playlist is loaded but nothing was watched or favourited yet.
class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return _Illustrated(
      title: 'Your home fills up as you watch',
      message: 'Start watching something and it shows up under Continue watching. Tap the heart on a channel, movie or '
          'TV show and it is kept here, so you never have to hunt for it again.',
      actions: [
        PrimaryButton(label: 'Browse Live TV', icon: LucideIcons.tv, onPressed: () => state.go(MainTab.live)),
        GhostButton(label: 'Movies', icon: LucideIcons.clapperboard, onPressed: () => state.go(MainTab.movies)),
        GhostButton(label: 'Series', icon: LucideIcons.tvMinimalPlay, onPressed: () => state.go(MainTab.series)),
      ],
    );
  }
}

/// Centred outline of the Home layout (the shelves that will appear), with a
/// title, a line of help and buttons. Drawn only from layout shapes: it shows
/// where things will go, not sample content.
class _Illustrated extends StatelessWidget {
  const _Illustrated({required this.title, required this.message, required this.actions});
  final String title, message;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _Skeleton(),
          const SizedBox(height: 30),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(message, textAlign: TextAlign.center, style: TextStyle(color: p.ink2, fontSize: 15, height: 1.45)),
          ),
          const SizedBox(height: 22),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: actions),
        ]),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    Widget box(double w, double h, {double r = 10, bool accent = false, double? progress}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(r),
            border: Border.all(color: accent ? p.accent.withValues(alpha: 0.5) : p.cardHover, width: 1.5),
          ),
          alignment: Alignment.bottomLeft,
          child: progress == null
              ? null
              : ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(r)),
                  child: SizedBox(
                      height: 4,
                      width: w * progress,
                      child: ColoredBox(color: p.accent)),
                ),
        );
    Widget label(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(icon, size: 14, color: p.accent),
            const SizedBox(width: 6),
            Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink3)),
          ]),
        );
    Widget row(Widget head, List<Widget> items) =>
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          head,
          ClipRect(
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(children: [for (final w in items) ...[w, const SizedBox(width: 10)]]))),
        ]);
    return Container(
      width: (MediaQuery.sizeOf(context).width - 64).clamp(0.0, 520.0),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: p.pane, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        row(label(LucideIcons.play, 'Continue watching'),
            [box(140, 79, r: 10, accent: true, progress: 0.6), box(140, 79, r: 10, progress: 0.3), box(140, 79, r: 10, progress: 0.8)]),
        const SizedBox(height: 16),
        row(label(LucideIcons.tv, 'Favourite channels'), [for (var i = 0; i < 6; i++) box(64, 48, r: 10)]),
        const SizedBox(height: 16),
        row(label(LucideIcons.heart, 'Favourite movies and TV shows'), [for (var i = 0; i < 7; i++) box(54, 80, r: 8)]),
      ]),
    );
  }
}
