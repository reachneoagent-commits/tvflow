import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../state/app_state.dart';
import '../ui/theme.dart' show PaletteX;
import '../ui/widgets.dart' show Pressable;

/// True on macOS, Windows and Linux, where TVflow has its own window.
final bool isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

/// True on Android TV / Fire TV: driven by a remote control, full-screen all the time.
/// Set once at startup by [detectDevice]; phones and tablets running Android are not TVs.
bool isTv = false;

/// Remote Back handlers, innermost first: each returns true when it consumed the press
/// (for example by moving focus from a list to its category rail).
final List<bool Function()> tvBackHandlers = [];

/// What to call this machine in messages: "Mac" on a Mac, "device" on phones, tablets and TVs.
String get deviceName => Platform.isMacOS ? 'Mac' : (isDesktop ? 'computer' : 'device');

/// True on a phone or tablet (touch, no remote).
bool isTouch = false;

const _deviceChannel = MethodChannel('tvflow/device');

Future<void> detectDevice() async {
  if (Platform.isAndroid) {
    try {
      isTv = await _deviceChannel.invokeMethod<bool>('isTv') ?? false;
    } catch (_) {
      isTv = false;
    }
    isTouch = !isTv;
  } else if (Platform.isIOS) {
    isTouch = true;
  } else if (isDesktop && Platform.environment['TVFLOW_FORCE_TV'] == '1') {
    // Development: lay the app out and drive it like a TV on a desktop window.
    isTv = true;
  }
}

/// How much room the window has. Phones are compact, tablets in portrait and small windows
/// are medium, everything else (desktop, TV, tablets in landscape) is expanded.
enum FormFactor { compact, medium, expanded }

FormFactor formOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  return w < 600 ? FormFactor.compact : (w < 900 ? FormFactor.medium : FormFactor.expanded);
}

extension FormX on BuildContext {
  FormFactor get form => formOf(this);
  bool get compact => form == FormFactor.compact;
  bool get expanded => form == FormFactor.expanded;

  /// A dialog width that never overflows a narrow screen.
  double dialogW(double w) => w.clamp(0.0, MediaQuery.sizeOf(this).width - 56);

  /// Side margin of pages: tighter on phones.
  double get gutter => compact ? 14 : 28;
}

/// Left padding that clears the macOS traffic lights; nothing is needed elsewhere.
double get windowButtonsInset => Platform.isMacOS ? 84 : 20;

/// Full-screen is a window mode on desktop and a no-op on TV (always full-screen).
/// On phones and tablets it hides the system bars and turns the screen to landscape for video.
Future<void> setWindowFullScreen(bool v) async {
  if (isDesktop) {
    await windowManager.setFullScreen(v);
  } else if (isTouch) {
    await SystemChrome.setEnabledSystemUIMode(v ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(
        v ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight] : <DeviceOrientation>[]);
  }
}

/// Dragging the top bar moves the window on desktop only.
class WindowDragArea extends StatelessWidget {
  const WindowDragArea({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => isDesktop ? DragToMoveArea(child: child) : child;
}

/// Where focus last was, so a redraw that drops focus can put it back close by.
Rect? _lastFocusRect;

/// Moves focus onto a button: the one nearest where focus was before, else the first on-screen.
bool tvEnterFocus() {
  final primary = FocusManager.instance.primaryFocus;
  final scope = primary?.nearestScope ?? FocusManager.instance.rootScope;
  FocusNode? best;
  var bestD = double.infinity;
  for (final n in scope.traversalDescendants) {
    if (n == primary || n is FocusScopeNode || _isContainer(n)) continue;
    if (!n.canRequestFocus || n.context == null) continue;
    // A screen that never had focus starts at its first button; otherwise stay near the last one.
    final d = (_lastFocusRect == null || scope.focusedChild == null)
        ? n.rect.top * 10000 + n.rect.left
        : (n.rect.center - _lastFocusRect!.center).distanceSquared;
    if (d < bestD) {
      bestD = d;
      best = n;
    }
  }
  if (best == null) return false;
  best.requestFocus();
  return true;
}

/// A focus node that wraps a whole page rather than being a button or field.
bool _isContainer(FocusNode n) {
  final ctx = n.context;
  if (ctx == null) return true;
  final screen = MediaQuery.sizeOf(ctx);
  return n.rect.width * n.rect.height > screen.width * screen.height * 0.5;
}

/// Moves focus to the best button in [dir] from the focused one. Done by geometry: Flutter's own
/// traversal gets stuck on this layout. Up/down prefers the next row of controls even when it
/// sits off to the side (so the tabs next to a title are reachable); left/right stays on the row.
bool tvMove(TraversalDirection dir, {FocusNode? cur, Rect? from}) {
  cur ??= FocusManager.instance.primaryFocus;
  // Focus was dropped (the page redrew): carry on from where it was, in the direction pressed.
  final lost = cur == null || cur is FocusScopeNode || _isContainer(cur);
  if (lost && from == null) return tvEnterFocus();
  final scope = (lost ? FocusManager.instance.rootScope : cur.nearestScope) ?? FocusManager.instance.rootScope;
  final c = lost ? from! : cur.rect;
  final horizontal = dir == TraversalDirection.left || dir == TraversalDirection.right;
  FocusNode? best;
  var bestScore = double.infinity;
  // From the menu bar, Down goes to the next row of controls, whatever its side of the screen.
  final fromBar = !lost && dir == TraversalDirection.down && cur.context?.getInheritedWidgetOfExactType<TvBarScope>() != null;
  if (fromBar) {
    final cands = <FocusNode>[];
    var minMain = double.infinity;
    for (final n in scope.traversalDescendants) {
      if (n == cur || n is FocusScopeNode || !n.canRequestFocus || n.context == null) continue;
      if (_isContainer(n) || n.context!.getInheritedWidgetOfExactType<TvBarScope>() != null) continue;
      final m = n.rect.center.dy - c.center.dy;
      if (m <= 1) continue;
      cands.add(n);
      if (m < minMain) minMain = m;
    }
    for (final n in cands) {
      if (n.rect.center.dy - c.center.dy > minMain + 20) continue;
      final d = (n.rect.center.dx - c.center.dx).abs();
      if (d < bestScore) {
        bestScore = d;
        best = n;
      }
    }
    if (best == null) return false;
    best.requestFocus();
    return true;
  }
  for (final n in scope.traversalDescendants) {
    if (n == cur || n is FocusScopeNode || !n.canRequestFocus || n.context == null) continue;
    if (_isContainer(n) || (!lost && cur.ancestors.contains(n))) continue;
    final r = n.rect;
    final double main;
    switch (dir) {
      case TraversalDirection.down:
        main = r.center.dy - c.center.dy;
      case TraversalDirection.up:
        main = c.center.dy - r.center.dy;
      case TraversalDirection.right:
        main = r.center.dx - c.center.dx;
      case TraversalDirection.left:
        main = c.center.dx - r.center.dx;
    }
    if (main <= 1) continue;
    final double gap = horizontal ? _gap(c.top, c.bottom, r.top, r.bottom) : _gap(c.left, c.right, r.left, r.right);
    final double score;
    if (horizontal) {
      // Same row first: anything sharing the row beats anything on a different one.
      score = gap == 0 ? main : 100000 + main + gap * 3;
    } else {
      final dx = (r.center.dx - c.center.dx).abs();
      // Straight above/below first: a neighbour in another column (the category list next to the
      // channel grid) must never win over the next row of the same column.
      score = gap == 0 ? main + dx * 0.06 : 100000 + main + gap * 3;
    }
    if (score < bestScore) {
      bestScore = score;
      best = n;
    }
  }
  // Right never jumps to another row (the end of a row is the end); Left may, to reach the side list.
  if (best != null && dir == TraversalDirection.right && bestScore >= 100000) return false;
  if (best == null) return false;
  best.requestFocus();
  final ctx = best.context;
  if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.5, duration: const Duration(milliseconds: 120));
  return true;
}

double _gap(double a0, double a1, double b0, double b1) {
  if (b0 > a1) return b0 - a1;
  if (a0 > b1) return a0 - b1;
  return 0;
}

/// On TV, arrows move between buttons by geometry, and the first press with nothing focused
/// lands on the nearest button to where focus was.
class TvFocusEntry extends StatefulWidget {
  const TvFocusEntry({super.key, required this.child});
  final Widget child;

  @override
  State<TvFocusEntry> createState() => _TvFocusEntryState();
}

class _TvFocusEntryState extends State<TvFocusEntry> {
  static final _dirs = {
    LogicalKeyboardKey.arrowUp: TraversalDirection.up,
    LogicalKeyboardKey.arrowDown: TraversalDirection.down,
    LogicalKeyboardKey.arrowLeft: TraversalDirection.left,
    LogicalKeyboardKey.arrowRight: TraversalDirection.right,
  };

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_remember);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_remember);
    super.dispose();
  }

  void _remember() {
    if (!isTv) return;
    final p = FocusManager.instance.primaryFocus;
    if (p != null && p is! FocusScopeNode && p.context != null && !_isContainer(p)) _lastFocusRect = p.rect;
  }

  @override
  Widget build(BuildContext context) {
    if (!isTv) return widget.child;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, e) {
        if (e is KeyUpEvent) return KeyEventResult.ignored;
        final p = FocusManager.instance.primaryFocus;
        final dir = _dirs[e.logicalKey];
        final container = p == null || p is FocusScopeNode || _isContainer(p);
        if (dir != null) {
          // Left/right move the cursor inside a text field that is being edited.
          final editing = p?.context?.widget is EditableText;
          if (editing && (dir == TraversalDirection.left || dir == TraversalDirection.right)) {
            return KeyEventResult.ignored;
          }
          if (container) {
            if (!tvMove(dir, from: _lastFocusRect)) tvEnterFocus();
          } else {
            tvMove(dir);
          }
          return KeyEventResult.handled;
        }
        if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.select && container) {
          return tvEnterFocus() ? KeyEventResult.handled : KeyEventResult.ignored;
        }
        return KeyEventResult.ignored;
      },
      child: widget.child,
    );
  }
}

/// On TV, a text field is a button until OK is pressed: moving over it with the arrows must not
/// pop up the on-screen keyboard. After OK the field takes focus and the keyboard opens.
class TvEditGate extends StatefulWidget {
  const TvEditGate({super.key, required this.child});
  final Widget child;
  @override
  State<TvEditGate> createState() => _TvEditGateState();
}

class _TvEditGateState extends State<TvEditGate> {
  final _gate = FocusNode(debugLabel: 'tv-edit-gate', skipTraversal: true);
  bool _editing = false;

  @override
  void dispose() {
    _gate.dispose();
    super.dispose();
  }

  void _begin() {
    setState(() => _editing = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _gate.requestFocus();
      _gate.nextFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isTv) return widget.child;
    if (_editing) {
      return Focus(
        focusNode: _gate,
        onFocusChange: (has) {
          if (!has && mounted) setState(() => _editing = false);
        },
        child: widget.child,
      );
    }
    return Pressable(
      onTap: _begin,
      radius: 14,
      child: AbsorbPointer(child: ExcludeFocus(child: widget.child)),
    );
  }
}

/// Marks the menu bar, so navigation can tell when focus is up there.
class TvBarScope extends InheritedWidget {
  const TvBarScope({super.key, required super.child});
  @override
  bool updateShouldNotify(TvBarScope oldWidget) => false;
}

/// Keeps pages inside the part of the screen a TV actually shows. Many TVs (plasma and older LCDs
/// especially) crop the edges of the picture, which cut off the menu bar. The margin is a
/// percentage of the screen, adjustable in Settings > Player.
class TvSafeArea extends StatelessWidget {
  const TvSafeArea({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isTv) return child;
    final pct = AppScope.of(context).integer(P.tvMargin, 5).clamp(0, 15);
    final size = MediaQuery.sizeOf(context);
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * pct / 100, vertical: size.height * pct / 100),
        child: child,
      ),
    );
  }
}

/// Draws the TV focus outline around a child whose focus node belongs to an ancestor
/// (for example the child of a PopupMenuButton, which is focusable but draws nothing).
class TvFocusRing extends StatefulWidget {
  const TvFocusRing({super.key, required this.child, this.radius = 17});
  final Widget child;
  final double radius;
  @override
  State<TvFocusRing> createState() => _TvFocusRingState();
}

class _TvFocusRingState extends State<TvFocusRing> {
  FocusNode? _node;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final n = Focus.maybeOf(context, scopeOk: false);
    if (n != _node) {
      _node?.removeListener(_changed);
      _node = n;
      n?.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _node?.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isTv) return widget.child;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        border: (_node?.hasFocus ?? false) ? Border.all(color: context.pal.accent, width: 3) : null,
      ),
      child: widget.child,
    );
  }
}
