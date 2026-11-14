import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/platform.dart';

import '../../data/repository.dart';
import '../../state/app_state.dart';
import '../item_actions.dart';
import '../theme.dart';
import '../widgets.dart';

/// Header shared by movie and series detail pages: backdrop, poster, facts.
class DetailHeader extends StatelessWidget {
  const DetailHeader({
    super.key,
    required this.item,
    this.backdrop,
    this.plot,
    this.facts = const [],
    this.actions = const [],
    this.rating,
  });
  final ItemView item;
  final String? backdrop;
  final String? plot;
  final List<(String, String)> facts;
  final List<Widget> actions;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final state = AppScope.of(context);
    final stars = rating != null ? (rating! / 2).clamp(0.0, 5.0) : item.stars;
    final meta = [
      if (item.year != null) '${item.year}',
      if (stars != null) '★ ${(stars * 2).toStringAsFixed(1)}',
      for (final (k, v) in facts)
        if ((k == 'Genre' || k == 'Duration') && v.trim().isNotEmpty) v.trim(),
    ];
    final art = backdrop ?? item.icon;
    final compact = context.compact;
    final poster = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
            width: compact ? 150 : 220, height: compact ? 225 : 330, child: NetImage(item.icon, cacheWidth: 440)),
      ),
    );
    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(item.name,
          style: TextStyle(fontSize: compact ? 24 : 34, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.8)),
      if (meta.isNotEmpty) ...[
        const SizedBox(height: 8),
        Text(meta.join('  ·  '), style: TextStyle(color: p.ink2, fontSize: 13.5)),
      ],
      const SizedBox(height: 18),
      Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
        ...actions,
        RoundIconButton(
          LucideIcons.heart,
          filled: item.isFavorite,
          color: item.isFavorite ? p.live : null,
          tooltip: item.isFavorite ? 'Remove from favourites' : 'Add to favourites',
          onTap: () => state.repo.toggleFavorite(item.sourceId, item.type, item.id),
        ),
        RoundIconButton(
          LucideIcons.listPlus,
          tooltip: 'Add to group',
          onTap: () => showGroupPicker(context, item),
        ),
      ]),
      if (plot != null && plot!.trim().isNotEmpty) ...[
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(plot!.trim(), style: TextStyle(height: 1.5, color: p.ink, fontSize: 14)),
        ),
      ],
      const SizedBox(height: 14),
      for (final (k, v) in facts)
        if (v.trim().isNotEmpty && k != 'Genre' && k != 'Duration')
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Text.rich(TextSpan(style: const TextStyle(fontSize: 13), children: [
                TextSpan(text: '$k  ', style: TextStyle(color: p.ink3, fontWeight: FontWeight.w600)),
                TextSpan(text: v.trim(), style: TextStyle(color: p.ink2)),
              ])),
            ),
          ),
    ]);
    return Stack(children: [
      if (art != null)
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (r) => LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withValues(alpha: backdrop != null ? 0.55 : 0.3), Colors.transparent],
              stops: const [0.2, 1],
            ).createShader(r),
            blendMode: BlendMode.dstIn,
            child: backdrop != null
                ? NetImage(backdrop, fit: BoxFit.cover, cacheWidth: 1600)
                : ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40, tileMode: TileMode.clamp),
                    child: NetImage(item.icon, fit: BoxFit.cover, cacheWidth: 300),
                  ),
          ),
        ),
      Padding(
        padding: compact ? const EdgeInsets.fromLTRB(16, 16, 16, 20) : const EdgeInsets.fromLTRB(36, 30, 36, 24),
        child: compact
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: poster),
                const SizedBox(height: 20),
                info,
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                poster,
                const SizedBox(width: 34),
                Expanded(child: info),
              ]),
      ),
    ]);
  }
}

/// Top bar with a back button for pushed pages. Leaves room for the window
/// buttons and drags the window.
class BackBar extends StatelessWidget {
  const BackBar({super.key, required this.title, this.trailing = const []});
  final String title;
  final List<Widget> trailing;
  @override
  Widget build(BuildContext context) {
    return WindowDragArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(isTouch ? 8 : windowButtonsInset, 8, isTouch ? 12 : 20, 8),
        child: SizedBox(
          height: 36,
          child: Row(children: [
            RoundIconButton(LucideIcons.chevronLeft, size: 32, tooltip: 'Back', onTap: () => Navigator.maybePop(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            ...trailing,
          ]),
        ),
      ),
    );
  }
}

/// Re-reads the item (for the ♥ state) whenever user data changes.
class LiveItem extends StatelessWidget {
  const LiveItem({super.key, required this.item, required this.builder});
  final ItemView item;
  final Widget Function(BuildContext, ItemView) builder;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: state.revision,
      builder: (context, _, _) => FutureBuilder<ItemView?>(
        future: state.repo.item(item.sourceId, item.type, item.id),
        initialData: item,
        builder: (context, snap) => builder(context, snap.data ?? item),
      ),
    );
  }
}
