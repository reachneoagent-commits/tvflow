import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../navigation.dart';
import '../theme.dart';
import '../widgets.dart' show ThinBar;
import 'play_request.dart';
import 'player_screen.dart';
import 'player_session.dart';

/// Floats the minimized player over every page of the app (picture in picture).
class MiniPlayerHost extends StatelessWidget {
  const MiniPlayerHost({super.key, required this.child, required this.navigatorKey});
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<PlayerSession?>(
        valueListenable: PlayerHub.current,
        builder: (_, s, _) => Stack(fit: StackFit.expand, children: [
          child,
          if (s != null) _MiniPlayer(key: ObjectKey(s), session: s, navigatorKey: navigatorKey),
        ]),
      );
}

class _MiniPlayer extends StatefulWidget {
  const _MiniPlayer({super.key, required this.session, required this.navigatorKey});
  final PlayerSession session;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<_MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<_MiniPlayer> {
  // Size is remembered between minimizes; the height follows 16:9.
  static double _width = 360;
  static const double _minW = 240;
  double get w => _width;
  double get h => _width * 9 / 16;
  final _subs = <StreamSubscription>[];
  bool hover = false, playing = true, buffering = false;
  Duration position = Duration.zero, duration = Duration.zero;
  // Distance from the window's right and bottom edges; dragging moves it.
  double right = 20, bottom = 20;

  PlayerSession get s => widget.session;

  @override
  void initState() {
    super.initState();
    final st = s.player.state;
    playing = st.playing;
    buffering = st.buffering;
    position = st.position;
    duration = st.duration;
    _subs.addAll([
      s.player.stream.playing.listen((v) => setState(() => playing = v)),
      s.player.stream.buffering.listen((v) => setState(() => buffering = v)),
      s.player.stream.duration.listen((v) => setState(() => duration = v)),
      s.player.stream.position.listen((v) {
        position = v;
        if (hover && mounted) setState(() {});
      }),
    ]);
  }

  @override
  void dispose() {
    for (final x in _subs) {
      x.cancel();
    }
    super.dispose();
  }

  void _expand() {
    final session = PlayerHub.take();
    final nav = widget.navigatorKey.currentState;
    if (session == null || nav == null) return;
    nav.push(fadeRoute(PlayerScreen(request: session.req, adopt: session), safe: false));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final size = MediaQuery.sizeOf(context);
    final maxW = (size.width - 16).clamp(_minW, size.width * 0.9);
    final r = s.req;
    final isLive = r.kind == PlayKind.live;
    final title = r.kind == PlayKind.episode
        ? '${r.item.name} · S${r.episode!.season} E${r.episode!.episode}'
        : r.item.name;
    return Positioned(
      right: right,
      bottom: bottom,
      width: w,
      height: h,
      child: MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: GestureDetector(
          onTap: _expand,
          onPanUpdate: (d) => setState(() {
            right = (right - d.delta.dx).clamp(8.0, size.width - w - 8);
            bottom = (bottom - d.delta.dy).clamp(8.0, size.height - h - 8);
          }),
          child: Material(
            color: Colors.black,
            elevation: 18,
            shadowColor: Colors.black,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14), side: BorderSide(color: p.border, width: 1)),
            child: Stack(fit: StackFit.expand, children: [
              Video(
                controller: s.video,
                controls: NoVideoControls,
                subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
              ),
              if (buffering) const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
              AnimatedOpacity(
                opacity: hover ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: IgnorePointer(
                  ignoring: !hover,
                  child: Stack(fit: StackFit.expand, children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xB3000000), Color(0x00000000), Color(0xCC000000)]),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 80,
                      bottom: isLive ? 10 : 16,
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Row(children: [
                        _Btn(LucideIcons.maximize2, 'Expand', _expand),
                        _Btn(LucideIcons.x, 'Close', PlayerHub.discard),
                      ]),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeUpLeft,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanUpdate: (d) => setState(() {
                            // The window is anchored bottom-right, so dragging the top-left corner outwards grows it.
                            final grow = -(d.delta.dx + d.delta.dy * 16 / 9) / 2;
                            _width = (_width + grow).clamp(_minW, maxW);
                            right = right.clamp(8.0, size.width - _width - 8);
                            bottom = bottom.clamp(8.0, size.height - h - 8);
                          }),
                          child: const SizedBox(
                            width: 30,
                            height: 30,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(LucideIcons.moveDiagonal2, size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Center(child: _Btn(playing ? LucideIcons.pause : LucideIcons.play, 'Play / pause', s.player.playOrPause, size: 30)),
                  ]),
                ),
              ),
              if (!isLive && duration > Duration.zero)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ThinBar((position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn(this.icon, this.label, this.onTap, {this.size = 18});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        button: true,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.all(2),
              padding: EdgeInsets.all(size > 20 ? 10 : 6),
              decoration: const BoxDecoration(color: Color(0x99000000), shape: BoxShape.circle),
              child: Icon(icon, size: size, color: Colors.white),
            ),
          ),
        ),
      );
}
