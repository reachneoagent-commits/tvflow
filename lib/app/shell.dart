import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';

import '../core/platform.dart';
import '../core/updates.dart';

import '../data/database/schema.dart';
import '../data/sources/models.dart';
import '../state/app_state.dart';
import '../ui/account_info.dart';
import '../ui/navigation.dart';
import '../ui/refresh_button.dart';
import '../ui/screens/browse_screen.dart';
import '../ui/screens/favorites_screen.dart';
import '../ui/screens/history_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/search_screen.dart';
import '../ui/cast_ui.dart';
import '../ui/screens/settings/settings_screen.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// Height of the top bar. The window's traffic lights sit at its left end.
const double kTopBarHeight = 56;

/// Main window: the main menu across the top, the selected page below it.
class Shell extends StatefulWidget {
  const Shell({super.key});

  /// ⌘1…⌘5, unchanged from the previous layout.
  static const shortcutTabs = [
    MainTab.live,
    MainTab.series,
    MainTab.movies,
    MainTab.search,
    MainTab.menu,
  ];

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  @override
  void initState() {
    super.initState();
    // One quiet check a few seconds after launch; tells the user only when a newer version exists.
    Future.delayed(const Duration(seconds: 6), () async {
      final u = await UpdateChecker.check();
      if (mounted && u != null && u.newer) toast(context, 'TVflow ${u.latest} is available. See Settings > About to download it.');
    });
  }

  /// Remote Back: first from the page to the menu bar, then to Home, and only then out of the app.
  void _tvBack(AppState state) {
    for (final h in tvBackHandlers.reversed.toList()) {
      if (h()) return;
    }
    final scope = FocusScope.of(context);
    FocusNode? tab;
    for (final n in scope.traversalDescendants) {
      if (n.context?.findAncestorWidgetOfExactType<NavPill>()?.active == true) {
        tab = n;
        break;
      }
    }
    if (tab != null && !tab.hasPrimaryFocus) {
      tab.requestFocus();
    } else if (state.tab != MainTab.home) {
      state.go(MainTab.home);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final n in FocusScope.of(context).traversalDescendants) {
          if (n.context?.findAncestorWidgetOfExactType<NavPill>()?.active ==
              true) {
            n.requestFocus();
            break;
          }
        }
      });
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final index = MainTab.values.indexOf(state.tab);
    return PopScope(
      // Remote: Back climbs up one level. Phone: Back returns to Home before it leaves the app.
      canPop: !isTv && !(isTouch && state.tab != MainTab.home),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isTv) {
          _tvBack(state);
        } else {
          state.go(MainTab.home);
        }
      },
      child: CallbackShortcuts(
        bindings: {
          for (var i = 0; i < Shell.shortcutTabs.length; i++)
            SingleActivator(
              LogicalKeyboardKey(LogicalKeyboardKey.digit1.keyId + i),
              meta: true,
            ): () =>
                state.go(Shell.shortcutTabs[i]),
          const SingleActivator(LogicalKeyboardKey.keyF, meta: true): () =>
              state.go(MainTab.search),
          const SingleActivator(
            LogicalKeyboardKey.keyH,
            meta: true,
            shift: true,
          ): () =>
              state.go(MainTab.home),
        },
        child: Focus(
          // Only here for the shortcuts; on TV it must not be a focus target itself.
          autofocus: !isTv,
          canRequestFocus: !isTv,
          skipTraversal: isTv,
          child: Scaffold(
            bottomNavigationBar: context.compact
                ? _BottomNav(state: state)
                : null,
            body: SafeArea(
              top: isTouch,
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(state: state),
                  SizedBox(height: context.compact ? 4 : 10),
                  Expanded(
                    child: IndexedStack(
                      index: index,
                      children: [
                        for (final (i, page) in <Widget>[
                          const BrowseScreen(
                            key: PageStorageKey('live'),
                            type: ContentType.live,
                          ),
                          const BrowseScreen(
                            key: PageStorageKey('series'),
                            type: ContentType.series,
                          ),
                          const BrowseScreen(
                            key: PageStorageKey('movies'),
                            type: ContentType.movie,
                          ),
                          state.tab == MainTab.search
                              ? const SearchScreen()
                              : const SizedBox(),
                          const SettingsScreen(),
                          const HomeScreen(),
                          state.tab == MainTab.favorites
                              ? const FavoritesScreen()
                              : const SizedBox(),
                          state.tab == MainTab.history
                              ? const HistoryScreen(embedded: true)
                              : const SizedBox(),
                        ].indexed)
                          ExcludeFocus(excluding: i != index, child: page),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Brand on the left, main sections in the middle, search, status, source and settings on the right.
/// The whole bar also drags the window.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.state});
  final AppState state;

  static const _icons = {
    MainTab.home: LucideIcons.house,
    MainTab.live: LucideIcons.tv,
    MainTab.movies: LucideIcons.clapperboard,
    MainTab.series: LucideIcons.tvMinimalPlay,
    MainTab.favorites: LucideIcons.heart,
    MainTab.history: LucideIcons.history,
  };

  static const _tabs = [
    MainTab.home,
    MainTab.live,
    MainTab.movies,
    MainTab.series,
    MainTab.history,
  ];
  static const _titles = {
    MainTab.home: 'Home',
    MainTab.live: 'Live TV',
    MainTab.movies: 'Movies',
    MainTab.series: 'Series',
    MainTab.history: 'History',
    MainTab.favorites: 'Favourites',
    MainTab.search: 'Search',
    MainTab.menu: 'Settings',
  };

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final compact = context.compact;
    final small = !context.expanded;
    return TvBarScope(
      child: WindowDragArea(
        child: Container(
          height: compact ? 52 : kTopBarHeight,
          decoration: BoxDecoration(
            color: p.side,
            border: Border(bottom: BorderSide(color: p.border, width: 0.5)),
          ),
          // 84 px on the left leaves room for the traffic lights.
          padding: EdgeInsets.fromLTRB(
            isTouch ? 12 : windowButtonsInset,
            0,
            compact ? 6 : 16,
            0,
          ),
          child: Row(
            children: [
              _Brand(onTap: () => state.go(MainTab.home)),
              const SizedBox(width: 18),
              if (compact)
                Expanded(
                  child: Text(
                    _titles[state.tab] ?? 'TVflow',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final t in _tabs) ...[
                          NavPill(
                            label: t.label,
                            icon: _icons[t],
                            active: state.tab == t,
                            onTap: () => state.go(t),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ],
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              if (isTv) ...[
                // A remote has no hover or tooltips: everything in the bar is a labelled pill.
                if (state.sources.isNotEmpty) ...[
                  _SourcePicker(state: state, iconOnly: false),
                  const SizedBox(width: 6),
                ],
                NavPill(
                  label: 'Search',
                  icon: LucideIcons.search,
                  active: state.tab == MainTab.search,
                  onTap: () => state.go(MainTab.search),
                ),
                const SizedBox(width: 4),
                NavPill(
                  label: 'Settings',
                  icon: LucideIcons.settings,
                  active: state.tab == MainTab.menu,
                  onTap: () => state.go(MainTab.menu),
                ),
              ] else ...[
                IconBtn(
                  LucideIcons.search,
                  size: 20,
                  color: state.tab == MainTab.search ? p.ink : p.ink2,
                  tooltip: 'Search everything (⌘F)',
                  onTap: () => state.go(MainTab.search),
                ),
                const SizedBox(width: 6),
                _Status(state: state),
                if (state.sources.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  _SourcePicker(state: state, iconOnly: small),
                ],
                const SizedBox(width: 6),
                const CastButton(),
                const SizedBox(width: 6),
                IconBtn(
                  LucideIcons.settings,
                  size: 20,
                  color: state.tab == MainTab.menu ? p.ink : p.ink2,
                  tooltip: 'Settings',
                  onTap: () => state.go(MainTab.menu),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      radius: 9,
      hoverColor: Colors.transparent,
      focusable: !isTv,
      tooltip: 'Home',
      child: Semantics(
        label: 'TVflow home',
        child: Image.asset(
          'assets/brand/logo.png',
          width: 36,
          height: 36,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

/// Playlist refresh progress and sync state, as small icons.
class _Status extends StatelessWidget {
  const _Status({required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder(
          valueListenable: state.catalog.progress,
          builder: (context, prog, _) {
            if (prog.isEmpty) return const SizedBox();
            final first = prog.values.first;
            return Tooltip(
              message: first.stage,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: first.fraction,
                    color: p.ink2,
                  ),
                ),
              ),
            );
          },
        ),
        ValueListenableBuilder(
          valueListenable: state.sync,
          builder: (context, s, _) {
            if (!state.device.syncEnabled) return const SizedBox();
            final icon = s.running
                ? LucideIcons.refreshCw
                : (s.error != null
                      ? LucideIcons.circleAlert
                      : LucideIcons.cloudCheck);
            return IconBtn(
              icon,
              size: 19,
              color: s.error != null ? p.danger : p.ink2,
              tooltip: s.running
                  ? 'Syncing…'
                  : (s.error ?? 'Synced. Click to sync now.'),
              onTap: s.running ? null : state.syncNow,
            );
          },
        ),
      ],
    );
  }
}

class _SourcePicker extends StatelessWidget {
  const _SourcePicker({required this.state, this.iconOnly = false});
  final AppState state;
  final bool iconOnly;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final name = state.activeSource?.name ?? 'Playlist';
    return PopupMenuButton<String>(
      tooltip: 'Switch playlist',
      position: PopupMenuPosition.under,
      onSelected: (id) async {
        if (id == '+') {
          await openAddSource(context);
        } else {
          await state.selectSource(id);
        }
      },
      itemBuilder: (_) => [
        for (final s in state.sources)
          PopupMenuItem(
            // The row handles its own taps so the refresh icon can leave the menu open.
            enabled: false,
            padding: EdgeInsets.zero,
            height: 54,
            child: _PlaylistMenuRow(
              source: s,
              active: s.id == state.activeSource?.id,
              onPick: () {
                Navigator.pop(context);
                state.selectSource(s.id);
              },
              // Edit and delete close the menu first, then act from the main window.
              onEdit: () {
                Navigator.pop(context);
                openAddSource(context, edit: s);
              },
              onDelete: () {
                Navigator.pop(context);
                confirmDeletePlaylist(context, state, s);
              },
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: '+',
          height: 38,
          child: Row(
            children: [
              SizedBox(width: 22, child: Icon(LucideIcons.plus, size: 18)),
              SizedBox(width: 8),
              Text('Add playlist'),
            ],
          ),
        ),
      ],
      child: TvFocusRing(
        child: Container(
          height: iconOnly ? 40 : 34,
          width: iconOnly ? 40 : null,
          constraints: const BoxConstraints(maxWidth: 200),
          padding: EdgeInsets.symmetric(horizontal: iconOnly ? 0 : 10),
          decoration: BoxDecoration(
            color: p.ghost,
            borderRadius: BorderRadius.circular(20),
          ),
          child: iconOnly
              ? Icon(LucideIcons.listVideo, size: 19, color: p.ink2)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.listVideo, size: 18, color: p.ink2),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(LucideIcons.chevronsUpDown, size: 15, color: p.ink3),
                  ],
                ),
        ),
      ),
    );
  }
}

class _PlaylistMenuRow extends StatelessWidget {
  const _PlaylistMenuRow({
    required this.source,
    required this.active,
    required this.onPick,
    required this.onEdit,
    required this.onDelete,
  });
  final Source source;
  final bool active;
  final VoidCallback onPick, onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final state = AppScope.of(context);
    // Menu items that handle their own taps are drawn dimmed by Flutter; undo that.
    return IconTheme.merge(
      data: const IconThemeData(opacity: 1),
      // Wide enough for the "Updated …" line and the three icons.
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: context.compact ? 290 : 360),
        child: Row(
          children: [
            Expanded(
              child: Pressable(
                onTap: onPick,
                radius: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 4, 0),
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          child: active
                              ? Icon(
                                  LucideIcons.check,
                                  size: 18,
                                  color: p.accent,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          // Rebuilds when a refresh starts or ends, so the time stays current.
                          child: ValueListenableBuilder(
                            valueListenable: state.catalog.progress,
                            builder: (context, prog, _) =>
                                FutureBuilder<SourceStatusRow?>(
                                  future: state.repo.status(source.id),
                                  builder: (context, snap) {
                                    final st = snap.data;
                                    final busy = prog.containsKey(source.id);
                                    final sub = busy
                                        ? 'Updating…'
                                        : st == null || st.lastRefresh == 0
                                        ? 'Not updated yet'
                                        : 'Updated ${fmtStamp(DateTime.fromMillisecondsSinceEpoch(st.lastRefresh))}';
                                    final failed =
                                        !busy && st?.lastError != null;
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          source.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: p.ink,
                                            fontWeight: active
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          failed
                                              ? '$sub · last try failed'
                                              : sub,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: failed ? p.danger : p.ink3,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            RefreshButton(source: source),
            IconBtn(
              LucideIcons.pencil,
              size: 17,
              color: p.ink,
              tooltip: 'Edit "${source.name}"',
              onTap: onEdit,
            ),
            IconBtn(
              LucideIcons.trash2,
              size: 17,
              color: p.ink,
              tooltip: 'Delete "${source.name}"',
              onTap: onDelete,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

/// Phone navigation: the main sections along the bottom, within thumb reach.
class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.state});
  final AppState state;

  static const _items = [
    (MainTab.home, LucideIcons.house, 'Home'),
    (MainTab.live, LucideIcons.tv, 'Live'),
    (MainTab.movies, LucideIcons.clapperboard, 'Movies'),
    (MainTab.series, LucideIcons.tvMinimalPlay, 'Series'),
    (MainTab.history, LucideIcons.history, 'History'),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      decoration: BoxDecoration(
        color: p.side,
        border: Border(top: BorderSide(color: p.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final (tab, icon, label) in _items)
                Expanded(
                  child: Pressable(
                    onTap: () => state.go(tab),
                    radius: 12,
                    hoverColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 52,
                          height: 28,
                          decoration: BoxDecoration(
                            color: state.tab == tab
                                ? p.accent.withValues(alpha: 0.22)
                                : null,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: state.tab == tab ? p.accent : p.ink2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: state.tab == tab
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: state.tab == tab ? p.ink : p.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
