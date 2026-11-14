import '../../core/platform.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:media_kit/media_kit.dart';

import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../cards.dart';
import '../theme.dart';
import '../widgets.dart';

/// Frosted dark panel that slides in from the right over the video.
class PlayerSidePanel extends StatelessWidget {
  const PlayerSidePanel({super.key, required this.width, required this.child});
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Swallows taps so they do not pause the video behind the panel.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      onDoubleTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            width: width,
            decoration: BoxDecoration(
              color: const Color(0xF5101A1D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12, width: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A row in a player list: label, optional detail line, check mark when chosen.
class PanelRow extends StatelessWidget {
  const PanelRow({super.key, required this.title, this.detail, required this.selected, required this.onTap});
  final String title;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: onTap,
      radius: 10,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 14.5, color: selected ? p.accent : Colors.white, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
              if (detail != null) ...[
                const SizedBox(height: 3),
                Text(detail!, style: const TextStyle(fontSize: 12, color: Colors.white60)),
              ],
            ]),
          ),
          if (selected)
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
              child: Icon(LucideIcons.check, size: 14, color: p.onPill),
            ),
        ]),
      ),
    );
  }
}

String _audioDetail(AudioTrack t) {
  final ch = t.channelscount;
  final chText = switch (ch) {
    1 => '1.0',
    2 => '2.0',
    6 => '5.1',
    8 => '7.1',
    null => null,
    _ => '$ch ch',
  };
  final kbps = t.bitrate == null ? null : '${(t.bitrate! / 1000).round()} kbps';
  return [?t.codec, ?chText, ?kbps].join(' · ');
}

String _trackName(String? title, String? lang, String id, String fallback) {
  final l = (lang ?? '').isEmpty ? null : lang!.toUpperCase();
  final t = (title ?? '').isEmpty ? null : title;
  if (t != null && l != null) return '$t · $l';
  return t ?? l ?? '$fallback $id';
}

/// Audio and subtitles side by side, built from what the stream itself reports.
class TracksPanel extends StatefulWidget {
  const TracksPanel({
    super.key,
    required this.audio,
    required this.subtitles,
    required this.currentAudio,
    required this.currentSubtitle,
    required this.onAudio,
    required this.onSubtitle,
    required this.onSearchOpenSubtitles,
    required this.onLoadFile,
    required this.canAddSubtitles,
    required this.subSize,
    required this.subColor,
    required this.subBackground,
    required this.onSubSize,
    required this.onSubColor,
    required this.onSubBackground,
    required this.onClose,
  });

  final List<AudioTrack> audio;
  final List<SubtitleTrack> subtitles;
  final AudioTrack currentAudio;
  final SubtitleTrack currentSubtitle;
  final ValueChanged<AudioTrack> onAudio;
  final ValueChanged<SubtitleTrack> onSubtitle;
  final VoidCallback onSearchOpenSubtitles, onLoadFile, onClose;
  final bool canAddSubtitles;
  final double subSize;
  final String subColor;
  final bool subBackground;
  final ValueChanged<double> onSubSize;
  final ValueChanged<String> onSubColor;
  final ValueChanged<bool> onSubBackground;

  @override
  State<TracksPanel> createState() => _TracksPanelState();
}

class _TracksPanelState extends State<TracksPanel> {
  int tab = 0; // 0 = from the stream, 1 = OpenSubtitles
  bool styling = false;

  Widget _header(String text, {List<Widget> trailing = const []}) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 8),
        child: Row(children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white))),
          ...trailing,
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final audioOff = widget.currentAudio.id == 'no';
    final subOff = widget.currentSubtitle.id == 'no' || widget.currentSubtitle.id == 'auto' && widget.subtitles.isEmpty;
    return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // Audio
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _header('Audio'),
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(10, 0, 10, 16), children: [
              PanelRow(title: 'Disabled', selected: audioOff, onTap: () => widget.onAudio(AudioTrack.no())),
              if (widget.audio.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Text('This stream has one default audio track.', style: TextStyle(color: Colors.white60, fontSize: 12.5)),
                ),
              for (final a in widget.audio)
                PanelRow(
                  title: _trackName(a.title, a.language, a.id, 'Track'),
                  detail: _audioDetail(a).isEmpty ? null : _audioDetail(a),
                  // "auto" means the player picked the first track.
                  selected: widget.currentAudio.id == a.id || (widget.currentAudio.id == 'auto' && a == widget.audio.first),
                  onTap: () => widget.onAudio(a),
                ),
            ]),
          ),
        ]),
      ),
      Container(width: 0.5, color: Colors.white24),
      // Subtitles
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _header('Subtitles', trailing: [
            IconBtn(LucideIcons.palette,
                size: 19, color: styling ? p.accent : Colors.white, tooltip: 'Subtitle style', onTap: () => setState(() => styling = !styling)),
            IconBtn(LucideIcons.x, size: 20, color: Colors.white, tooltip: 'Close', onTap: widget.onClose),
          ]),
          if (styling)
            Expanded(child: _style(p))
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Segmented<int>(
                values: const [0, 1],
                labels: const ['Internal', 'OpenSubtitles'],
                selected: tab,
                onChanged: (v) => setState(() => tab = v),
              ),
            ),
            Expanded(
              child: tab == 0
                  ? ListView(padding: const EdgeInsets.fromLTRB(10, 0, 10, 16), children: [
                      PanelRow(
                          title: 'Disabled', selected: subOff, onTap: () => widget.onSubtitle(SubtitleTrack.no())),
                      for (final s in widget.subtitles)
                        PanelRow(
                          title: _trackName(s.title, s.language, s.id, 'Subtitle'),
                          detail: s.codec,
                          selected: widget.currentSubtitle.id == s.id,
                          onTap: () => widget.onSubtitle(s),
                        ),
                    ])
                  : ListView(padding: const EdgeInsets.fromLTRB(10, 0, 10, 16), children: [
                      if (!widget.canAddSubtitles)
                        const Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('Extra subtitles are available for movies and episodes.',
                              style: TextStyle(color: Colors.white60, fontSize: 13)),
                        )
                      else ...[
                        _action(LucideIcons.search, 'Search OpenSubtitles for this title', widget.onSearchOpenSubtitles),
                        _action(LucideIcons.folderOpen, 'Load a subtitle file…', widget.onLoadFile),
                      ],
                    ]),
            ),
          ],
        ]),
      ),
    ]);
  }

  Widget _action(IconData icon, String label, VoidCallback onTap) => Pressable(
        onTap: onTap,
        radius: 10,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
          child: Row(children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14.5, color: Colors.white))),
          ]),
        ),
      );

  Widget _style(Palette p) {
    Widget chip(String label, bool on, VoidCallback onTap) => Pressable(
          onTap: onTap,
          radius: 18,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
                color: on ? p.accent : Colors.white12, borderRadius: BorderRadius.circular(18)),
            child: Text(label,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: on ? p.onPill : Colors.white)),
          ),
        );
    Widget label(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8), child: Text(t, style: const TextStyle(color: Colors.white60, fontSize: 12.5)));
    return ListView(padding: const EdgeInsets.fromLTRB(10, 0, 10, 16), children: [
      label('Size'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (n, v) in [('Small', 24.0), ('Medium', 32.0), ('Large', 40.0), ('Huge', 52.0)])
            chip(n, widget.subSize == v, () => widget.onSubSize(v)),
        ]),
      ),
      label('Colour'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(spacing: 8, runSpacing: 8, children: [
          for (final (n, v) in [('White', 'white'), ('Yellow', 'yellow'), ('Cyan', 'cyan'), ('Green', 'green')])
            chip(n, widget.subColor == v, () => widget.onSubColor(v)),
        ]),
      ),
      label('Background'),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(spacing: 8, children: [
          chip('None', !widget.subBackground, () => widget.onSubBackground(false)),
          chip('Dark box', widget.subBackground, () => widget.onSubBackground(true)),
        ]),
      ),
    ]);
  }
}

/// Live TV: every channel of the list you came from, to switch without leaving the player.
class ChannelsPanel extends StatefulWidget {
  const ChannelsPanel({super.key, required this.channels, required this.currentId, required this.onPick, required this.onClose});
  final List<ItemView> channels;
  final String currentId;
  final ValueChanged<ItemView> onPick;
  final VoidCallback onClose;

  @override
  State<ChannelsPanel> createState() => _ChannelsPanelState();
}

class _ChannelsPanelState extends State<ChannelsPanel> {
  String q = '';
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start with the playing channel in view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final i = widget.channels.indexWhere((c) => c.id == widget.currentId);
      if (i > 3 && _scroll.hasClients) _scroll.jumpTo((i * 56.0 - 120).clamp(0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final list = q.isEmpty ? widget.channels : widget.channels.where((c) => c.name.toLowerCase().contains(q.toLowerCase())).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Row(children: [
          const Expanded(child: Text('Channels', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white))),
          Text('${widget.channels.length}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          IconBtn(LucideIcons.x, size: 20, color: Colors.white, tooltip: 'Close', onTap: widget.onClose),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
        child: SizedBox(
          height: 36,
          child: TvEditGate(child: TextField(
            onChanged: (v) => setState(() => q = v.trim()),
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Search these channels',
              prefixIcon: const Icon(LucideIcons.search, size: 17),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              fillColor: Colors.white12,
            ),
          )),
        ),
      ),
      Expanded(
        child: list.isEmpty
            ? const Center(child: Text('No channels found', style: TextStyle(color: Colors.white60)))
            : ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                itemExtent: 56,
                itemCount: list.length,
                itemBuilder: (_, i) {
                  final c = list[i];
                  final on = c.id == widget.currentId;
                  return Pressable(
                    onTap: () => widget.onPick(c),
                    radius: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(color: on ? Colors.white12 : null, borderRadius: BorderRadius.circular(10)),
                      child: Row(children: [
                        ChannelLogo(c.icon, width: 52, height: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(c.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, color: on ? p.accent : Colors.white, fontWeight: on ? FontWeight.w700 : FontWeight.w500)),
                        ),
                        if (on) Icon(LucideIcons.play, size: 15, color: p.accent),
                      ]),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}

/// Series: season tabs on top, that season's episodes below.
class EpisodesPanel extends StatefulWidget {
  const EpisodesPanel({
    super.key,
    required this.episodes,
    required this.currentId,
    required this.progress,
    required this.onPick,
    required this.onClose,
  });
  final List<EpisodeInfo> episodes;
  final String currentId;

  /// Episode id → saved position (watched / in progress).
  final Map<String, ({double fraction, bool finished})> progress;
  final ValueChanged<EpisodeInfo> onPick;
  final VoidCallback onClose;

  @override
  State<EpisodesPanel> createState() => _EpisodesPanelState();
}

class _EpisodesPanelState extends State<EpisodesPanel> {
  late int season = widget.episodes.where((e) => e.id == widget.currentId).firstOrNull?.season ??
      (widget.episodes.isEmpty ? 1 : widget.episodes.first.season);

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final seasons = {for (final e in widget.episodes) e.season}.toList()..sort();
    final eps = widget.episodes.where((e) => e.season == season).toList()..sort((a, b) => a.episode - b.episode);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Row(children: [
          const Expanded(child: Text('Episodes', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: Colors.white))),
          IconBtn(LucideIcons.x, size: 20, color: Colors.white, tooltip: 'Close', onTap: widget.onClose),
        ]),
      ),
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          children: [
            for (final s in seasons)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Pressable(
                  onTap: () => setState(() => season = s),
                  radius: 18,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                        color: s == season ? p.accent : Colors.white12, borderRadius: BorderRadius.circular(18)),
                    child: Text(s == 0 ? 'Specials' : 'Season $s',
                        style: TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w700, color: s == season ? p.onPill : Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 14),
          itemCount: eps.length,
          itemBuilder: (_, i) {
            final e = eps[i];
            final on = e.id == widget.currentId;
            final pr = widget.progress[e.id];
            final mins = e.durationSecs == null ? null : (e.durationSecs! / 60).round();
            return Pressable(
              onTap: () => widget.onPick(e),
              radius: 12,
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: on ? Colors.white12 : null, borderRadius: BorderRadius.circular(12)),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 128,
                      height: 72,
                      child: Stack(fit: StackFit.expand, children: [
                        ColoredBox(color: Colors.white10, child: NetImage(e.image, fit: BoxFit.cover, placeholderIcon: LucideIcons.clapperboard)),
                        if (pr != null && !pr.finished && pr.fraction > 0)
                          Positioned(left: 0, right: 0, bottom: 0, child: ThinBar(pr.fraction, height: 3)),
                        if (on)
                          Center(child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: Icon(LucideIcons.play, size: 16, color: p.accent),
                          )),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          child: Text('E${e.episode}  ${e.title}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700, color: on ? p.accent : Colors.white)),
                        ),
                        if (pr?.finished ?? false)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle),
                            child: Icon(LucideIcons.check, size: 12, color: p.onPill),
                          ),
                      ]),
                      if (mins != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text('$mins min', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                        ),
                      if ((e.plot ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(e.plot!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.3)),
                        ),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
    ]);
  }
}
