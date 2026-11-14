import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kReleaseMode, debugPrint;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

import '../state/app_state.dart';

/// Development-only HTTP bridge for automated UI checks.
///
/// Off unless the IPTV_DEV_PORT environment variable is set, and bound to
/// 127.0.0.1 only. Endpoints:
///   GET /state                 current tab, source, routes
///   GET /screenshot?scale=1    PNG of the window contents
///   GET /texts                 visible texts with their rectangles
///   GET /tap?x=&y=             left click at logical coordinates
///   GET /rtap?x=&y=            right click
///   GET /drag?x=&y=&x2=&y2=     press, move, release
///   GET /scroll?x=&y=&dy=      scroll wheel
///   GET /type?text=            replace the focused text field's contents
///   GET /go?tab=live           switch tab
///   GET /key?k=up|down|left|right|ok|back|menu   press a remote key
///   GET /back                  pop the top route
class DevBridge {
  DevBridge(this.state, this.boundaryKey, this.navigatorKey);
  final AppState state;
  final GlobalKey boundaryKey;
  final GlobalKey<NavigatorState> navigatorKey;
  HttpServer? _server;
  int _pointer = 900;
  static const _device = 77;

  static Future<DevBridge?> startIfEnabled(
      AppState state, GlobalKey boundaryKey, GlobalKey<NavigatorState> navigatorKey) async {
    // Never in a release build: it can click and screenshot the app.
    if (kReleaseMode) return null;
    final port = int.tryParse(Platform.environment['IPTV_DEV_PORT'] ?? '');
    if (port == null) return null;
    final b = DevBridge(state, boundaryKey, navigatorKey);
    b._server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    b._server!.listen(b._handle);
    debugPrint('Dev bridge listening on 127.0.0.1:$port');
    return b;
  }

  Future<void> _handle(HttpRequest req) async {
    final q = req.uri.queryParameters;
    double d(String k, [double def = 0]) => double.tryParse(q[k] ?? '') ?? def;
    try {
      switch (req.uri.path) {
        case '/state':
          final routes = <String>[];
          navigatorKey.currentState?.popUntil((r) {
            routes.add(r.settings.name ?? r.runtimeType.toString());
            return true;
          });
          _json(req, {
            'tab': state.tab.name,
            'source': state.activeSource?.name,
            'sources': state.sources.length,
            'routes': routes,
            'progress': {for (final e in state.catalog.progress.value.entries) e.key: e.value.stage},
            'sync': {'running': state.sync.value.running, 'error': state.sync.value.error},
          });
        case '/screenshot':
          await _settle();
          final ctx = boundaryKey.currentContext;
          final ro = ctx?.findRenderObject() as RenderRepaintBoundary?;
          if (ro == null) throw StateError('no boundary');
          final img = await ro.toImage(pixelRatio: d('scale', 1));
          final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
          req.response.headers.contentType = ContentType('image', 'png');
          req.response.add(bytes!.buffer.asUint8List());
          await req.response.close();
        case '/texts':
          _json(req, _texts(all: q['all'] == '1'));
        case '/tap':
        case '/rtap':
          final pos = Offset(d('x'), d('y'));
          final buttons = req.uri.path == '/rtap' ? kSecondaryMouseButton : kPrimaryMouseButton;
          final id = _pointer++;
          final b = GestureBinding.instance;
          // One fixed virtual mouse, so hover state follows the last tap.
          b.handlePointerEvent(PointerHoverEvent(position: pos, kind: PointerDeviceKind.mouse, device: _device));
          b.handlePointerEvent(
              PointerDownEvent(pointer: id, position: pos, buttons: buttons, kind: PointerDeviceKind.mouse, device: _device));
          await Future.delayed(const Duration(milliseconds: 40));
          b.handlePointerEvent(PointerUpEvent(pointer: id, position: pos, kind: PointerDeviceKind.mouse, device: _device));
          await _settle();
          _json(req, {'ok': true});
        case '/drag':
          // Press, move in small steps, release (for reorderable lists).
          final from = Offset(d('x'), d('y')), to = Offset(d('x2'), d('y2'));
          final id = _pointer++;
          final b = GestureBinding.instance;
          b.handlePointerEvent(PointerDownEvent(
              pointer: id, position: from, buttons: kPrimaryMouseButton, kind: PointerDeviceKind.mouse, device: _device));
          await _frame();
          const steps = 12;
          for (var i = 1; i <= steps; i++) {
            final pos = Offset.lerp(from, to, i / steps)!;
            b.handlePointerEvent(PointerMoveEvent(
                pointer: id,
                position: pos,
                delta: (to - from) / steps.toDouble(),
                buttons: kPrimaryMouseButton,
                kind: PointerDeviceKind.mouse,
                device: _device));
            await _frame();
          }
          b.handlePointerEvent(PointerUpEvent(pointer: id, position: to, kind: PointerDeviceKind.mouse, device: _device));
          await _settle();
          _json(req, {'ok': true});
        case '/scroll':
          final pos = Offset(d('x'), d('y'));
          GestureBinding.instance.handlePointerEvent(
              PointerScrollEvent(position: pos, scrollDelta: Offset(d('dx'), d('dy')), kind: PointerDeviceKind.mouse, device: _device));
          await _settle();
          _json(req, {'ok': true});
        case '/type':
          final ok = _typeIntoFocused(q['text'] ?? '');
          await _settle();
          _json(req, {'ok': ok});
        case '/go':
          state.go(MainTab.values.byName(q['tab'] ?? 'live'));
          await _settle();
          _json(req, {'ok': true});
        case '/key':
          final keys = {
            'up': LogicalKeyboardKey.arrowUp,
            'down': LogicalKeyboardKey.arrowDown,
            'left': LogicalKeyboardKey.arrowLeft,
            'right': LogicalKeyboardKey.arrowRight,
            'ok': LogicalKeyboardKey.select,
            'back': LogicalKeyboardKey.goBack,
            'menu': LogicalKeyboardKey.contextMenu,
          };
          final phys = {
            'up': PhysicalKeyboardKey.arrowUp,
            'down': PhysicalKeyboardKey.arrowDown,
            'left': PhysicalKeyboardKey.arrowLeft,
            'right': PhysicalKeyboardKey.arrowRight,
            'ok': PhysicalKeyboardKey.enter,
            'back': PhysicalKeyboardKey.escape,
            'menu': PhysicalKeyboardKey.contextMenu,
          };
          for (final name in (q['k'] ?? '').split(',')) {
            final lk = keys[name], pk = phys[name];
            if (lk == null || pk == null) continue;
            if (name == 'back') {
              await navigatorKey.currentState?.maybePop();
            } else {
              for (final type in [ui.KeyEventType.down, ui.KeyEventType.up]) {
                ServicesBinding.instance.keyEventManager.handleKeyData(ui.KeyData(
                    timeStamp: Duration.zero,
                    type: type,
                    physical: pk.usbHidUsage,
                    logical: lk.keyId,
                    character: null,
                    synthesized: false));
              }
            }
            await Future<void>.delayed(const Duration(milliseconds: 250));
            await _settle();
          }
          final pf = FocusManager.instance.primaryFocus;
          final r = pf?.rect;
          _json(req, {
            'ok': true,
            'focus': pf == null ? null : '${pf.context?.widget.runtimeType}',
            'rect': r == null ? null : [r.left.round(), r.top.round(), r.width.round(), r.height.round()],
          });
        case '/back':
          final popped = await navigatorKey.currentState?.maybePop() ?? false;
          await _settle();
          _json(req, {'ok': popped});
        default:
          req.response.statusCode = 404;
          await req.response.close();
      }
    } catch (e) {
      req.response.statusCode = 500;
      req.response.write('$e');
      await req.response.close();
    }
  }

  /// Draws a frame now. macOS stops vsync for windows hidden behind others,
  /// so a warm-up frame (which does not wait for vsync) is used.
  Future<void> _frame() async {
    for (var i = 0; i < 3; i++) {
      SchedulerBinding.instance.scheduleWarmUpFrame();
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  Future<void> _settle() async {
    for (var i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      await _frame();
    }
  }

  void _json(HttpRequest req, Object data) {
    req.response.headers.contentType = ContentType.json;
    req.response.write(jsonEncode(data));
    req.response.close();
  }

  /// True when a click at [pos] would reach [ro] (visible, on the top route).
  bool _reachable(RenderBox ro, Offset pos) {
    final view = WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) return true;
    final r = HitTestResult();
    RendererBinding.instance.hitTestInView(r, pos, view.viewId);
    return r.path.any((e) => identical(e.target, ro));
  }

  List<Map<String, Object?>> _texts({bool all = false}) {
    final out = <Map<String, Object?>>[];
    void visit(Element e) {
      final w = e.widget;
      String? text;
      if (w is Text) {
        text = w.data ?? w.textSpan?.toPlainText();
      } else if (w is EditableText) {
        text = '[field] ${w.controller.text}';
      } else if (w is Tooltip) {
        text = '[tip] ${w.message ?? ''}';
      }
      if (text != null) {
        final ro = e.renderObject;
        if (ro is RenderBox && ro.attached && ro.hasSize) {
          final o = ro.localToGlobal(Offset.zero);
          if (o.dx > -1 && o.dy > -1 && (all || _reachable(ro, o + ro.size.center(Offset.zero)))) {
            out.add({
              't': text,
              'x': o.dx.round(),
              'y': o.dy.round(),
              'w': ro.size.width.round(),
              'h': ro.size.height.round(),
            });
          }
        }
      }
      final ro = e is MultiChildRenderObjectElement ? e.renderObject : null;
      if (ro is RenderIndexedStack) {
        // Only the visible tab.
        final kids = <Element>[];
        e.visitChildElements(kids.add);
        final i = ro.index ?? 0;
        if (i < kids.length) visit(kids[i]);
        return;
      }
      e.visitChildElements(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildElements(visit);
    return out;
  }

  bool _typeIntoFocused(String text) {
    var done = false;
    void visit(Element e) {
      if (done) return;
      if (e is StatefulElement && e.state is EditableTextState) {
        final s = e.state as EditableTextState;
        if (s.widget.focusNode.hasFocus) {
          s.userUpdateTextEditingValue(
              TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length)),
              SelectionChangedCause.keyboard);
          done = true;
          return;
        }
      }
      e.visitChildElements(visit);
    }

    WidgetsBinding.instance.rootElement?.visitChildElements(visit);
    return done;
  }

  Future<void> close() async => _server?.close(force: true);
}
