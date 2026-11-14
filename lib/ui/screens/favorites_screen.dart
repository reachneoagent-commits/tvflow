import '../../core/platform.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../cards.dart';
import '../item_actions.dart';
import '../navigation.dart';
import '../widgets.dart';
import 'settings/settings_screen.dart';

/// Favourite channels, movies and series of the active source.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final AppState state = AppScope.read(context);
  Map<ContentType, List<ItemView>>? favs;
  Map<String, Programme> nowPlaying = {};

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

  Future<void> _load() async {
    final src = state.activeSource;
    if (src == null) {
      if (mounted) setState(() => favs = {});
      return;
    }
    final out = <ContentType, List<ItemView>>{};
    for (final t in ContentType.values) {
      final ids = await state.repo.favoriteIds(src.id, t);
      out[t] = await state.repo.itemsByIds(src.id, t, ids);
    }
    final epg = {for (final c in out[ContentType.live]!) if (c.epgId != null) c.epgId!}.toList();
    final now = DateTime.now();
    final progs = await state.repo.programmes(src.id, epg, now, now.add(const Duration(seconds: 1)),
        offsetMin: src.epgOffsetMin);
    if (!mounted) return;
    setState(() {
      favs = out;
      nowPlaying = {
        for (final e in progs.entries)
          e.key: ?e.value.where((p) => p.isLiveAt(now)).firstOrNull
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final f = favs;
    if (f == null) return const Center(child: CircularProgressIndicator());
    final empty = f.values.every((l) => l.isEmpty);
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(child: PageHeader('Favourites', subtitle: state.activeSource?.name)),
      if (empty)
        const SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            icon: LucideIcons.heart,
            title: 'No favourites yet',
            message: 'Click ♥ on any channel, movie or series to keep it here.',
          ),
        ),
      for (final t in [ContentType.live, ContentType.movie, ContentType.series])
        if ((f[t] ?? const []).isNotEmpty) ...[
          SliverToBoxAdapter(
            child: ShelfTitle(
              t == ContentType.live ? 'Channels' : t.label,
              trailing: OutlineBox(
                tooltip: 'Change the order',
                onTap: () async {
                  await showDialog(
                      context: context,
                      builder: (_) => FavoritesOrderDialog(sourceId: state.activeSource!.id, type: t));
                  _load();
                },
                child: const Row(children: [Icon(LucideIcons.arrowUpDown), SizedBox(width: 5), Text('Reorder')]),
              ),
            ),
          ),
          if (t == ContentType.live) _channels(f[t]!) else _posters(f[t]!),
        ],
      const SliverToBoxAdapter(child: SizedBox(height: 40)),
    ]);
  }

  Widget _channels(List<ItemView> list) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverLayoutBuilder(builder: (context, c) {
          final cols = (c.crossAxisExtent / 360).floor().clamp(1, 5);
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols, mainAxisExtent: 64, crossAxisSpacing: 10, mainAxisSpacing: 6),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final it = list[i];
                return ChannelCard(
                  item: it,
                  now: it.epgId == null ? null : nowPlaying[it.epgId],
                  onTap: () => openItem(context, it, channels: list),
                  onFavorite: () => state.repo.toggleFavorite(it.sourceId, it.type, it.id),
                  onMenu: (pos) => showItemMenu(context, it, pos,
                      onOpen: () => openItem(context, it, channels: list), onGuide: () => openGuide(context, it)),
                );
              },
              childCount: list.length,
            ),
          );
        }),
      );

  Widget _posters(List<ItemView> list) => SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: context.gutter),
        sliver: SliverLayoutBuilder(builder: (context, c) {
          final cols = (c.crossAxisExtent / 170).floor().clamp(2, 12);
          final w = (c.crossAxisExtent - (cols - 1) * 18) / cols;
          return SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols, mainAxisExtent: w * 1.5 + PosterCard.captionHeight, crossAxisSpacing: 18, mainAxisSpacing: 18),
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final it = list[i];
                return PosterCard(
                  item: it,
                  onTap: () => openItem(context, it),
                  onFavorite: () => state.repo.toggleFavorite(it.sourceId, it.type, it.id),
                  onMenu: (pos) => showItemMenu(context, it, pos, onOpen: () => openItem(context, it), openLabel: 'Show details'),
                );
              },
              childCount: list.length,
            ),
          );
        }),
      );
}
