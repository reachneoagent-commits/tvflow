import '../../core/platform.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';

import '../../data/database/schema.dart';
import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../cards.dart';
import '../item_actions.dart';
import '../navigation.dart';
import '../theme.dart';
import '../widgets.dart';
import 'category_manager.dart';
import 'hero_banner.dart';
import 'live_preview.dart';
import '../player/play_request.dart';
import 'tv_guide_view.dart';

/// Live TV / Movies / Series: title, filters, category column and content.
class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key, required this.type});
  final ContentType type;

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  static const _page = 240;
  static const _shelfPosterW = 150.0;
  double get _shelfW => context.compact ? 118 : _shelfPosterW;

  late AppState state;
  String? _sourceId;
  BrowseQuery? q;
  List<ItemView> items = [];
  int total = 0;
  bool loading = false;
  bool _loadingMore = false;
  List<CategoryView> cats = [];
  Map<String, int> counts = {};
  List<(String, int)> chips = [];
  bool sidebar = true;
  Map<String, Programme> nowPlaying = {};
  List<WatchRow> recents = [];
  List<ItemView> resumeItems = [];

  /// Movie id → its watch row; series id → its last watched episode.
  Map<String, WatchRow> resumeRows = {};
  List<ItemView> newest = [];

  /// Live TV: the channel shown in the side panel, and list vs guide view.
  ItemView? selected;
  bool guide = false;

  /// Live TV: channel list with a preview window and its guide on the right.
  bool preview = false;
  final previewKey = GlobalKey<LivePreviewPaneState>();
  final selectedKey = GlobalKey();
  final listFocus = FocusNode(debugLabel: 'browse list');

  final searchCtl = TextEditingController();
  final scroll = ScrollController();
  Timer? _debounce;
  Timer? _clock;
  int _gen = 0;

  ContentType get type => widget.type;
  bool get isLive => type == ContentType.live;

  String get _noun => switch (type) {
        ContentType.live => 'channels',
        ContentType.movie => 'movies',
        ContentType.series => 'series',
      };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    state = AppScope.of(context);
    final sid = state.activeSource?.id;
    if (sid != _sourceId) {
      _sourceId = sid;
      selected = null;
      if (sid != null) {
        final defCat = state.str(P.defaultCat(type));
        q = BrowseQuery(
          sourceId: sid,
          type: type,
          categoryId: defCat.isEmpty ? null : defCat,
          sort: state.sortFor(type),
          favoritesFirst: state.flag(P.favFirst(type)),
        );
        if (isLive) guide = state.flag(P.liveEpgGrid);
        searchCtl.clear();
        _reloadAll();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (isTv) tvBackHandlers.add(_tvBackHandler);
    AppScope.read(context).revision.addListener(_onRevision);
    _clock = Timer.periodic(const Duration(seconds: 60), (_) => _loadNowPlaying(items));
  }

  @override
  void dispose() {
    tvBackHandlers.remove(_tvBackHandler);
    _pickTimer?.cancel();
    for (final n in _railNodes.values) {
      n.dispose();
    }
    _contentNode.dispose();
    state.revision.removeListener(_onRevision);
    _debounce?.cancel();
    _clock?.cancel();
    scroll.dispose();
    searchCtl.dispose();
    listFocus.dispose();
    super.dispose();
  }

  // --- TV: category rail and content are two regions; Back goes content -> rail -> menu bar.
  final _contentNode = FocusNode(skipTraversal: true, canRequestFocus: false);
  final Map<String, FocusNode> _railNodes = {};
  Timer? _pickTimer;

  bool _tvBackHandler() {
    final pf = FocusManager.instance.primaryFocus;
    if (!mounted || q == null || pf == null || !pf.ancestors.contains(_contentNode)) return false;
    final rail = _railNodes[q!.categoryId ?? ''];
    if (rail == null || rail.context == null) return false;
    rail.requestFocus();
    return true;
  }

  /// Focusing a category on the rail shows it after a short pause, like the Roku app does.
  void _tvPick(String? id) {
    _pickTimer?.cancel();
    _pickTimer = Timer(const Duration(milliseconds: 350), () {
      if (mounted && q != null && q!.categoryId != id) _setQuery(q!.copyWith(categoryId: id));
    });
  }

  void _onRevision() {
    if (!mounted || q == null) return;
    q = q!.copyWith(favoritesFirst: state.flag(P.favFirst(type)));
    _reloadAll(keepScroll: true);
  }

  Future<void> _reloadAll({bool keepScroll = false}) async {
    final query = q;
    if (query == null) return;
    final repo = state.repo;
    final c = await repo.categories(query.sourceId, type);
    final n = await repo.categoryCounts(query.sourceId, type);
    final ch = await repo.chips(query.sourceId, type);
    if (!mounted) return;
    setState(() {
      cats = c;
      counts = n;
      chips = ch;
    });
    await _loadHeader();
    await _load(reset: true, keepScroll: keepScroll);
  }

  Future<void> _loadHeader() async {
    final query = q!;
    final repo = state.repo;
    resumeRows = {};
    if (!state.flag(P.recents(type), true)) {
      recents = [];
      resumeItems = [];
    } else if (isLive) {
      recents = await repo.recent(query.sourceId, 'live', limit: 20);
    } else if (type == ContentType.series) {
      final rows = await repo.recentSeries(query.sourceId, limit: 20);
      resumeItems = await repo.itemsByIds(query.sourceId, type, [for (final r in rows) r.seriesId!]);
      resumeRows = {for (final r in rows) r.seriesId!: r};
    } else {
      final rows = (await repo.recent(query.sourceId, 'movie', limit: 40))
          .where((r) => !r.finished && r.positionMs > 0)
          .toList();
      resumeItems = await repo.itemsByIds(query.sourceId, type, [for (final r in rows) r.itemId]);
      resumeRows = {for (final r in rows) r.itemId: r};
    }
    if (!isLive) newest = await repo.newest(query.sourceId, type, limit: 24);
    if (mounted) setState(() {});
  }

  Future<void> _load({bool reset = false, bool keepScroll = false}) async {
    final query = q;
    if (query == null) return;
    final gen = ++_gen;
    if (reset) {
      setState(() => loading = items.isEmpty || !keepScroll);
    }
    final repo = state.repo;
    final want = reset ? (keepScroll ? items.length.clamp(_page, 5000) : _page) : _page;
    final page = await repo.browse(query, limit: want, offset: reset ? 0 : items.length);
    final count = reset ? await repo.count(query) : total;
    if (!mounted || gen != _gen) return;
    setState(() {
      items = reset ? page : [...items, ...page];
      total = count;
      loading = false;
      if (isLive) {
        // Keep the selected channel up to date (♥ changes), or pick the first one.
        final cur = selected == null ? null : items.where((i) => i.key == selected!.key).firstOrNull;
        if (cur != null) {
          selected = cur;
        } else if (selected == null && items.isNotEmpty) {
          selected = items.first;
        }
      }
    });
    if (reset && !keepScroll && scroll.hasClients) scroll.jumpTo(0);
    _loadNowPlaying(page, merge: !reset);
  }

  Future<void> _loadNowPlaying(List<ItemView> list, {bool merge = false}) async {
    if (!isLive || _sourceId == null) return;
    final src = state.activeSource;
    if (src == null) return;
    final ids = {for (final i in list) if (i.epgId != null) i.epgId!}.toList();
    if (ids.isEmpty) return;
    final now = DateTime.now();
    final m = await state.repo.programmes(src.id, ids, now, now.add(const Duration(seconds: 1)),
        offsetMin: src.epgOffsetMin);
    if (!mounted) return;
    setState(() {
      if (!merge) nowPlaying = {};
      for (final e in m.entries) {
        final cur = e.value.where((p) => p.isLiveAt(now)).firstOrNull;
        if (cur != null) nowPlaying[e.key] = cur;
      }
    });
  }

  void _loadMore() {
    if (_loadingMore || items.length >= total) return;
    _loadingMore = true;
    _load().whenComplete(() => _loadingMore = false);
  }

  void _setQuery(BrowseQuery nq) {
    q = nq;
    _load(reset: true);
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () => _setQuery(q!.copyWith(search: v)));
  }

  List<SortMode> get _sortModes => isLive
      ? [SortMode.defaultOrder, SortMode.az, SortMode.za, SortMode.addedNewest, SortMode.addedOldest]
      : SortMode.values;

  Future<void> _setSort(SortMode m) async {
    await state.setPref(P.lastSort(type), m.key);
    _setQuery(q!.copyWith(sort: m));
  }

  Future<void> _removeRecent(ItemView it, ContentType type) => type == ContentType.movie
      ? state.repo.removeWatch(it.sourceId, 'movie', it.id)
      : state.repo.removeSeriesWatch(it.sourceId, it.id);

  Future<void> _toggleFav(ItemView it) async {
    await state.repo.toggleFavorite(it.sourceId, it.type, it.id);
  }

  void _open(ItemView it) {
    final pane = isLive && preview ? previewKey.currentState : null;
    if (pane != null) {
      pane.openFull(it);
    } else {
      openItem(context, it, channels: isLive ? items : null);
    }
  }

  void _select(ItemView it) {
    setState(() => selected = it);
    listFocus.requestFocus();
  }

  /// Arrow keys move the selection on Live TV, Return plays it.
  KeyEventResult _onKey(FocusNode _, KeyEvent e, int cols) {
    // On TV the remote moves focus between the real buttons instead (see tvMove).
    if (isTv || !isLive || guide || items.isEmpty || e is KeyUpEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    final i = selected == null ? -1 : items.indexWhere((x) => x.key == selected!.key);
    int? next;
    if (k == LogicalKeyboardKey.arrowDown) next = i + cols;
    if (k == LogicalKeyboardKey.arrowUp) next = i - cols;
    if (k == LogicalKeyboardKey.arrowRight) next = i + 1;
    if (k == LogicalKeyboardKey.arrowLeft) next = i - 1;
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      if (selected != null) _open(selected!);
      return KeyEventResult.handled;
    }
    if (next == null) return KeyEventResult.ignored;
    next = next.clamp(0, items.length - 1);
    setState(() => selected = items[next!]);
    if (next > items.length - 40) _loadMore();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = selectedKey.currentContext;
      if (c != null) Scrollable.ensureVisible(c, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
      final c2 = selectedKey.currentContext;
      if (c2 != null) Scrollable.ensureVisible(c2, alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
    });
    return KeyEventResult.handled;
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final src = state.activeSource;
    if (src == null || q == null) {
      return Column(children: [
        PageHeader(type.label),
        Expanded(
          child: EmptyState(
            icon: LucideIcons.listPlus,
            title: 'Add a playlist to start watching',
            message: 'Add an M3U playlist, Xtream Codes account or Stalker portal.',
            action: PrimaryButton(label: 'Add playlist', icon: LucideIcons.plus, onPressed: () => openAddSource(context)),
          ),
        ),
      ]);
    }
    final compact = context.compact;
    final side = (sidebar || isTv) && context.expanded;
    final guideOnly = !context.expanded;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (compact) _compactTop() else
      PageHeader(
        type.label,
        subtitle: '${src.name} · $total ${total == 1 ? typeNoun(type) : _noun}',
        trailing: [
          if (context.expanded) ...[
            if (!isTv)
          OutlineBox(
            onTap: () => setState(() => sidebar = !sidebar),
            selected: sidebar,
            padding: const EdgeInsets.symmetric(horizontal: 9),
            tooltip: sidebar ? 'Hide categories' : 'Show categories',
            child: const Icon(LucideIcons.panelLeft),
          ),
          ] else
            OutlineBox(
              onTap: _showCategorySheet,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(LucideIcons.listFilter),
                const SizedBox(width: 6),
                Text(_currentCategoryName()),
              ]),
            ),
          if (isLive) _liveModes(guideOnly),
          // On TV the sort and filter buttons live up here, next to the view switch.
          if (isTv) ..._filterButtons(),
        ],
      ),
      if (!isTv && (!side || chips.isNotEmpty)) _toolbar(),
      Expanded(
        child: Padding(
          padding: compact ? const EdgeInsets.fromLTRB(12, 0, 12, 4) : const EdgeInsets.fromLTRB(16, 0, 20, 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (side) _categories(),
            if (isLive && preview && !guideOnly) ...[
              // Channels in the middle, the preview window and its guide on the right.
              SizedBox(
                width: 400,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (!isTv) _titleBar(),
                  Expanded(child: Focus(focusNode: _contentNode, skipTraversal: true, canRequestFocus: false, child: _content(src))),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LivePreviewPane(
                  key: previewKey,
                  channel: selected,
                  onOpen: (c) => openPlayer(context, PlayRequest.live(c, channels: items)),
                ),
              ),
            ] else
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (!isTv) _titleBar(),
                  Expanded(
                    child: Focus(
                      focusNode: _contentNode,
                      skipTraversal: true,
                      canRequestFocus: false,
                      child: isLive && guide ? TvGuideView(query: q!) : _content(src),
                    ),
                  ),
                ]),
              ),
          ]),
        ),
      ),
    ]);
  }

  /// Channels / TV guide / Preview switch. Preview needs room, so small screens only get the first two.
  Widget _liveModes(bool guideOnly) {
    final mode = preview && !guideOnly ? 2 : (guide ? 1 : 0);
    return SizedBox(
      width: guideOnly ? 200 : 300,
      child: Segmented<int>(
        values: guideOnly ? const [0, 1] : const [0, 1, 2],
        labels: guideOnly ? const ['Channels', 'TV guide'] : const ['Channels', 'TV guide', 'Preview'],
        selected: mode,
        onChanged: (v) => setState(() {
          guide = v == 1;
          preview = v == 2;
        }),
      ),
    );
  }

  String _currentCategoryName() {
    final id = q?.categoryId;
    if (id == null) return 'All';
    return cats.where((x) => x.id == id).firstOrNull?.name ?? 'All';
  }

  /// Phones: the live-TV mode switch, search and the category picker, then the playlist and count.
  Widget _compactTop() {
    final p = context.pal;
    final src = state.activeSource!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (isLive) ...[
          Segmented<int>(
            values: const [0, 1],
            labels: const ['Channels', 'TV guide'],
            selected: guide ? 1 : 0,
            onChanged: (v) => setState(() {
              guide = v == 1;
              preview = false;
            }),
          ),
          const SizedBox(height: 10),
        ],
        Row(children: [
          Expanded(child: _searchField()),
          const SizedBox(width: 8),
          OutlineBox(
            onTap: _showCategorySheet,
            selected: q?.categoryId != null,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.listFilter),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 110),
                child: Text(_currentCategoryName(), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 6),
        Text('${src.name} · $total ${total == 1 ? typeNoun(type) : _noun}',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: p.ink3)),
      ]),
    );
  }

  /// Bottom sheet with the category list, for screens too narrow for the side column.
  void _showCategorySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.pal.raised,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: _categoryList(afterPick: () => Navigator.pop(sheet)),
        ),
      ),
    );
  }

  /// Search box, sort, favourites and replay filters. Shown at the top of the
  /// categories column, or in the toolbar when the column is hidden.
  Widget _searchField() {
    final p = context.pal;
    return SizedBox(
      height: isTouch ? 40 : 34,
      child: TvEditGate(child: TextField(
        controller: searchCtl,
        onChanged: (v) {
          setState(() {});
          _onSearch(v);
        },
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search ${isLive ? 'live TV' : _noun}',
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          prefixIcon: Icon(LucideIcons.search, color: p.ink2, size: 18),
          prefixIconConstraints: const BoxConstraints(minWidth: 34),
          suffixIcon: searchCtl.text.isEmpty
              ? null
              : IconBtn(LucideIcons.circleX, size: 15, color: p.ink3, tooltip: 'Clear', onTap: () {
                  searchCtl.clear();
                  setState(() {});
                  _setQuery(q!.copyWith(search: ''));
                }),
          suffixIconConstraints: const BoxConstraints(minWidth: 30),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: p.accent, width: 2)),
        ),
      )),
    );
  }

  List<Widget> _filterButtons() {
    final p = context.pal;
    final query = q!;
    return [
      PopupMenuButton<SortMode>(
        tooltip: 'Sort',
        position: PopupMenuPosition.under,
        onSelected: _setSort,
        itemBuilder: (_) => [
          for (final s in _sortModes)
            PopupMenuItem(
              value: s,
              height: 36,
              child: Row(children: [
                SizedBox(width: 22, child: s == query.sort ? Icon(LucideIcons.check, size: 17, color: p.accent) : null),
                const SizedBox(width: 6),
                Text(s.label),
              ]),
            ),
        ],
        child: IgnorePointer(
          child: OutlineBox(
            selected: query.sort != SortMode.defaultOrder,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(LucideIcons.arrowUpDown),
              const SizedBox(width: 5),
              Text(query.sort == SortMode.defaultOrder ? 'Sort' : _sortLabel(query.sort)),
            ]),
          ),
        ),
      ),
      OutlineBox(
        selected: query.favoritesOnly,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        tooltip: 'Favourites only',
        onTap: () => _setQuery(query.copyWith(favoritesOnly: !query.favoritesOnly)),
        child: query.favoritesOnly ? const FilledHeart(size: 20) : const Icon(LucideIcons.heart),
      ),
      if (isLive)
        OutlineBox(
          selected: query.archiveOnly,
          tooltip: 'Channels with replay (catch-up)',
          onTap: () => _setQuery(query.copyWith(archiveOnly: !query.archiveOnly)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.history), SizedBox(width: 5), Text('Replay')]),
        ),
    ];
  }

  /// Shown when the categories column is hidden (search and filters move here),
  /// or when the source has language chips.
  Widget _toolbar() {
    final p = context.pal;
    final query = q!;
    return Padding(
      padding: EdgeInsets.fromLTRB(context.compact ? 12 : 28, 0, context.compact ? 12 : 20, context.compact ? 8 : 14),
      child: SizedBox(
        height: isTouch ? 40 : 34,
        child: Row(children: [
          if (!(sidebar && context.expanded) && !context.compact) ...[
            SizedBox(width: 240, child: _searchField()),
            if (chips.isNotEmpty) Container(width: 0.8, height: 18, color: p.border, margin: const EdgeInsets.symmetric(horizontal: 10)),
          ],
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final (code, n) in chips) ...[
                  OutlineBox(
                    selected: query.lang == code,
                    tooltip: '$n $_noun',
                    onTap: () => _setQuery(query.copyWith(lang: query.lang == code ? null : code)),
                    child: Text(code),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }

  String _sortLabel(SortMode s) => switch (s) {
        SortMode.az => 'A–Z',
        SortMode.za => 'Z–A',
        SortMode.defaultOrder => 'Sort',
        SortMode.addedNewest => 'Newest added',
        SortMode.addedOldest => 'Oldest added',
        SortMode.releaseNewest => 'Newest release',
        SortMode.releaseOldest => 'Oldest release',
        SortMode.ratingHighest => 'Highest rated',
        SortMode.ratingLowest => 'Lowest rated',
      };

  Widget _categories() {
    return Container(
      width: isTv ? 280 : 230,
      margin: const EdgeInsets.only(right: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!isTv) ...[_searchField(), const SizedBox(height: 10)],
        Expanded(child: _categoryList()),
      ]),
    );
  }

  Widget _categoryList({VoidCallback? afterPick}) {
    final p = context.pal;
    final query = q!;
    final groups = cats.where((c) => c.isGroup).toList();
    final normal = cats.where((c) => !c.isGroup).toList();
    final allCount = counts.entries.where((e) => !e.key.startsWith('group:')).fold<int>(0, (a, e) => a + e.value);
    final touch = isTouch;

    Widget row(String? id, String name, {int? count, IconData? icon}) {
      final sel = query.categoryId == id;
      return Pressable(
        focusNode: isTv ? (_railNodes[id ?? ''] ??= FocusNode()) : null,
        onFocusChange: isTv ? (f) { if (f) _tvPick(id); } : null,
        onTap: () {
          _pickTimer?.cancel();
          _setQuery(query.copyWith(categoryId: id));
          afterPick?.call();
          // OK on a category: go to its titles.
          if (isTv) tvMove(TraversalDirection.right);
        },
        radius: 8,
        child: Container(
          constraints: BoxConstraints(minHeight: touch ? 46 : (isTv ? 44 : 32)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: sel ? p.sel : null, borderRadius: BorderRadius.circular(8)),
          child: Row(children: [
            if (icon != null) ...[Icon(icon, size: 15, color: sel ? p.ink : p.ink2), const SizedBox(width: 7)],
            Expanded(
              child: Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: touch ? 15 : (isTv ? 16 : 13), height: 1.25, color: sel ? p.ink : p.ink2, fontWeight: sel ? FontWeight.w600 : FontWeight.w500)),
            ),
            if (count != null) Text('$count', style: TextStyle(fontSize: 11.5, color: p.ink3)),
          ]),
        ),
      );
    }

    Widget heading(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 14, 10, 4),
          child: Text(t, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: p.ink3)),
        );

    return ListView(padding: const EdgeInsets.only(bottom: 30), children: [
        row(null, 'All $_noun', count: allCount > 0 ? allCount : null),
        if (groups.isNotEmpty) ...[
          heading('Your groups'),
          for (final g in groups) row(g.id, g.name, count: counts[g.id], icon: LucideIcons.folder),
        ],
        heading('Categories'),
        if (normal.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text('No categories', style: TextStyle(color: p.ink3, fontSize: 13)),
          ),
        for (final c in normal) row(c.id, c.name, count: counts[c.id]),
        const SizedBox(height: 8),
        Pressable(
          onTap: () {
            afterPick?.call();
            showCategoryManager(context, query.sourceId, type);
          },
          radius: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(children: [
              Icon(LucideIcons.slidersHorizontal, size: 15, color: p.ink3),
              const SizedBox(width: 7),
              Text('Manage categories and groups', style: TextStyle(fontSize: 12.5, color: p.ink3)),
            ]),
          ),
        ),
      ]);
  }

  bool get _showHeader {
    final query = q!;
    return query.categoryId == null &&
        query.search.isEmpty &&
        query.lang == null &&
        !query.favoritesOnly &&
        !query.archiveOnly;
  }

  Widget _content(Source src) {
    final p = context.pal;
    final status = state.catalog.progress.value[src.id];
    return ValueListenableBuilder(
      valueListenable: state.catalog.progress,
      builder: (context, prog, _) {
        final refreshing = prog[src.id];
        if (items.isEmpty && !loading) {
          if (refreshing != null) {
            return EmptyState(
              icon: LucideIcons.download,
              title: refreshing.stage,
              message: 'Loading "${src.name}". Large playlists can take a minute.',
              action: SizedBox(width: 260, child: ThinBar(refreshing.fraction ?? 0, height: 4)),
            );
          }
          return FutureBuilder(
            future: Future.wait([
              state.repo.status(src.id),
              state.repo.hiddenIds(src.id, type, 'category'),
            ]),
            builder: (context, snap) {
              final err = (snap.data?[0] as SourceStatusRow?)?.lastError;
              final hiddenCats = (snap.data?[1] as List<String>?)?.length ?? 0;
              final query = q!;
              final filtered = query.search.isNotEmpty || query.favoritesOnly || query.lang != null ||
                  query.categoryId != null || query.archiveOnly;
              if (err != null && total == 0 && !filtered) {
                return EmptyState(
                  icon: LucideIcons.cloudOff,
                  title: 'Could not load $_noun',
                  message: err,
                  action: Row(mainAxisSize: MainAxisSize.min, children: [
                    GhostButton(label: 'Edit playlist', icon: LucideIcons.pencil, onPressed: () => openAddSource(context, edit: src)),
                    const SizedBox(width: 10),
                    PrimaryButton(label: 'Retry', icon: LucideIcons.rotateCcw, onPressed: () => state.catalog.refresh(src)),
                  ]),
                );
              }
              if (!filtered && hiddenCats > 0) {
                return EmptyState(
                  icon: LucideIcons.eyeOff,
                  title: 'Everything here is in hidden categories',
                  message: '$hiddenCats hidden ${hiddenCats == 1 ? 'category' : 'categories'}.',
                  action: GhostButton(
                      label: 'Manage categories',
                      icon: LucideIcons.slidersHorizontal,
                      onPressed: () => showCategoryManager(context, src.id, type)),
                );
              }
              return EmptyState(
                icon: query.favoritesOnly ? LucideIcons.heart : LucideIcons.search,
                title: query.favoritesOnly
                    ? 'No favourites in this category'
                    : filtered
                        ? 'No results'
                        : 'No $_noun in this playlist',
                message: query.favoritesOnly ? 'Click ♥ on any ${typeNoun(type)} to add it here.' : null,
              );
            },
          );
        }
        return Stack(children: [
          NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.axis == Axis.vertical && n.metrics.pixels > n.metrics.maxScrollExtent - 1200) _loadMore();
              return false;
            },
            child: LayoutBuilder(builder: (context, c) {
              final cols = isTv && isLive ? 1 : (isLive ? ((c.maxWidth - 8) / 360).floor().clamp(1, 6) : _posterCols(c.maxWidth));
              return Focus(
                focusNode: listFocus,
                onKeyEvent: (n, e) => _onKey(n, e, cols),
                child: CustomScrollView(
                  controller: scroll,
                  slivers: [
                    if (_showHeader) ..._headerSlivers(c.maxWidth),
                    if (_showHeader && !isLive) const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    _grid(c.maxWidth, cols),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
              );
            }),
          ),
          if (loading) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 2)),
          if (status != null && items.isNotEmpty)
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: p.raised,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 14, offset: Offset(0, 4))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: p.ink2)),
                  const SizedBox(width: 10),
                  Text(status.stage, style: TextStyle(fontSize: 12.5, color: p.ink)),
                ]),
              ),
            ),
        ]);
      },
    );
  }

  /// Fixed line above the list: what is shown and how many, with sort and filters on the right.
  Widget _titleBar() {
    final p = context.pal;
    if (!context.expanded) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SizedBox(
          height: isTouch ? 40 : 34,
          child: ListView(scrollDirection: Axis.horizontal, children: [
            for (final b in _filterButtons()) ...[b, const SizedBox(width: 8)],
          ]),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(isLive ? 8 : 12, 0, 8, 12),
      child: SizedBox(
        height: 34,
        child: Row(children: [
          // The title takes all free width so the buttons end flush with the right edge.
          Expanded(
            child: Row(children: [
              Flexible(
                child: Text(_gridTitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
              ),
              const SizedBox(width: 10),
              Text(total == items.length || items.isEmpty ? '$total' : '${items.length} of $total',
                  style: TextStyle(fontSize: 12.5, color: p.ink3)),
            ]),
          ),
          for (final b in _filterButtons()) ...[const SizedBox(width: 8), b],
        ]),
      ),
    );
  }

  String _gridTitle() {
    final query = q!;
    if (query.search.isNotEmpty) return 'Results for "${query.search}"';
    if (query.categoryId != null) {
      return cats.where((x) => x.id == query.categoryId).firstOrNull?.name ?? type.label;
    }
    if (query.favoritesOnly) return 'Favourite $_noun';
    return 'All $_noun';
  }

  List<Widget> _headerSlivers(double width) {
    // A remote gets one list: Home already shows Continue watching and Recently watched.
    if (isTv) return [];
    if (isLive) {
      if (recents.isEmpty) return [];
      return [
        const SliverToBoxAdapter(child: ShelfTitle('Recently watched', padding: EdgeInsets.fromLTRB(8, 0, 8, 10))),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 82,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: recents.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final r = recents[i];
                return LogoTile(
                  icon: r.icon,
                  label: r.name,
                  onTap: () async {
                    final it = await state.repo.item(r.sourceId, ContentType.live, r.itemId);
                    if (it != null && mounted) _open(it);
                  },
                  onRemove: () => state.repo.removeWatch(r.sourceId, 'live', r.itemId),
                  onMenu: (pos) async {
                    final it = await state.repo.item(r.sourceId, ContentType.live, r.itemId);
                    if (it == null || !mounted) return;
                    await showItemMenu(context, it, pos,
                        onOpen: () => _open(it),
                        onRemoveRecent: () => state.repo.removeWatch(r.sourceId, 'live', r.itemId));
                  },
                );
              },
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
      ];
    }
    final out = <Widget>[];
    final hero = resumeItems.where((i) => resumeRows[i.id] != null).firstOrNull;
    if (hero != null) {
      out.add(SliverToBoxAdapter(
        child: HeroBanner(
            item: hero, watch: resumeRows[hero.id]!, padding: const EdgeInsets.fromLTRB(12, 0, 12, 4)),
      ));
    }
    if (resumeItems.isNotEmpty) {
      out.add(const SliverToBoxAdapter(child: ShelfTitle('Continue watching', padding: EdgeInsets.fromLTRB(12, 24, 12, 10))));
      out.add(_shelf(resumeItems, resume: true));
    }
    if (newest.isNotEmpty) {
      out.add(const SliverToBoxAdapter(child: ShelfTitle('Recently added', padding: EdgeInsets.fromLTRB(12, 24, 12, 10))));
      out.add(_shelf(newest));
    }
    return out;
  }

  Widget _shelf(List<ItemView> list, {bool resume = false}) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: _shelfW * 1.5 + PosterCard.captionHeight + 16,
        child: ListView.separated(
          // Room for the hover zoom and shadow.
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          clipBehavior: Clip.none,
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(width: 18),
          itemBuilder: (_, i) {
            final it = list[i];
            final w = resumeRows[it.id];
            final frac = resume && w != null && w.durationMs > 0 ? w.positionMs / w.durationMs : null;
            final caption = resume && type == ContentType.series && w?.season != null
                ? '${it.name} · S${w!.season} E${w.episode}'
                : null;
            return SizedBox(
              width: _shelfW,
              child: PosterCard(
                item: it,
                progress: frac,
                caption: caption,
                onTap: () => _open(it),
                onFavorite: () => _toggleFav(it),
                onRemove: resume ? () => _removeRecent(it, type) : null,
                onMenu: (pos) => showItemMenu(context, it, pos,
                    onOpen: () => _open(it),
                    openLabel: 'Show details',
                    onRemoveRecent: resume ? () => _removeRecent(it, type) : null),
              ),
            );
          },
        ),
      ),
    );
  }

  int _posterCols(double width) => ((width - 24) / (context.compact ? 112 : (isTv ? 160 : 168))).floor().clamp(2, 12);

  Widget _grid(double width, int cols) {
    if (isLive) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisExtent: isTv ? 68 : 64,
            crossAxisSpacing: 8,
            mainAxisSpacing: 4,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final it = items[i];
              final sel = selected?.key == it.key;
              return ChannelCard(
                key: sel ? selectedKey : ValueKey(it.key),
                item: it,
                selected: sel,
                now: it.epgId == null ? null : nowPlaying[it.epgId],
                onTap: () => isTv ? _open(it) : _select(it),
                onDoubleTap: () => _open(it),
                onPlay: () => _open(it),
                onFavorite: () => _toggleFav(it),
                onMenu: (pos) => showItemMenu(context, it, pos,
                    onOpen: () => _open(it), onGuide: () => openGuide(context, it)),
              );
            },
            childCount: items.length,
          ),
        ),
      );
    }
    final cardW = (width - 24 - (cols - 1) * (context.compact ? 10 : 18)) / cols;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisExtent: cardW * 1.5 + PosterCard.captionHeight,
          crossAxisSpacing: context.compact ? 10 : 18,
          mainAxisSpacing: 20,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final it = items[i];
            return PosterCard(
              key: ValueKey(it.key),
              item: it,
              onTap: () => _open(it),
              onFavorite: () => _toggleFav(it),
              onMenu: (pos) =>
                  showItemMenu(context, it, pos, onOpen: () => _open(it), openLabel: 'Show details'),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

