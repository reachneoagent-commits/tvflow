import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Live TV "Preview": the selected channel playing in a small window, with its
/// programme guide underneath. Click the picture to watch full screen.
class LivePreviewPane extends StatefulWidget {
  const LivePreviewPane({super.key, required this.channel, required this.onOpen});
  final ItemView? channel;

  /// Opens the full-screen player. The preview stops while it is open.
  final Future<void> Function(ItemView channel) onOpen;

  @override
  State<LivePreviewPane> createState() => LivePreviewPaneState();
}

class LivePreviewPaneState extends State<LivePreviewPane> {
  late final AppState state = AppScope.read(context);
  late final Player player = Player(configuration: const PlayerConfiguration(title: 'TVflow preview', bufferSize: 16 * 1024 * 1024));
  late final VideoController video = VideoController(player);
  final _subs = <StreamSubscription>[];
  final _guideScroll = ScrollController();
  Timer? _debounce, _clock;

  bool muted = true, buffering = false, hover = false, failed = false;
  List<Programme> guide = [];
  bool guideLoading = false;

  ItemView? get ch => widget.channel;

  @override
  void initState() {
    super.initState();
    player.setVolume(0);
    _subs.addAll([
      player.stream.buffering.listen((v) => setState(() => buffering = v)),
      player.stream.error.listen((e) {
        if (mounted && e.isNotEmpty) setState(() => failed = true);
      }),
    ]);
    // Keeps the "now" highlight and progress bar current.
    _clock = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
    _loadGuide();
    _schedulePlay();
  }

  @override
  void didUpdateWidget(LivePreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.channel?.key != ch?.key) {
      _loadGuide();
      _schedulePlay();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _clock?.cancel();
    for (final s in _subs) {
      s.cancel();
    }
    _guideScroll.dispose();
    player.dispose();
    super.dispose();
  }

  /// Waits a moment so that moving through the list doesn't open a stream per row.
  void _schedulePlay({bool now = false}) {
    _debounce?.cancel();
    if (ch == null) return;
    setState(() {
      failed = false;
      buffering = true;
    });
    _debounce = Timer(now ? Duration.zero : const Duration(milliseconds: 500), _play);
  }

  Future<void> _play() async {
    final c = ch;
    if (c == null || !mounted) return;
    try {
      final src = await state.repo.source(c.sourceId);
      if (src == null) return;
      final url = await state.catalog.streamUrl(src, c);
      if (!mounted || ch?.key != c.key) return;
      final native = player.platform;
      if (native is NativePlayer) {
        await native.setProperty('user-agent', state.userAgent);
        await native.setProperty('network-timeout', '15');
        await native.setProperty('cache-secs', '10');
      }
      await player.open(Media(url, httpHeaders: {'User-Agent': state.userAgent}));
      await player.setVolume(muted ? 0 : 100);
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  Future<void> _loadGuide() async {
    final c = ch;
    if (c == null) {
      setState(() => guide = []);
      return;
    }
    setState(() => guideLoading = true);
    final src = await state.repo.source(c.sourceId);
    if (src == null || !mounted) return;
    List<Programme> list = [];
    try {
      list = await state.catalog.channelGuide(src, c, back: const Duration(hours: 2), ahead: const Duration(hours: 24));
    } catch (_) {/* no guide for this channel */}
    if (!mounted || ch?.key != c.key) return;
    setState(() {
      guide = list;
      guideLoading = false;
    });
  }

  Future<void> _expand() => openFull(ch);

  /// Watches [c] full screen; the preview stops meanwhile so only one stream is open.
  Future<void> openFull(ItemView? c) async {
    if (c == null) return;
    await player.stop();
    await widget.onOpen(c);
    if (mounted) _schedulePlay(now: true);
  }

  void _toggleMute() {
    setState(() => muted = !muted);
    player.setVolume(muted ? 0 : 100);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final c = ch;
    if (c == null) {
      return Center(child: Text('Pick a channel to preview it', style: TextStyle(color: p.ink3)));
    }
    final now = DateTime.now();
    final current = guide.where((g) => g.isLiveAt(now)).firstOrNull;
    final upcoming = guide.where((g) => g.stop.isAfter(now)).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: GestureDetector(
          onTap: _expand,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(fit: StackFit.expand, children: [
                const ColoredBox(color: Colors.black),
                Video(
                  controller: video,
                  controls: NoVideoControls,
                  subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
                ),
                if (buffering && !failed) const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                if (failed)
                  const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.circleAlert, color: Colors.white70, size: 30),
                      SizedBox(height: 8),
                      Text('This channel could not be played', style: TextStyle(color: Colors.white70)),
                    ]),
                  ),
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 64,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xB3000000)]),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: hover ? 1 : 0,
                  duration: const Duration(milliseconds: 140),
                  child: Stack(fit: StackFit.expand, children: [
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x00000000), Color(0x00000000), Color(0xCC000000)]),
                      ),
                    ),
                    const Center(child: Icon(LucideIcons.maximize, color: Colors.white, size: 34)),
                  ]),
                ),
                Positioned(
                  left: 12,
                  bottom: 10,
                  right: 56,
                  child: Row(children: [
                    const LiveBadge(),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700)),
                    ),
                  ]),
                ),
                Positioned(
                  right: 6,
                  bottom: 4,
                  child: IconBtn(muted ? LucideIcons.volumeX : LucideIcons.volume2,
                      color: Colors.white, size: 20, tooltip: muted ? 'Turn sound on' : 'Mute', onTap: _toggleMute),
                ),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      if (current != null) _nowCard(current, now),
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 14, 2, 6),
        child: Text('TV guide', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
      ),
      Expanded(
        child: guideLoading && guide.isEmpty
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : upcoming.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('No guide information for this channel.', style: TextStyle(color: p.ink3, fontSize: 13)),
                  )
                : ListView.builder(
                    controller: _guideScroll,
                    itemCount: upcoming.length,
                    itemBuilder: (_, i) {
                      final g = upcoming[i];
                      final on = g.isLiveAt(now);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                            color: on ? p.sel : null,
                            borderRadius: BorderRadius.circular(10),
                            border: on ? null : Border(bottom: BorderSide(color: p.border, width: 0.5))),
                        child: Row(children: [
                          SizedBox(
                            width: 120,
                            child: Text('${fmtTime(g.start)} – ${fmtTime(g.stop)}',
                                style: TextStyle(fontSize: 12.5, color: on ? p.accent : p.ink3, fontWeight: FontWeight.w600)),
                          ),
                          Expanded(
                            child: Text(g.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13.5, color: on ? p.ink : p.ink2, fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
                          ),
                          if (on) const LiveBadge(label: 'NOW'),
                        ]),
                      );
                    },
                  ),
      ),
    ]);
  }

  Widget _nowCard(Programme g, DateTime now) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(g.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('${fmtTime(g.start)} – ${fmtTime(g.stop)} · ${g.stop.difference(now).inMinutes} min left',
            style: TextStyle(fontSize: 12.5, color: p.ink2)),
        const SizedBox(height: 8),
        ThinBar(g.progressAt(now), height: 4),
        if ((g.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(g.description!, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12.5, height: 1.4, color: p.ink3)),
        ],
      ]),
    );
  }
}
