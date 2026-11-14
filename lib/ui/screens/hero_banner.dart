import '../../core/platform.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/database/schema.dart';
import '../../data/repository.dart';
import '../../data/sources/models.dart';
import '../../state/app_state.dart';
import '../navigation.dart';
import '../player/play_request.dart';
import '../theme.dart';
import '../widgets.dart';

/// Backdrops already looked up this session (movie id → url or null).
final Map<String, String?> _backdrops = {};

/// "Continue watching" banner at the top of Movies and Series.
class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key, required this.item, required this.watch, this.padding});
  final ItemView item;
  final EdgeInsets? padding;

  /// The movie's watch row, or the last watched episode of the series.
  final WatchRow watch;

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  late final AppState state = AppScope.read(context);
  String? backdrop;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _loadBackdrop();
  }

  @override
  void didUpdateWidget(HeroBanner old) {
    super.didUpdateWidget(old);
    if (old.item.key != widget.item.key) {
      backdrop = null;
      _loadBackdrop();
    }
  }

  Future<void> _loadBackdrop() async {
    final it = widget.item;
    if (_backdrops.containsKey(it.key)) {
      setState(() => backdrop = _backdrops[it.key]);
      return;
    }
    try {
      final src = await state.repo.source(it.sourceId);
      if (src == null) return;
      String? b;
      if (it.type == ContentType.movie) {
        b = (await state.catalog.movieDetail(src, it))?.backdrop;
      } else {
        b = (await state.repo.seriesDetail(src.id, it.id))?.$1.backdrop;
      }
      _backdrops[it.key] = b;
      if (mounted) setState(() => backdrop = b);
    } catch (_) {
      _backdrops[it.key] = null;
    }
  }

  Duration get _pos => Duration(milliseconds: widget.watch.positionMs);

  Future<void> _play({required bool fromStart}) async {
    final it = widget.item;
    final start = fromStart ? Duration.zero : _pos;
    if (it.type == ContentType.movie) {
      await openPlayer(context, PlayRequest.movie(it, start: start));
      return;
    }
    setState(() => busy = true);
    try {
      final src = await state.repo.source(it.sourceId);
      if (src == null || !mounted) return;
      final d = await state.catalog.seriesDetail(src, it);
      final ep = d.episodes.where((e) => e.id == widget.watch.itemId).firstOrNull;
      if (!mounted) return;
      if (ep == null) {
        openItem(context, it);
        return;
      }
      await openPlayer(context, PlayRequest.episode(it, d, ep, start: start));
    } catch (e) {
      if (mounted) toast(context, 'Could not load the episodes: $e', error: true);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final it = widget.item;
    final w = widget.watch;
    final left = w.durationMs > 0 ? Duration(milliseconds: w.durationMs - w.positionMs) : null;
    final frac = w.durationMs > 0 ? w.positionMs / w.durationMs : null;
    final episode = it.type == ContentType.series && w.season != null ? 'S${w.season} E${w.episode}' : null;
    final meta = [
      ?episode,
      if (it.year != null) '${it.year}',
      if (left != null && left.inMinutes > 0) '${left.inMinutes} min left',
    ].join('  ·  ');
    const white2 = Color(0xB3FFFFFF);
    return Padding(
      padding: widget.padding ?? EdgeInsets.fromLTRB(context.gutter, 4, context.gutter, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 300,
          child: Stack(fit: StackFit.expand, children: [
            if (backdrop != null)
              NetImage(backdrop, cacheWidth: 1600)
            else
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40, tileMode: TileMode.clamp),
                child: Transform.scale(scale: 1.3, child: NetImage(it.icon, cacheWidth: 300)),
              ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xE6000000), Color(0x99000000), Color(0x00000000)],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (backdrop == null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(width: 160, height: 240, child: NetImage(it.icon, cacheWidth: 320)),
                  ),
                  const SizedBox(width: 26),
                ],
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    const Text('CONTINUE WATCHING',
                        style: TextStyle(color: white2, fontSize: 11.5, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                    const SizedBox(height: 6),
                    Text(it.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.8, height: 1.1)),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(meta, style: const TextStyle(color: white2, fontSize: 13)),
                    ],
                    const SizedBox(height: 18),
                    Theme(
                      // The banner is always dark, so use the dark palette for its buttons.
                      data: buildTheme(Brightness.dark),
                      child: Row(children: [
                        PrimaryButton(
                          label: w.positionMs > 15000 ? 'Resume' : 'Play',
                          icon: LucideIcons.play,
                          busy: busy,
                          onPressed: () => _play(fromStart: false),
                        ),
                        const SizedBox(width: 10),
                        if (w.positionMs > 15000) ...[
                          GhostButton(label: 'Start over', icon: LucideIcons.rotateCcw, onPressed: () => _play(fromStart: true)),
                          const SizedBox(width: 10),
                        ],
                        GhostButton(label: 'Details', onPressed: () => openItem(context, it)),
                        const SizedBox(width: 10),
                        RoundIconButton(
                          LucideIcons.heart,
                          filled: it.isFavorite,
                          color: it.isFavorite ? p.live : Colors.white,
                          tooltip: it.isFavorite ? 'Remove from favourites' : 'Add to favourites',
                          onTap: () => state.repo.toggleFavorite(it.sourceId, it.type, it.id),
                        ),
                        if (frac != null) ...[
                          const SizedBox(width: 22),
                          SizedBox(width: 140, child: ThinBar(frac, height: 4, color: Colors.white, track: Colors.white30)),
                        ],
                      ]),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
