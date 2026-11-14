import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'ui/player/mini_player.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';


import 'app/dev_bridge.dart';
import 'core/disk_image.dart';
import 'core/platform.dart';
import 'app/shell.dart';
import 'state/app_state.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await detectDevice();
  // A remote has no pointer: always show the focus ring.
  if (isTv) {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.alwaysTraditional;
  }
  if (isDesktop) {
    await windowManager.ensureInitialized();
    // TVFLOW_WINDOW=390x844 opens the window at a phone or tablet size, for layout checks.
    final preview = (Platform.environment['TVFLOW_WINDOW'] ?? '').split('x').map(double.tryParse).toList();
    final custom = preview.length == 2 && preview.every((v) => v != null);
    await windowManager.waitUntilReadyToShow(
      WindowOptions(
        size: custom ? Size(preview[0]!, preview[1]!) : const Size(1440, 900),
        minimumSize: custom ? const Size(300, 400) : const Size(900, 600),
        center: true,
        title: 'TVflow',
        titleBarStyle: TitleBarStyle.hidden,
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }

  AppState state;
  try {
    state = await AppState.load();
  } catch (e, st) {
    runApp(_StartupError('$e\n\n$st'));
    return;
  }
  final boundary = GlobalKey();
  final nav = GlobalKey<NavigatorState>();
  await DevBridge.startIfEnabled(state, boundary, nav);
  unawaited(ImageDiskCache.instance.trim());
  runApp(IptvApp(state: state, boundaryKey: boundary, navigatorKey: nav));
}

class IptvApp extends StatelessWidget {
  const IptvApp({super.key, required this.state, required this.boundaryKey, required this.navigatorKey});
  final AppState state;
  final GlobalKey boundaryKey;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'TVflow',
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: buildTheme(Brightness.dark),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: ThemeMode.dark,
          builder: (context, child) => RepaintBoundary(
              key: boundaryKey, child: _tvScale(context, TvFocusEntry(child: MiniPlayerHost(navigatorKey: navigatorKey, child: child!)))),
          home: const TvSafeArea(child: Shell()),
        ),
      ),
    );
  }
}

/// Fire TV reports a 960x540 logical screen (320 dpi), which is too coarse for this layout.
/// Lay the app out at 1.2x that size and scale it down to fit (about 1150x650 units, so text stays large).
Widget _tvScale(BuildContext context, Widget child) {
  if (!isTv) return child;
  const k = 1.2;
  final mq = MediaQuery.of(context);
  final size = Size(mq.size.width * k, mq.size.height * k);
  return FittedBox(
    fit: BoxFit.fill,
    child: SizedBox(
      width: size.width,
      height: size.height,
      child: MediaQuery(data: mq.copyWith(size: size, devicePixelRatio: mq.devicePixelRatio / k), child: child),
    ),
  );
}

class _StartupError extends StatelessWidget {
  const _StartupError(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(32),
            child: SelectableText('TVflow could not start.\n\n$message'),
          ),
        ),
      );
}
