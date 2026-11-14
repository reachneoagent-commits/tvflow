import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../../core/platform.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../account_info.dart';
import '../theme.dart';
import '../widgets.dart';

/// Watch several live channels at once. One tile has the sound (the selected
/// one); the others are muted. The grid size and the channels are remembered.
class MultiViewScreen extends StatefulWidget {
  const MultiViewScreen({super.key, this.add});

  /// A channel to put into the first free tile when the screen opens.
  final ItemView? add;

  @override
  State<MultiViewScreen> createState() => _MultiViewScreenState();
}

class _Tile {
  ItemView? item;
  Player? player;
  VideoController? video;
  String? error;
  bool loading = false;
  bool buffering = false;
  int retries = 0;
  final subs = <StreamSubscription>[];

  void dispose() {
    for (final s in subs) {
      s.cancel();
    }
    subs.clear();
    player?.dispose();
    player = null;
    video = null;
  }
}

class _MultiViewScreenState extends State<MultiViewScreen> {
  late final AppState state = AppScope.read(context);
  static const _prefKey = 'multiview';
  static const _layouts = [2, 4, 6, 9];

  final focus = FocusNode();
  final tiles = <_Tile>[];
  int count = 4;
  int selected = 0;
  int? expanded;
  int? hovered;
  bool fullscreen = false;
  int? maxConnections;
  String? sourceId;

  int get cols => switch (count) { 2 => 2, 4 => 2, 6 => 3, _ => 3 };
  int get rows => (count / cols).ceil();

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    for (final t in tiles) {
      t.dispose();
    }
    if (fullscreen) setWindowFullScreen(false);
    focus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Saved layout

  Future<void> _restore() async {
    final src = state.activeSource;
    sourceId = src?.id;
    if (src != null) {
      final st = await state.repo.status(src.id);
      maxConnections = AccountInfo.parse(st?.accountJson)?.max;
    }
    List<String?> ids = [];
    try {
      final d = jsonDecode(state.str(_prefKey, '{}'));
      if (d is Map && d['source'] == src?.id) {
        final n = d['n'];
        if (n is int && _layouts.contains(n)) count = n;
        ids = [for (final v in (d['ids'] as List? ?? [])) v as String?];
      }
    } catch (_) {/* start empty */}
    for (var i = 0; i < count; i++) {
      tiles.add(_Tile());
    }
    if (mounted) setState(() {});
    if (src != null) {
      final wanted = [for (final i in ids.take(count)) ?i];
      final found = await state.repo.itemsByIds(src.id, ContentType.live, wanted);
      final byId = {for (final f in found) f.id: f};
      for (var i = 0; i < ids.length && i < count; i++) {
        final it = ids[i] == null ? null : byId[ids[i]!];
        if (it != null) await _assign(i, it, save: false);
      }
    }
    final add = widget.add;
    if (add != null && mounted) {
      final free = tiles.indexWhere((t) => t.item == null);
      await _assign(free >= 0 ? free : selected, add);
      if (free >= 0) selected = free;
    }
    if (mounted) setState(() {});
    _applyAudio();
  }

  void _save() {
    state.setPref(
        _prefKey,
        jsonEncode({
          'source': sourceId,
          'n': count,
          'ids': [for (final t in tiles) t.item?.id],
        }));
  }

  // ---------------------------------------------------------------------------
  // Tiles

  Future<void> _setCount(int n) async {
    if (n == count) return;
    setState(() {
      expanded = null;
      while (tiles.length > n) {
        tiles.removeLast().dispose();
      }
      while (tiles.length < n) {
        tiles.add(_Tile());
      }
      count = n;
      if (selected >= n) selected = n - 1;
    });
    _save();
    _applyAudio();
  }

  Future<void> _assign(int i, ItemView item, {bool save = true}) async {
    if (i >= tiles.length) return;
    final t = tiles[i];
    t.item = item;
    t.error = null;
    t.retries = 0;
    if (mounted) setState(() {});
    await _open(t);
    if (save) _save();
    _applyAudio();
  }

  Future<void> _open(_Tile t) async {
    final item = t.item;
    if (item == null) return;
    t.loading = true;
    t.error = null;
    if (mounted) setState(() {});
    try {
      final src = await state.repo.source(item.sourceId);
      if (src == null) throw StateError('This playlist was removed.');
      final url = await state.catalog.streamUrl(src, item);
      if (t.player == null) {
        final p = Player(configuration: const PlayerConfiguration(title: 'TVflow', bufferSize: 16 * 1024 * 1024));
        t.player = p;
        t.video = VideoController(p);
        t.subs.addAll([
          p.stream.buffering.listen((b) {
            t.buffering = b;
            if (mounted) setState(() {});
          }),
          p.stream.error.listen((e) => _onError(t, e)),
        ]);
      }
      final native = t.player!.platform;
      if (native is NativePlayer) {
        await native.setProperty('user-agent', state.userAgent);
        await native.setProperty('network-timeout', '20');
        await native.setProperty('cache-secs', '8');
      }
      await t.player!.setVolume(0);
      await t.player!.open(Media(url, httpHeaders: {'User-Agent': state.userAgent}));
      t.loading = false;
    } catch (e) {
      t.loading = false;
      t.error = '$e';
    }
    if (mounted) setState(() {});
  }

  void _onError(_Tile t, String e) {
    final item = t.item;
    if (!mounted || item == null) return;
    debugPrint('multiview error: $e');
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted || t.item != item || t.error != null) return;
      final p = t.player;
      if (p != null && p.state.playing && !t.buffering) return;
      if (t.retries < 2) {
        t.retries++;
        _open(t);
        return;
      }
      setState(() => t.error = e.isEmpty ? 'The stream could not be played.' : e);
    });
  }

  void _remove(int i) {
    final t = tiles[i];
    t.dispose();
    setState(() {
      t.item = null;
      t.error = null;
      t.loading = false;
      if (expanded == i) expanded = null;
    });
    _save();
  }

  /// Only the selected tile has sound.
  void _applyAudio() {
    final vol = state.flag(P.rememberVolume, true) ? state.dbl(P.volume, 100) : 100.0;
    for (var i = 0; i < tiles.length; i++) {
      tiles[i].player?.setVolume(i == selected ? (vol <= 0 ? 100 : vol) : 0);
    }
    if (mounted) setState(() {});
  }

  void _select(int i) {
    if (selected == i) return;
    selected = i;
    _applyAudio();
  }

  Future<void> _pick(int i) async {
    final src = state.activeSource;
    if (src == null) return;
    final it = await showDialog<ItemView>(context: context, builder: (_) => _ChannelPicker(sourceId: src.id));
    if (it != null) {
      selected = i;
      await _assign(i, it);
    }
  }

  Future<void> _toggleFullscreen() async {
    fullscreen = !fullscreen;
    await setWindowFullScreen(fullscreen);
    if (mounted) setState(() {});
  }

  void _clearAll() {
    setState(() {
      for (final t in tiles) {
        t.dispose();
        t.item = null;
        t.error = null;
      }
      expanded = null;
    });
    _save();
  }

  // ---------------------------------------------------------------------------
  // Keyboard

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    int move(int dc, int dr) {
      final c = selected % cols + dc, r = selected ~/ cols + dr;
      if (c < 0 || c >= cols || r < 0 || r >= rows) return selected;
      final n = r * cols + c;
      return n < count ? n : selected;
    }

    if (k == LogicalKeyboardKey.arrowLeft) {
      _select(move(-1, 0));
    } else if (k == LogicalKeyboardKey.arrowRight) {
      _select(move(1, 0));
    } else if (k == LogicalKeyboardKey.arrowUp) {
      _select(move(0, -1));
    } else if (k == LogicalKeyboardKey.arrowDown) {
      _select(move(0, 1));
    } else if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) {
      if (tiles[selected].item == null) {
        _pick(selected);
      } else {
        setState(() => expanded = expanded == selected ? null : selected);
      }
    } else if (k == LogicalKeyboardKey.escape) {
      if (expanded != null) {
        setState(() => expanded = null);
      } else if (fullscreen) {
        _toggleFullscreen();
      } else {
        Navigator.of(context).maybePop();
      }
    } else if (k == LogicalKeyboardKey.keyF) {
      _toggleFullscreen();
    } else if (k == LogicalKeyboardKey.keyC) {
      _pick(selected);
    } else if (k == LogicalKeyboardKey.delete || k == LogicalKeyboardKey.backspace) {
      if (tiles[selected].item != null) _remove(selected);
    } else {
      final d = k.keyId - LogicalKeyboardKey.digit1.keyId;
      if (d >= 0 && d < count) {
        _select(d);
      } else {
        return KeyEventResult.ignored;
      }
    }
    return KeyEventResult.handled;
  }

  // ---------------------------------------------------------------------------
  // UI

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final filled = tiles.where((t) => t.item != null).length;
    final overLimit = maxConnections != null && filled > maxConnections!;
    return Scaffold(
      backgroundColor: p.bg,
      body: Focus(
        focusNode: focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _header(p, filled),
          if (overLimit)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                  color: p.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: p.danger.withValues(alpha: 0.6))),
              child: Row(children: [
                Icon(LucideIcons.circleAlert, size: 18, color: p.danger),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This playlist allows $maxConnections connection${maxConnections == 1 ? '' : 's'} at once and you are '
                    'watching $filled. Streams beyond the limit may be refused by the provider.',
                    style: TextStyle(color: p.danger, fontSize: 13),
                  ),
                ),
              ]),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: tiles.isEmpty ? const Center(child: CircularProgressIndicator()) : _grid(p),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _header(Palette p, int filled) {
    return Padding(
      // 84 px on the left leaves room for the window buttons.
      padding: EdgeInsets.fromLTRB(fullscreen ? 16 : windowButtonsInset, 10, 16, 10),
      child: Row(children: [
        IconBtn(LucideIcons.arrowLeft, tooltip: 'Back', onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 8),
        const Text('Multi-view', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
        const SizedBox(width: 14),
        Text('$filled of $count channels', style: TextStyle(color: p.ink3, fontSize: 13)),
        const Spacer(),
        SizedBox(
          width: 240,
          child: Segmented<int>(
            values: _layouts,
            labels: [for (final n in _layouts) '$n'],
            selected: count,
            onChanged: _setCount,
          ),
        ),
        const SizedBox(width: 10),
        IconBtn(LucideIcons.trash2, tooltip: 'Clear all tiles', onTap: filled == 0 ? null : _clearAll),
        IconBtn(fullscreen ? LucideIcons.minimize : LucideIcons.maximize,
            tooltip: fullscreen ? 'Exit full screen (F)' : 'Full screen (F)', onTap: _toggleFullscreen),
      ]),
    );
  }

  Widget _grid(Palette p) {
    const gap = 10.0;
    // Tiles stay mounted while one is expanded so their streams keep playing.
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      final h = (c.maxHeight - gap * (rows - 1)) / rows;
      return Stack(children: [
        for (var i = 0; i < count; i++)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            left: expanded == i ? 0 : (i % cols) * (w + gap),
            top: expanded == i ? 0 : (i ~/ cols) * (h + gap),
            width: expanded == i ? c.maxWidth : w,
            height: expanded == i ? c.maxHeight : h,
            child: Offstage(offstage: expanded != null && expanded != i, child: _tile(p, i)),
          ),
      ]);
    });
  }

  Widget _tile(Palette p, int i) {
    final t = tiles[i];
    final sel = selected == i;
    final hot = hovered == i;
    final isExpanded = expanded == i;
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = i),
      onExit: (_) => setState(() => hovered = hovered == i ? null : hovered),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          focus.requestFocus();
          if (t.item == null) {
            _pick(i);
          } else {
            _select(i);
          }
        },
        onDoubleTap: t.item == null ? null : () => setState(() => expanded = isExpanded ? null : i),
        child: Container(
          decoration: BoxDecoration(
            color: p.pane,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: sel ? p.accent : p.card, width: sel ? 3 : 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            if (t.item == null)
              _emptyTile(p, i)
            else ...[
              if (t.video != null) Video(controller: t.video!, controls: NoVideoControls, fill: Colors.black),
              if (t.loading || (t.buffering && t.error == null))
                const Center(child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.5))),
              if (t.error != null) _errorTile(p, t),
              // Name and sound state, always visible so the audio tile is clear.
              Positioned(
                left: 8,
                bottom: 8,
                right: 8,
                child: Row(children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: p.overlay, borderRadius: BorderRadius.circular(8)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(sel ? LucideIcons.volume2 : LucideIcons.volumeX, size: 14, color: sel ? p.accent : p.ink3),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('${i + 1}  ${t.item!.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                  ),
                ]),
              ),
              if (hot || isExpanded)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    decoration: BoxDecoration(color: p.overlay, borderRadius: BorderRadius.circular(10)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconBtn(LucideIcons.listVideo, size: 17, tooltip: 'Change channel (C)', onTap: () => _pick(i)),
                      IconBtn(isExpanded ? LucideIcons.minimize : LucideIcons.maximize,
                          size: 17,
                          tooltip: isExpanded ? 'Back to the grid' : 'Fill the window (Enter)',
                          onTap: () => setState(() => expanded = isExpanded ? null : i)),
                      IconBtn(LucideIcons.x, size: 17, tooltip: 'Remove from multi-view', onTap: () => _remove(i)),
                    ]),
                  ),
                ),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _emptyTile(Palette p, int i) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: p.card, shape: BoxShape.circle),
            child: Icon(LucideIcons.plus, color: p.accent, size: 22),
          ),
          const SizedBox(height: 10),
          Text('Add a channel', style: TextStyle(color: p.ink2, fontWeight: FontWeight.w600, fontSize: 13.5)),
          const SizedBox(height: 2),
          Text('Tile ${i + 1}', style: TextStyle(color: p.ink3, fontSize: 12)),
        ]),
      );

  Widget _errorTile(Palette p, _Tile t) => Container(
        color: p.bg.withValues(alpha: 0.85),
        padding: const EdgeInsets.all(14),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(LucideIcons.circleAlert, color: p.danger, size: 24),
            const SizedBox(height: 8),
            Text(
              maxConnections != null && maxConnections! <= 1
                  ? 'Could not play. Your playlist may allow only one stream at a time.'
                  : 'Could not play this channel.',
              textAlign: TextAlign.center,
              style: TextStyle(color: p.ink2, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            GhostButton(label: 'Try again', icon: LucideIcons.rotateCcw, onPressed: () {
              t.retries = 0;
              _open(t);
            }),
          ]),
        ),
      );
}

/// Search the playlist's live channels (favourites first) and pick one.
class _ChannelPicker extends StatefulWidget {
  const _ChannelPicker({required this.sourceId});
  final String sourceId;
  @override
  State<_ChannelPicker> createState() => _ChannelPickerState();
}

class _ChannelPickerState extends State<_ChannelPicker> {
  late final AppState state = AppScope.read(context);
  List<ItemView>? items;
  String query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final r = await state.repo.browse(
        BrowseQuery(sourceId: widget.sourceId, type: ContentType.live, search: query, favoritesFirst: true),
        limit: 120);
    if (mounted) setState(() => items = r);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('Pick a channel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            TvEditGate(child: TextField(
              autofocus: true,
              decoration: InputDecoration(hintText: 'Search channels', prefixIcon: Icon(LucideIcons.search, size: 18, color: p.ink3)),
              onChanged: (v) {
                query = v.trim();
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 220), _load);
              },
            )),
            const SizedBox(height: 10),
            Expanded(
              child: items == null
                  ? const Center(child: CircularProgressIndicator())
                  : items!.isEmpty
                      ? Center(child: Text('No channels found', style: TextStyle(color: p.ink3)))
                      : ListView.builder(
                          itemCount: items!.length,
                          itemBuilder: (_, i) {
                            final it = items![i];
                            return Pressable(
                              radius: 10,
                              onTap: () => Navigator.pop(context, it),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                child: Row(children: [
                                  Container(
                                    width: 56,
                                    height: 38,
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(8)),
                                    child: NetImage(it.icon, fit: BoxFit.contain, placeholderIcon: LucideIcons.tv, cacheWidth: 120, transparent: true),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  if (it.isFavorite) FilledHeart(size: 16, color: p.accent),
                                ]),
                              ),
                            );
                          },
                        ),
            ),
          ]),
        ),
      ),
    );
  }
}
