import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/platform.dart';
import '../data/repository.dart';
import '../data/sources/models.dart';
import 'theme.dart';
import 'widgets.dart';

/// Live TV channel row: logo · name + what's on now · replay · ♥ · ⋯
class ChannelCard extends StatelessWidget {
  const ChannelCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavorite,
    required this.onMenu,
    this.now,
    this.selected = false,
    this.onDoubleTap,
    this.onPlay,
  });
  final ItemView item;
  final Programme? now;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  /// Shown as a play button on the selected row.
  final VoidCallback? onPlay;
  final VoidCallback onFavorite;
  final void Function(Offset globalPos) onMenu;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final prog = now;
    return Pressable(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapUp: (d) => onMenu(d.globalPosition),
      radius: 12,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(color: selected ? p.sel : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [
          ChannelLogo(item.icon, width: 58, height: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: prog == null ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isTv ? 16 : 14, height: 1.25, fontWeight: FontWeight.w600, color: p.ink),
                ),
                if (prog != null) ...[
                  const SizedBox(height: 2),
                  Text('${fmtTime(prog.start)}  ${prog.title}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isTv ? 13.5 : 12, color: p.ink2)),
                  const SizedBox(height: 5),
                  ThinBar(prog.progressAt(DateTime.now()), height: 3),
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (item.archiveDays > 0)
            Tooltip(
                message: 'Replay available (${item.archiveDays} days)',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(LucideIcons.history, size: 15, color: p.ink3),
                )),
          if (isTv) ...[
            // A remote gets one stop per row: OK plays, Menu opens the options.
            if (item.isFavorite) Padding(padding: const EdgeInsets.only(left: 6), child: Icon(LucideIcons.heart, size: 18, color: p.live)),
          ] else ...[
          if (selected && onPlay != null)
            IconBtn(LucideIcons.circlePlay, size: 24, pad: 5, tooltip: 'Watch live', onTap: onPlay),
          IconBtn(LucideIcons.heart,
              size: 18,
              pad: 6,
              filled: item.isFavorite,
              color: item.isFavorite ? p.live : p.ink3,
              onTap: onFavorite,
              tooltip: item.isFavorite ? 'Remove from favourites' : 'Add to favourites'),
          Builder(
            builder: (c) => IconBtn(LucideIcons.ellipsis, size: 18, pad: 6, color: p.ink2, tooltip: 'More', onTap: () {
              final box = c.findRenderObject() as RenderBox;
              onMenu(box.localToGlobal(box.size.bottomLeft(Offset.zero)));
            }),
          ),
          ],
        ]),
      ),
    );
  }
}

/// Channel logo on a soft rounded tile.
class ChannelLogo extends StatelessWidget {
  const ChannelLogo(this.url, {super.key, this.width = 58, this.height = 38});
  final String? url;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: p.ghost, borderRadius: BorderRadius.circular(8)),
      child: NetImage(url, fit: BoxFit.contain, placeholderIcon: LucideIcons.tv, cacheWidth: 140, transparent: true),
    );
  }
}

/// Poster card for Series / Movies: rounded artwork, title underneath,
/// grows slightly under the mouse like focus on Apple TV.
class PosterCard extends StatefulWidget {
  const PosterCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavorite,
    required this.onMenu,
    this.progress,
    this.caption,
    this.onRemove,
  });
  final ItemView item;
  final VoidCallback? onRemove;
  final double? progress;
  final String? caption;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final void Function(Offset) onMenu;

  /// Height of the text under the artwork; grids add this to the poster height.
  static const captionHeight = 52.0;

  @override
  State<PosterCard> createState() => _PosterCardState();
}

class _PosterCardState extends State<PosterCard> {
  bool _hover = false;
  bool _focus = false;

  /// Mouse hover on desktop, remote focus on TV: both lift the card.
  bool get hover => _hover || _focus;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final item = widget.item;
    final sub = [
      if (item.year != null) '${item.year}',
      if (item.stars != null) '★ ${(item.stars! * 2).toStringAsFixed(1)}',
    ].join('  ·  ');
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Pressable(
        onFocusChange: isTv ? (f) => setState(() => _focus = f) : null,
        onTap: widget.onTap,
        onSecondaryTapUp: (d) => widget.onMenu(d.globalPosition),
        radius: 12,
        hoverColor: Colors.transparent,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: AnimatedScale(
              scale: hover ? 1.04 : 1,
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: hover ? 0.45 : 0.18),
                      blurRadius: hover ? 22 : 6,
                      offset: Offset(0, hover ? 10 : 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(fit: StackFit.expand, children: [
                    NetImage(item.icon, placeholderIcon: LucideIcons.clapperboard, cacheWidth: 360),
                    AnimatedOpacity(
                      opacity: hover ? 1 : 0,
                      duration: const Duration(milliseconds: 140),
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [Color(0x99000000), Color(0x00000000)]),
                        ),
                      ),
                    ),
                    if (isTv && item.isFavorite)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Icon(LucideIcons.heart, size: 20, color: p.live),
                      ),
                    if (!isTv && (hover || item.isFavorite))
                      Positioned(
                        left: 2,
                        top: 2,
                        child: IconBtn(LucideIcons.heart,
                            filled: item.isFavorite,
                            color: item.isFavorite ? p.live : Colors.white,
                            tooltip: item.isFavorite ? 'Remove from favourites' : 'Add to favourites',
                            onTap: widget.onFavorite,
                            size: 19,
                            pad: 7),
                      ),
                    if (!isTv && hover && widget.onRemove != null)
                      Positioned(
                        right: 34,
                        top: 2,
                        child: IconBtn(LucideIcons.x,
                            color: Colors.white, size: 20, pad: 7, tooltip: 'Remove from recently watched', onTap: widget.onRemove),
                      ),
                    if (!isTv && hover)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Builder(
                          builder: (c) => IconBtn(LucideIcons.ellipsis, color: Colors.white, size: 20, pad: 7, tooltip: 'More',
                              onTap: () {
                            final box = c.findRenderObject() as RenderBox;
                            widget.onMenu(box.localToGlobal(box.size.bottomLeft(Offset.zero)));
                          }),
                        ),
                      ),
                    if (widget.progress != null && widget.progress! > 0)
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: ThinBar(widget.progress!, height: 4, color: Colors.white, track: Colors.white30),
                      ),
                  ]),
                ),
              ),
            ),
          ),
          SizedBox(
            height: PosterCard.captionHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 9, 2, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.caption ?? item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isTv ? 15 : 13, height: 1.25, color: p.ink, fontWeight: FontWeight.w500)),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(sub, maxLines: 1, style: TextStyle(fontSize: 11.5, color: p.ink2)),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Logo tile with the channel name underneath (Live TV "Recently watched").
class LogoTile extends StatefulWidget {
  const LogoTile({super.key, required this.icon, required this.label, required this.onTap, this.onMenu, this.onRemove});
  final String? icon;
  final String label;
  final VoidCallback onTap;
  final void Function(Offset)? onMenu;
  final VoidCallback? onRemove;

  @override
  State<LogoTile> createState() => _LogoTileState();
}

class _LogoTileState extends State<LogoTile> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: Tooltip(
        message: 'Watch ${widget.label}',
        child: Pressable(
          onTap: widget.onTap,
          onSecondaryTapUp: widget.onMenu == null ? null : (d) => widget.onMenu!(d.globalPosition),
          radius: 12,
          child: SizedBox(
            width: 96,
            child: Column(children: [
              Stack(children: [
                Container(
                  height: 58,
                  width: 96,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: p.card, borderRadius: BorderRadius.circular(12)),
                  child: NetImage(widget.icon, fit: BoxFit.contain, placeholderIcon: LucideIcons.tv, cacheWidth: 160, transparent: true),
                ),
                if (hover && widget.onRemove != null)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: RemoveChip(onTap: widget.onRemove!),
                  ),
              ]),
              const SizedBox(height: 5),
              Text(widget.label,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: p.ink2)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Small round "x" shown over a card on hover to drop it from a recently-watched row.
class RemoveChip extends StatelessWidget {
  const RemoveChip({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Remove from recently watched',
        child: GestureDetector(
          onTap: onTap,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(color: Color(0xCC000000), shape: BoxShape.circle),
              child: const Icon(LucideIcons.x, size: 14, color: Colors.white),
            ),
          ),
        ),
      );
}
