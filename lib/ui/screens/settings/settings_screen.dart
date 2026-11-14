import '../../../core/platform.dart';
import '../../../core/updates.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/net.dart';
import '../../../data/database/schema.dart';
import '../../../data/repository.dart';
import '../../../data/services/secrets.dart';
import '../../../data/sources/models.dart';
import '../../../state/app_state.dart';
import '../../navigation.dart';
import '../../theme.dart';
import '../../widgets.dart';
import '../../refresh_button.dart';
import '../../account_info.dart';
import '../category_manager.dart';
import 'sync_settings.dart';

enum _Section { sources, appearance, sync, customization, content, player, subtitles, metadata, about }

extension on _Section {
  (String, IconData) get meta => switch (this) {
        _Section.sources => ('Manage playlists', LucideIcons.listVideo),
        _Section.appearance => ('Start screen', LucideIcons.sunMoon),
        _Section.sync => ('Sync', LucideIcons.refreshCw),
        _Section.customization => ('Customization', LucideIcons.slidersHorizontal),
        _Section.content => ('Content', LucideIcons.library),
        _Section.player => ('Video player', LucideIcons.monitorPlay),
        _Section.subtitles => ('Subtitles', LucideIcons.subtitles),
        _Section.metadata => ('Metadata & skipping', LucideIcons.fastForward),
        _Section.about => ('About', LucideIcons.info),
      };
}

/// The Menu tab: settings list on the left, the selected pane on the right.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  _Section section = _Section.sources;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    // Narrow screens: a list of sections; each opens as its own page.
    if (MediaQuery.sizeOf(context).width < 720) {
      return ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
        for (final s in _Section.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: SidebarItem(
              icon: s.meta.$2,
              label: s.meta.$1,
              active: false,
              onTap: () => Navigator.of(context).push(fadeRoute(_SectionPage(section: s, pane: _paneFor(s)))),
            ),
          ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const PageHeader('Settings'),
      Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 240,
            margin: const EdgeInsets.fromLTRB(20, 0, 0, 24),
            child: ListView(children: [
              for (final s in _Section.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: SidebarItem(
                    icon: s.meta.$2,
                    label: s.meta.$1,
                    active: s == section,
                    onTap: () => setState(() => section = s),
                  ),
                ),
            ]),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 24, 0),
              constraints: const BoxConstraints(maxWidth: 820),
              alignment: Alignment.topLeft,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: p.ink),
                child: KeyedSubtree(key: ValueKey(section), child: _pane()),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _pane() => _paneFor(section);

  static Widget _paneFor(_Section section) => switch (section) {
        _Section.sources => const _SourcesPane(),
        _Section.appearance => const _AppearancePane(),
        _Section.sync => const SyncSettingsPane(),
        _Section.customization => const _CustomizationPane(),
        _Section.content => const _ContentPane(),
        _Section.player => const _PlayerPane(),
        _Section.subtitles => const _SubtitlesPane(),
        _Section.metadata => const _MetadataPane(),
        _Section.about => const _AboutPane(),
      };
}

/// One settings section on its own page (phones and narrow windows).
class _SectionPage extends StatelessWidget {
  const _SectionPage({required this.section, required this.pane});
  final _Section section;
  final Widget pane;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
            child: Row(children: [
              IconBtn(LucideIcons.chevronLeft, size: 24, color: p.ink, tooltip: 'Back', onTap: () => Navigator.of(context).maybePop()),
              const SizedBox(width: 4),
              Expanded(
                child: Text(section.meta.$1,
                    maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DefaultTextStyle.merge(style: TextStyle(color: p.ink), child: pane),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

/// TV: what to do with a playlist, as one list the remote can walk.
Future<void> _tvPlaylistMenu(BuildContext context, AppState state, Source s) {
  Widget option(BuildContext ctx, IconData icon, String label, VoidCallback run) => SimpleDialogOption(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        onPressed: () {
          Navigator.of(ctx).pop();
          run();
        },
        child: Row(children: [Icon(icon, size: 20), const SizedBox(width: 14), Text(label, style: const TextStyle(fontSize: 17))]),
      );
  return showDialog<void>(
    context: context,
    builder: (ctx) => SimpleDialog(
      title: Text(s.name),
      children: [
        if (s.id != state.activeSource?.id)
          option(ctx, LucideIcons.circleCheck, 'Use this playlist', () => state.selectSource(s.id)),
        option(ctx, LucideIcons.rotateCw, 'Refresh now', () => state.catalog.refresh(s)),
        option(ctx, LucideIcons.pencil, 'Edit', () => openAddSource(context, edit: s)),
        option(ctx, LucideIcons.settings, 'Playlist settings',
            () => Navigator.of(context).push(fadeRoute(_SourceSettingsPage(source: s)))),
        option(ctx, LucideIcons.trash2, 'Delete', () => confirmDeletePlaylist(context, state, s)),
      ],
    ),
  );
}

class _SourcesPane extends StatelessWidget {
  const _SourcesPane();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ListView(children: [
      PaneSection('Playlists', children: [
        for (final s in state.sources)
          SettingsRow(
            icon: s.id == state.activeSource?.id ? LucideIcons.circleCheck : LucideIcons.circle,
            title: s.name,
            subtitle: SourceKind.of(s.kind).label,
            // A remote gets one stop per playlist; OK opens its actions.
            trailing: isTv ? null : Row(mainAxisSize: MainAxisSize.min, children: [
              RefreshButton(source: s),
              IconBtn(LucideIcons.pencil,
                  size: 18,
                  color: context.pal.ink2,
                  tooltip: 'Edit "${s.name}"',
                  onTap: () => openAddSource(context, edit: s)),
              IconBtn(LucideIcons.trash2,
                  size: 18,
                  color: context.pal.ink2,
                  tooltip: 'Delete "${s.name}"',
                  onTap: () => confirmDeletePlaylist(context, state, s)),
            ]),
            chevron: true,
            onTap: isTv
                ? () => _tvPlaylistMenu(context, state, s)
                : () => Navigator.of(context).push(fadeRoute(_SourceSettingsPage(source: s))),
          ),
        SettingsRow(icon: LucideIcons.circlePlus, title: 'Add playlist', onTap: () => openAddSource(context)),
      ]),
    ]);
  }
}

/// Per-source refresh/EPG settings.
class _SourceSettingsPage extends StatefulWidget {
  const _SourceSettingsPage({required this.source});
  final Source source;
  @override
  State<_SourceSettingsPage> createState() => _SourceSettingsPageState();
}

class _SourceSettingsPageState extends State<_SourceSettingsPage> {
  late Source s = widget.source;
  SourceStatusRow? st;
  late final AppState state = AppScope.read(context);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final fresh = await state.repo.source(s.id);
    final status = await state.repo.status(s.id);
    if (!mounted) return;
    setState(() {
      if (fresh != null) s = fresh;
      st = status;
    });
  }

  String _hours(int h) => h == 0 ? 'Manual only' : (h % 24 == 0 ? 'Every ${h ~/ 24} day(s)' : 'Every $h hours');

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(windowButtonsInset, 10, 16, 6),
            child: Row(children: [
              IconBtn(LucideIcons.arrowLeft, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 8),
              Expanded(child: Text(s.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
            ]),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView(children: [
                  PaneSection('Playlist', children: [
                    SettingsRow(
                        icon: LucideIcons.pencil,
                        title: 'Edit connection',
                        onTap: () async {
                          await openAddSource(context, edit: s);
                          await _reload();
                        }),
                    ValueListenableBuilder(
                      valueListenable: state.catalog.progress,
                      builder: (context, prog, _) {
                        final busy = prog.containsKey(s.id) || state.catalog.isRefreshing(s.id);
                        return SettingsRow(
                          icon: LucideIcons.refreshCw,
                          title: busy ? 'Updating…' : 'Fetch updates now',
                          subtitle: busy
                              ? (prog[s.id]?.stage ?? 'Working…')
                              : st == null || st!.lastRefresh == 0
                                  ? (st?.lastError ?? 'Never loaded')
                                  : 'Last updated ${fmtStamp(DateTime.fromMillisecondsSinceEpoch(st!.lastRefresh))}'
                                      '${st!.lastError != null ? ' · last attempt failed: ${st!.lastError}' : ''}',
                          chevron: false,
                          trailing: busy ? RefreshButton(source: s) : null,
                          onTap: busy
                              ? null
                              : () async {
                                  await refreshPlaylist(
                                      state, s, ScaffoldMessenger.maybeOf(context), context.pal.onPill);
                                  await _reload();
                                },
                        );
                      },
                    ),
                    SettingsRow(
                      icon: LucideIcons.rotateCw,
                      title: 'Automatic update',
                      subtitle: _hours(s.refreshHours),
                      onTap: () async {
                        final v = await pickOption<int>(context,
                            title: 'Update content automatically',
                            current: s.refreshHours,
                            options: [for (final h in [0, 6, 12, 24, 48, 168]) (h, _hours(h))]);
                        if (v == null) return;
                        await state.repo.updateSourceSettings(s.id, refreshHours: v);
                        await _reload();
                      },
                    ),
                  ]),
                  _AccountSection(source: s, status: st),
                  PaneSection('TV guide (EPG)', children: [
                    FutureBuilder<int>(
                      future: state.repo.guideCoverage(s.id),
                      builder: (context, snap) {
                        final total = st?.liveCount ?? 0;
                        final have = snap.data;
                        return SettingsRow(
                          icon: LucideIcons.chartNoAxesColumn,
                          title: 'Guide coverage',
                          subtitle: !s.epgEnabled
                              ? 'The TV guide is turned off for this playlist.'
                              : have == null
                                  ? 'Checking…'
                                  : '$have of $total live channels have programme data. '
                                      '${st?.lastEpgRefresh == null || st!.lastEpgRefresh == 0 ? 'Guide not loaded yet.' : 'Guide loaded ${fmtStamp(DateTime.fromMillisecondsSinceEpoch(st!.lastEpgRefresh))}.'}',
                          chevron: false,
                        );
                      },
                    ),
                    SettingsSwitch(
                      icon: LucideIcons.listVideo,
                      title: 'Load TV guide',
                      value: s.epgEnabled,
                      onChanged: (v) async {
                        await state.repo.updateSourceSettings(s.id, epgEnabled: v);
                        await _reload();
                      },
                    ),
                    SettingsRow(
                      icon: LucideIcons.link,
                      title: 'Guide URL',
                      subtitle: s.epgUrl ?? 'From the provider (XMLTV link in the playlist / Xtream xmltv.php)',
                      onTap: () async {
                        final v = await promptText(context,
                            title: 'XMLTV guide URL', initial: s.epgUrl, label: 'URL (empty = provider default)');
                        if (v == null) {
                          await state.repo.updateSourceSettings(s.id, clearEpgUrl: true);
                        } else {
                          await state.repo.updateSourceSettings(s.id, epgUrl: v);
                        }
                        await _reload();
                      },
                    ),
                    SettingsRow(
                      icon: LucideIcons.rotateCw,
                      title: 'Guide update',
                      subtitle: _hours(s.epgRefreshHours),
                      onTap: () async {
                        final v = await pickOption<int>(context,
                            title: 'Update guide automatically',
                            current: s.epgRefreshHours,
                            options: [for (final h in [0, 6, 12, 24, 48]) (h, _hours(h))]);
                        if (v == null) return;
                        await state.repo.updateSourceSettings(s.id, epgRefreshHours: v);
                        await _reload();
                      },
                    ),
                    SettingsRow(
                      icon: LucideIcons.clock,
                      title: 'Time offset',
                      subtitle: s.epgOffsetMin == 0 ? 'None' : '${s.epgOffsetMin > 0 ? '+' : ''}${s.epgOffsetMin ~/ 60}h ${(s.epgOffsetMin % 60).abs()}m',
                      onTap: () async {
                        final v = await pickOption<int>(context,
                            title: 'Shift guide times',
                            current: s.epgOffsetMin,
                            options: [for (var h = -12; h <= 12; h++) (h * 60, h == 0 ? 'None' : '${h > 0 ? '+' : ''}$h hours')]);
                        if (v == null) return;
                        await state.repo.updateSourceSettings(s.id, epgOffsetMin: v);
                        await _reload();
                      },
                    ),
                    SettingsRow(
                      icon: LucideIcons.rotateCcw,
                      title: 'Refresh guide now',
                      subtitle: st == null || st!.lastEpgRefresh == 0
                          ? (st?.epgError ?? 'Never loaded')
                          : '${st!.epgProgrammes} programmes · ${fmtDateTime(DateTime.fromMillisecondsSinceEpoch(st!.lastEpgRefresh))}'
                              '${st!.epgError != null ? ' · ${st!.epgError}' : ''}',
                      onTap: () async {
                        final e = await state.catalog.refreshEpg(s);
                        if (context.mounted) toast(context, e ?? 'TV guide updated.', error: e != null);
                        await _reload();
                      },
                    ),
                  ]),
                  PaneSection('Danger zone', children: [
                    SettingsRow(
                      icon: LucideIcons.trash2,
                      title: 'Delete playlist',
                      danger: true,
                      onTap: () async {
                        if (await confirmDeletePlaylist(context, state, s) && context.mounted) Navigator.pop(context);
                      },
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Playlist id: ${s.id}', style: TextStyle(color: p.ink3, fontSize: 12)),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _AppearancePane extends StatelessWidget {
  const _AppearancePane();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final start = state.str(P.startTab, 'live');
    return ListView(children: [
      PaneSection('Start screen', children: [
        for (final t in [MainTab.live, MainTab.series, MainTab.movies, MainTab.home])
          SettingsRow(
            title: t.label,
            onTap: () => state.setPref(P.startTab, t.name),
            trailing: CheckMark(start == t.name),
          ),
      ]),
    ]);
  }
}

// ---------------------------------------------------------------------------

class _CustomizationPane extends StatelessWidget {
  const _CustomizationPane();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final src = state.activeSource;
    return ListView(children: [
      for (final t in ContentType.values)
        PaneSection(t == ContentType.live ? 'Live TV' : t.label, children: [
          SettingsSwitch(
            title: 'Favourites first',
            subtitle: 'Show favourites at the top of every category',
            value: state.flag(P.favFirst(t)),
            onChanged: (v) => state.setPref(P.favFirst(t), v),
          ),
          SettingsSwitch(
            title: t == ContentType.live ? 'Recently watched row' : 'Resume / New row',
            value: state.flag(P.recents(t), true),
            onChanged: (v) => state.setPref(P.recents(t), v),
          ),
          SettingsRow(
            title: 'Default sorting',
            subtitle: state.str(P.defaultSort(t), 'remember') == 'remember'
                ? 'Remember last used'
                : SortMode.of(state.str(P.defaultSort(t))).label,
            onTap: () async {
              final v = await pickOption<String>(context,
                  title: 'Default sorting',
                  current: state.str(P.defaultSort(t), 'remember'),
                  options: [
                    ('remember', 'Remember last used'),
                    for (final s in SortMode.values) (s.key, s.label),
                  ]);
              if (v != null) await state.setPref(P.defaultSort(t), v);
            },
          ),
          if (src != null)
            FutureBuilder<Map<String, String>>(
              future: state.repo.categoryNames(src.id, t),
              builder: (context, snap) {
                final names = snap.data ?? const {};
                final cur = state.str(P.defaultCat(t));
                return SettingsRow(
                  title: 'Default category',
                  subtitle: cur.isEmpty ? 'All' : (names[cur] ?? cur),
                  onTap: () async {
                    final cats = await state.repo.categories(src.id, t);
                    if (!context.mounted) return;
                    final v = await pickOption<String>(context,
                        title: 'Default category',
                        current: cur,
                        options: [('', 'All'), for (final c in cats) (c.id, c.name)]);
                    if (v != null) await state.setPref(P.defaultCat(t), v);
                  },
                );
              },
            ),
          if (t == ContentType.live)
            SettingsSwitch(
              title: 'Open TV guide grid by default',
              value: state.flag(P.liveEpgGrid),
              onChanged: (v) => state.setPref(P.liveEpgGrid, v),
            ),
        ]),
    ]);
  }
}

// ---------------------------------------------------------------------------

class _ContentPane extends StatelessWidget {
  const _ContentPane();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final src = state.activeSource;
    if (src == null) return const EmptyState(icon: LucideIcons.listPlus, title: 'Add a playlist first');
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text('For "${src.name}"', style: TextStyle(color: context.pal.ink2)),
      ),
      for (final t in ContentType.values)
        PaneSection(t == ContentType.live ? 'Live TV' : t.label, children: [
          SettingsRow(
            icon: LucideIcons.listOrdered,
            title: 'Categories & groups',
            subtitle: 'Reorder, hide, create groups',
            onTap: () => showCategoryManager(context, src.id, t),
          ),
          SettingsRow(
            icon: LucideIcons.heart,
            title: 'Reorder favourites',
            onTap: () => showDialog(context: context, builder: (_) => FavoritesOrderDialog(sourceId: src.id, type: t)),
          ),
          SettingsRow(
            icon: LucideIcons.eyeOff,
            title: 'Hidden ${t == ContentType.live ? 'channels' : t.label.toLowerCase()}',
            onTap: () => showDialog(context: context, builder: (_) => _HiddenItems(sourceId: src.id, type: t)),
          ),
          SettingsRow(
            icon: LucideIcons.history,
            title: 'Clear watch history',
            danger: true,
            onTap: () async {
              if (!await confirm(context,
                  title: 'Clear ${t.label} history?',
                  message: 'Recently watched and resume positions for ${t.label.toLowerCase()} are removed on all synced devices.',
                  action: 'Clear')) {
                return;
              }
              await state.repo.clearHistory(src.id, type: t);
              if (context.mounted) toast(context, 'History cleared.');
            },
          ),
        ]),
    ]);
  }
}

class FavoritesOrderDialog extends StatefulWidget {
  const FavoritesOrderDialog({super.key, required this.sourceId, required this.type});
  final String sourceId;
  final ContentType type;
  @override
  State<FavoritesOrderDialog> createState() => _FavoritesOrderDialogState();
}

class _FavoritesOrderDialogState extends State<FavoritesOrderDialog> {
  late final AppState state = AppScope.read(context);
  List<ItemView>? items;

  @override
  void initState() {
    super.initState();
    () async {
      final ids = await state.repo.favoriteIds(widget.sourceId, widget.type);
      final it = await state.repo.itemsByIds(widget.sourceId, widget.type, ids);
      if (mounted) setState(() => items = it);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return AlertDialog(
      title: Text('Favorite ${widget.type == ContentType.live ? 'channels' : widget.type.label.toLowerCase()}'),
      content: SizedBox(
        width: 460,
        height: 520,
        child: items == null
            ? const Center(child: CircularProgressIndicator())
            : items!.isEmpty
                ? const EmptyState(icon: LucideIcons.heart, title: 'No favourites yet')
                : ReorderableListView.builder(
                    itemCount: items!.length,
                    onReorderItem: (a, b) async {
                      setState(() => items!.insert(b, items!.removeAt(a)));
                      await state.repo.reorderFavorites(widget.sourceId, widget.type, [for (final i in items!) i.id]);
                    },
                    itemBuilder: (_, i) => ListTile(
                      key: ValueKey(items![i].id),
                      dense: true,
                      leading: SizedBox(width: 44, height: 30, child: NetImage(items![i].icon, fit: BoxFit.contain)),
                      title: Text(items![i].name, style: TextStyle(color: p.ink)),
                    ),
                  ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
    );
  }
}

class _HiddenItems extends StatefulWidget {
  const _HiddenItems({required this.sourceId, required this.type});
  final String sourceId;
  final ContentType type;
  @override
  State<_HiddenItems> createState() => _HiddenItemsState();
}

class _HiddenItemsState extends State<_HiddenItems> {
  late final AppState state = AppScope.read(context);
  List<ItemView>? items;
  List<CategoryView> cats = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await state.repo.hiddenIds(widget.sourceId, widget.type, 'item');
    final it = await state.repo.itemsByIds(widget.sourceId, widget.type, ids);
    final c = (await state.repo.categories(widget.sourceId, widget.type, includeHidden: true))
        .where((c) => c.hidden)
        .toList();
    if (mounted) {
      setState(() {
        items = it;
        cats = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hidden'),
      content: SizedBox(
        width: 460,
        height: 520,
        child: items == null
            ? const Center(child: CircularProgressIndicator())
            : items!.isEmpty && cats.isEmpty
                ? const EmptyState(icon: LucideIcons.eye, title: 'Nothing is hidden')
                : ListView(children: [
                    for (final c in cats)
                      ListTile(
                        dense: true,
                        leading: const Icon(LucideIcons.folder),
                        title: Text('${c.name} (category)'),
                        trailing: TextButton(
                          child: const Text('Show'),
                          onPressed: () async {
                            await state.repo.setHidden(widget.sourceId, widget.type, 'category', c.id, false);
                            await _load();
                          },
                        ),
                      ),
                    for (final it in items!)
                      ListTile(
                        dense: true,
                        leading: SizedBox(width: 44, height: 30, child: NetImage(it.icon, fit: BoxFit.contain)),
                        title: Text(it.name),
                        trailing: TextButton(
                          child: const Text('Show'),
                          onPressed: () async {
                            await state.repo.setHidden(widget.sourceId, widget.type, 'item', it.id, false);
                            await _load();
                          },
                        ),
                      ),
                  ]),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
    );
  }
}

// ---------------------------------------------------------------------------

class _PlayerPane extends StatelessWidget {
  const _PlayerPane();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final skip = state.integer(P.skipSeconds, 10);
    final margin = state.integer(P.tvMargin, 5);
    return ListView(children: [
      if (isTv)
        PaneSection('TV screen', children: [
          SettingsRow(
            title: 'Screen margin',
            subtitle: '$margin% on each edge. Raise it if the menu bar is cut off by your TV.',
            onTap: () async {
              final v = await pickOption<int>(context,
                  title: 'Screen margin', current: margin, options: [for (final m in [0, 2, 3, 4, 5, 6, 8, 10, 12]) (m, m == 0 ? 'None' : '$m%')]);
              if (v != null) await state.setPref(P.tvMargin, v);
            },
          ),
        ]),
      PaneSection('Playback', children: [
        SettingsSwitch(
          title: 'Open player in full screen',
          value: state.flag(P.fullscreenOnOpen),
          onChanged: (v) => state.setPref(P.fullscreenOnOpen, v),
        ),
        SettingsSwitch(
          title: 'Show controls when the mouse moves',
          value: state.flag(P.controlsOnMove, true),
          onChanged: (v) => state.setPref(P.controlsOnMove, v),
        ),
        SettingsSwitch(
          title: 'Remember volume',
          value: state.flag(P.rememberVolume, true),
          onChanged: (v) => state.setPref(P.rememberVolume, v),
        ),
        SettingsRow(
          title: 'Seek step',
          subtitle: '$skip seconds (← / → keys)',
          onTap: () async {
            final v = await pickOption<int>(context,
                title: 'Seek step', current: skip, options: [for (final s in [5, 10, 15, 30, 60]) (s, '$s seconds')]);
            if (v != null) await state.setPref(P.skipSeconds, v);
          },
        ),
        SettingsRow(
          title: 'Preferred audio language',
          subtitle: state.str(P.audioLang).isEmpty ? 'Stream default' : state.str(P.audioLang),
          onTap: () async {
            final v = await pickOption<String>(context,
                title: 'Preferred audio language', current: state.str(P.audioLang), options: _languages(none: 'Stream default'));
            if (v != null) await state.setPref(P.audioLang, v);
          },
        ),
      ]),
      PaneSection('Series', children: [
        SettingsSwitch(
          title: 'Play next episode automatically',
          value: state.flag(P.autoplayNext, true),
          onChanged: (v) => state.setPref(P.autoplayNext, v),
        ),
      ]),
      PaneSection('Network', children: [
        SettingsRow(
          title: 'User agent',
          subtitle: state.userAgent,
          onTap: () async {
            final v = await promptText(context,
                title: 'User agent', initial: state.str(P.userAgent), label: 'Empty = $kDefaultUserAgent');
            await state.setPref(P.userAgent, v ?? '');
          },
        ),
      ]),
    ]);
  }
}

List<(String, String)> _languages({String none = 'Off'}) => [
      ('', none),
      for (final (c, n) in const [
        ('en', 'English'), ('fr', 'French'), ('de', 'German'), ('es', 'Spanish'), ('it', 'Italian'),
        ('pt', 'Portuguese'), ('nl', 'Dutch'), ('ar', 'Arabic'), ('tr', 'Turkish'), ('ru', 'Russian'),
        ('pl', 'Polish'), ('sv', 'Swedish'), ('da', 'Danish'), ('no', 'Norwegian'), ('fi', 'Finnish'),
        ('el', 'Greek'), ('he', 'Hebrew'), ('hi', 'Hindi'), ('ur', 'Urdu'), ('fa', 'Persian'),
        ('ja', 'Japanese'), ('ko', 'Korean'), ('zh-cn', 'Chinese (simplified)'), ('ro', 'Romanian'),
        ('hu', 'Hungarian'), ('cs', 'Czech'),
      ])
        (c, n),
    ];

// ---------------------------------------------------------------------------

class _SubtitlesPane extends StatefulWidget {
  const _SubtitlesPane();
  @override
  State<_SubtitlesPane> createState() => _SubtitlesPaneState();
}

class _SubtitlesPaneState extends State<_SubtitlesPane> {
  bool testing = false;

  Future<void> _setSecret(String key, String title, {bool password = false}) async {
    final state = AppScope.read(context);
    if (state.secrets.fromEnvironment(key)) {
      toast(context, 'This value comes from an environment variable and cannot be changed here.');
      return;
    }
    final v = await _secretPrompt(context, title, password: password);
    if (v == null) return;
    await state.secrets.set(key, v);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = context.pal;
    String show(String k, {bool mask = true}) {
      final v = state.secrets.get(k);
      if (v == null) return 'Not set';
      final src = state.secrets.fromEnvironment(k) ? ' (environment)' : '';
      return (mask ? '•' * 8 + (v.length > 4 ? v.substring(v.length - 4) : '') : v) + src;
    }

    final size = state.dbl(P.subSize, 32);
    return ListView(children: [
      PaneSection('OpenSubtitles', children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'Search and download subtitles inside the player. Create a free API consumer at '),
              WidgetSpan(
                child: InkWell(
                  onTap: () => launchUrl(Uri.parse('https://www.opensubtitles.com/en/consumers')),
                  child: Text('opensubtitles.com/consumers',
                      style: TextStyle(decoration: TextDecoration.underline, color: p.ink, fontSize: 13)),
                ),
              ),
              TextSpan(text: '. Downloading also needs your OpenSubtitles username and password. Keys are stored only on this '+deviceName+'.'),
            ]),
            style: TextStyle(color: p.ink2, fontSize: 13, height: 1.45),
          ),
        ),
        SettingsRow(title: 'API key', subtitle: show(SecretsStore.osApiKey), onTap: () => _setSecret(SecretsStore.osApiKey, 'OpenSubtitles API key')),
        SettingsRow(title: 'Username', subtitle: show(SecretsStore.osUsername, mask: false), onTap: () => _setSecret(SecretsStore.osUsername, 'OpenSubtitles username')),
        SettingsRow(title: 'Password', subtitle: state.secrets.get(SecretsStore.osPassword) == null ? 'Not set' : '••••••••', onTap: () => _setSecret(SecretsStore.osPassword, 'OpenSubtitles password', password: true)),
        SettingsRow(
          title: 'Test connection',
          trailing: testing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : null,
          onTap: testing
              ? null
              : () async {
                  setState(() => testing = true);
                  final e = await state.subtitles.test();
                  if (!mounted) return;
                  setState(() => testing = false);
                  if (context.mounted) toast(context, e ?? 'OpenSubtitles is working.', error: e != null);
                },
        ),
      ]),
      PaneSection('Preferences', children: [
        SettingsRow(
          title: 'Subtitle language',
          subtitle: state.str(P.subLang).isEmpty ? 'Off (pick manually in the player)' : state.str(P.subLang),
          onTap: () async {
            final v = await pickOption<String>(context, title: 'Subtitle language', current: state.str(P.subLang), options: _languages());
            if (v != null) await state.setPref(P.subLang, v);
          },
        ),
        SettingsRow(
          title: 'Text size',
          subtitle: '${size.round()}',
          trailing: SizedBox(
            width: 200,
            child: StepSlider(
              value: size.clamp(18, 64),
              min: 18,
              max: 64,
              step: 2,
              onChanged: (v) => state.setPref(P.subSize, v.roundToDouble()),
            ),
          ),
        ),
        SettingsRow(
          title: 'Text colour',
          subtitle: state.str(P.subColor, 'white'),
          onTap: () async {
            final v = await pickOption<String>(context,
                title: 'Text colour',
                current: state.str(P.subColor, 'white'),
                options: const [('white', 'White'), ('yellow', 'Yellow'), ('cyan', 'Cyan'), ('green', 'Green')]);
            if (v != null) await state.setPref(P.subColor, v);
          },
        ),
        SettingsSwitch(
          title: 'Background box',
          value: state.flag(P.subBg),
          onChanged: (v) => state.setPref(P.subBg, v),
        ),
      ]),
    ]);
  }
}

Future<String?> _secretPrompt(BuildContext context, String title, {bool password = false}) {
  final ctl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 420,
        child: TvEditGate(child: TextField(
          controller: ctl,
          autofocus: true,
          obscureText: password,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(labelText: 'Value (empty = remove)'),
          onSubmitted: (v) => Navigator.pop(c, v.trim()),
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, ctl.text.trim()), child: const Text('Save')),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------

class _MetadataPane extends StatefulWidget {
  const _MetadataPane();
  @override
  State<_MetadataPane> createState() => _MetadataPaneState();
}

class _MetadataPaneState extends State<_MetadataPane> {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = context.pal;
    final tmdb = state.secrets.get(SecretsStore.tmdbKey);
    return ListView(children: [
      PaneSection('Skip intro & credits', children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: Text(
            'Timings come from TheIntroDB (theintrodb.org), a crowd-sourced database. Skip buttons appear only '
            'when that title has been timed there and the app knows its TMDb id. Many titles have no data yet; '
            'nothing is guessed. Series ids are looked up with your TMDb key or OpenSubtitles key below.',
            style: TextStyle(color: p.ink2, fontSize: 13, height: 1.45),
          ),
        ),
        SettingsSwitch(
          title: 'Skip series intros automatically',
          subtitle: 'Off = show a "Skip intro" button',
          value: state.flag(P.seriesSkipIntro),
          onChanged: (v) => state.setPref(P.seriesSkipIntro, v),
        ),
        SettingsSwitch(
          title: 'Skip series credits automatically',
          subtitle: 'Jumps to the next episode when credits start',
          value: state.flag(P.seriesSkipCredits),
          onChanged: (v) => state.setPref(P.seriesSkipCredits, v),
        ),
        SettingsSwitch(
          title: 'Skip movie intros automatically',
          value: state.flag(P.movieSkipIntro),
          onChanged: (v) => state.setPref(P.movieSkipIntro, v),
        ),
      ]),
      PaneSection('TMDb', children: [
        SettingsRow(
          title: 'TMDb API key',
          subtitle: tmdb == null
              ? 'Not set — optional, improves matching for intro skipping and subtitles'
              : '••••••••${tmdb.length > 4 ? tmdb.substring(tmdb.length - 4) : ''}'
                  '${state.secrets.fromEnvironment(SecretsStore.tmdbKey) ? ' (environment)' : ''}',
          onTap: () async {
            if (state.secrets.fromEnvironment(SecretsStore.tmdbKey)) return;
            final v = await _secretPrompt(context, 'TMDb API key or read token');
            if (v == null) return;
            await state.secrets.set(SecretsStore.tmdbKey, v);
            setState(() {});
          },
        ),
        SettingsRow(
          title: 'Get a free key',
          subtitle: 'themoviedb.org/settings/api',
          onTap: () => launchUrl(Uri.parse('https://www.themoviedb.org/settings/api')),
        ),
      ]),
    ]);
  }
}

// ---------------------------------------------------------------------------

class _AboutPane extends StatelessWidget {
  const _AboutPane();
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final p = context.pal;
    return ListView(children: [
      PaneSection('TVflow', children: [
        const _VersionRow(),
        SettingsRow(title: 'Data folder', subtitle: state.paths.root.path, onTap: () => launchUrl(Uri.directory(state.paths.root.path))),
        SettingsRow(title: 'Device id', subtitle: state.device.deviceId),
      ]),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'This app plays streams from playlists you add. It does not provide any channels or content. '
          'Playback uses libmpv via media_kit. Font: the macOS system font.',
          style: TextStyle(color: p.ink2, fontSize: 13, height: 1.45),
        ),
      ),
    ]);
  }
}

/// Subscription details the server reported on the last refresh: expiry date,
/// status and connections. Only Xtream Codes servers (including get.php links)
/// provide them; plain M3U files and Stalker portals do not.
class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.source, required this.status});
  final Source source;
  final SourceStatusRow? status;

  @override
  Widget build(BuildContext context) {
    final a = AccountInfo.parse(status?.accountJson);
    final kind = SourceKind.of(source.kind);
    if (a == null) {
      final reason = switch (kind) {
        SourceKind.xtream => status == null || status!.lastRefresh == 0
            ? 'Fetch updates once and the expiry date shows up here.'
            : 'This server did not report an expiry date.',
        SourceKind.m3u => 'A plain M3U link does not say when it expires. Only Xtream Codes accounts report it '
            '(a link that contains username and password, like get.php?username=…, is detected as Xtream).',
        SourceKind.stalker => 'Stalker portals do not report an expiry date to TVflow.',
        SourceKind.file => 'A playlist file has no expiry date.',
      };
      return PaneSection('Subscription', children: [
        SettingsRow(icon: LucideIcons.calendarX, title: 'Expiry date unknown', subtitle: reason, chevron: false),
      ]);
    }
    final p = context.pal;
    final warn = a.expired || a.soon;
    final expiryTitle = a.expires != null
        ? '${a.expired ? 'Expired' : 'Expires'} ${fmtDay(a.expires!)}'
        : a.unlimited
            ? 'No expiry date (unlimited)'
            : 'Expiry date unknown';
    return PaneSection('Subscription', children: [
      SettingsRow(
        icon: warn ? LucideIcons.circleAlert : LucideIcons.calendar,
        title: expiryTitle,
        subtitle: a.countdown != null
            ? '${a.countdown![0].toUpperCase()}${a.countdown!.substring(1)}${a.soon ? '. Renew soon to keep watching.' : ''}'
            : 'Reported by the server at the last update.',
        chevron: false,
        trailing: warn
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: p.danger, borderRadius: BorderRadius.circular(6)),
                child: Text(a.expired ? 'Expired' : 'Soon', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.onPill)),
              )
            : null,
      ),
      if (a.status != null) SettingsRow(icon: LucideIcons.circleCheck, title: 'Status', subtitle: a.status, chevron: false),
      if (a.max != null)
        SettingsRow(
          icon: LucideIcons.monitorPlay,
          title: 'Connections',
          subtitle: a.active != null ? '${a.active} in use of ${a.max} allowed' : '${a.max} allowed at once',
          chevron: false,
        ),
      if (a.created != null) SettingsRow(icon: LucideIcons.clock, title: 'Started', subtitle: fmtDay(a.created!), chevron: false),
      if (a.trial) const SettingsRow(icon: LucideIcons.info, title: 'Trial account', chevron: false),
    ]);
  }
}

/// Asks before deleting a playlist; deletes it when confirmed. Returns true if it was deleted.
Future<bool> confirmDeletePlaylist(BuildContext context, AppState state, Source s) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final ok = await confirm(
    context,
    title: 'Delete "${s.name}"?',
    message: 'This removes the playlist from TVflow, together with its favourites, groups, watch history and resume '
        'positions. If sync is on, it is removed on your other devices too. Your account with the provider is not '
        'affected, and you can add the playlist again later.',
    action: 'Delete playlist',
  );
  if (!ok) return false;
  await state.deleteSource(s.id);
  messenger?.hideCurrentSnackBar();
  messenger?.showSnackBar(SnackBar(content: Text('"${s.name}" was deleted.')));
  return true;
}


/// Shows the installed version and whether a newer release exists on GitHub.
class _VersionRow extends StatefulWidget {
  const _VersionRow();
  @override
  State<_VersionRow> createState() => _VersionRowState();
}

class _VersionRowState extends State<_VersionRow> {
  String version = '…';
  String note = 'Checking for updates…';
  bool newer = false;

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final v = await UpdateChecker.currentVersion();
    if (mounted) setState(() => version = v);
    final u = await UpdateChecker.check();
    if (!mounted) return;
    setState(() {
      newer = u?.newer ?? false;
      note = u == null ? 'Could not check for updates' : (u.newer ? 'Update available: ${u.latest}. Tap to download.' : 'You have the latest version');
    });
  }

  @override
  Widget build(BuildContext context) => SettingsRow(
        title: 'Version $version',
        subtitle: note,
        onTap: () => newer ? launchUrl(Uri.parse(releasesPage)) : _run(),
      );
}
