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
import '../theme.dart';
import '../widgets.dart';

/// Search across channels, movies and series of the active source.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ctl = TextEditingController();
  final focus = FocusNode();
  Timer? _debounce;
  Map<ContentType, List<ItemView>> results = {};
  bool searching = false;
  int _gen = 0;
  late final AppState state = AppScope.read(context);

  @override
  void initState() {
    super.initState();
    state.revision.addListener(_rerun);
    WidgetsBinding.instance.addPostFrameCallback((_) => focus.requestFocus());
  }

  @override
  void dispose() {
    state.revision.removeListener(_rerun);
    _debounce?.cancel();
    ctl.dispose();
    focus.dispose();
    super.dispose();
  }

  void _rerun() => _run(ctl.text);

  Future<void> _run(String text) async {
    final src = state.activeSource;
    if (src == null) return;
    final gen = ++_gen;
    if (text.trim().length < 2) {
      setState(() {
        results = {};
        searching = false;
      });
      return;
    }
    setState(() => searching = true);
    final r = await state.repo.searchAll(src.id, text, perType: 60);
    if (!mounted || gen != _gen) return;
    setState(() {
      results = r;
      searching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final total = results.values.fold<int>(0, (a, b) => a + b.length);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      PageHeader('Search', subtitle: state.activeSource?.name),
      Padding(
        padding: EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 16),
        child: TvEditGate(child: TextField(
          controller: ctl,
          focusNode: focus,
          style: const TextStyle(fontSize: 17),
          onChanged: (v) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 250), () => _run(v));
          },
          decoration: InputDecoration(
            hintText: 'Channels, movies and series',
            hintStyle: TextStyle(color: p.ink3, fontSize: 17),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Icon(LucideIcons.search, color: p.ink2, size: 22),
            ),
            suffixIcon: ctl.text.isEmpty
                ? null
                : IconBtn(LucideIcons.circleX, size: 18, color: p.ink3, tooltip: 'Clear', onTap: () {
                    ctl.clear();
                    _run('');
                  }),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.accent, width: 2)),
          ),
        )),
      ),
      if (searching) const LinearProgressIndicator(minHeight: 2),
      Expanded(
        child: ctl.text.trim().length < 2
            ? const EmptyState(
                icon: LucideIcons.search, title: 'Search everything', message: 'Type at least two letters of a channel, movie or series.')
            : total == 0 && !searching
                ? EmptyState(icon: LucideIcons.search, title: 'No results for "${ctl.text.trim()}"')
                : LayoutBuilder(builder: (context, c) {
                    const cardW = 150.0;
                    final chCols = ((c.maxWidth - context.gutter * 2) / 360).floor().clamp(1, 5);
                    return ListView(padding: EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 40), children: [
                      for (final t in [ContentType.live, ContentType.movie, ContentType.series])
                        if ((results[t] ?? const []).isNotEmpty) ...[
                          ShelfTitle(
                            t == ContentType.live ? 'Channels' : t.label,
                            padding: const EdgeInsets.only(top: 14, bottom: 10),
                            trailing: Text('${results[t]!.length}${results[t]!.length == 60 ? '+' : ''}',
                                style: TextStyle(fontSize: 12, color: p.ink3)),
                          ),
                          if (t == ContentType.live)
                            Wrap(spacing: 8, runSpacing: 4, children: [
                              for (final it in results[t]!)
                                SizedBox(
                                  width: (c.maxWidth - context.gutter * 2 - 8 * (chCols - 1)) / chCols,
                                  height: 64,
                                  child: ChannelCard(
                                    item: it,
                                    onTap: () => openItem(context, it, channels: results[t]),
                                    onFavorite: () => state.repo.toggleFavorite(it.sourceId, it.type, it.id),
                                    onMenu: (pos) => showItemMenu(context, it, pos,
                                        onOpen: () => openItem(context, it), onGuide: () => openGuide(context, it)),
                                  ),
                                ),
                            ])
                          else
                            SizedBox(
                              height: cardW * 1.5 + PosterCard.captionHeight + 16,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                padding: const EdgeInsets.only(top: 6, bottom: 10),
                                itemCount: results[t]!.length,
                                separatorBuilder: (_, _) => const SizedBox(width: 18),
                                itemBuilder: (_, i) {
                                  final it = results[t]![i];
                                  return SizedBox(
                                    width: cardW,
                                    child: PosterCard(
                                      item: it,
                                      onTap: () => openItem(context, it),
                                      onFavorite: () => state.repo.toggleFavorite(it.sourceId, it.type, it.id),
                                      onMenu: (pos) => showItemMenu(context, it, pos,
                                          onOpen: () => openItem(context, it), openLabel: 'Show details'),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                    ]);
                  }),
      ),
    ]);
  }
}
