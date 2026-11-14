import 'dart:ui' show PointerDeviceKind;
import 'package:flutter/material.dart';
import '../core/disk_image.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_drawing/path_drawing.dart';

import '../core/platform.dart';
import 'theme.dart';

/// Rounded "pill" text button (segmented-style navigation).
class NavPill extends StatelessWidget {
  const NavPill({super.key, required this.label, required this.active, required this.onTap, this.icon});
  final String label;
  final bool active;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final fg = active ? p.onPill : p.ink3;
    return Pressable(
      onTap: onTap,
      radius: 40,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(color: active ? p.pill : Colors.transparent, borderRadius: BorderRadius.circular(40)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 7)],
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
        ]),
      ),
    );
  }
}

/// One entry of the main sidebar.
class SidebarItem extends StatelessWidget {
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.compact = false,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final bool active;
  final bool compact;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final fg = active ? p.ink : p.ink2;
    return Pressable(
      onTap: onTap,
      radius: 9,
      tooltip: compact ? label : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 10),
        decoration: BoxDecoration(color: active ? p.sel : Colors.transparent, borderRadius: BorderRadius.circular(9)),
        child: compact
            ? Center(child: Icon(icon, size: 20, color: fg))
            : Row(children: [
                Icon(icon, size: 19, color: fg),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: fg, fontWeight: active ? FontWeight.w600 : FontWeight.w500)),
                ),
                ?trailing,
              ]),
      ),
    );
  }
}

/// Red "LIVE" / grey "REPLAY" tag.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.label = 'LIVE', this.color});
  final String label;
  final Color? color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: color ?? context.pal.live, borderRadius: BorderRadius.circular(5)),
        child: Text(label,
            style: TextStyle(
                color: color == null ? context.pal.onPill : Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4)),
      );
}

/// Thin rounded progress bar (now playing, resume position).
/// A slider that a remote can use: on TV it is a minus button, a bar and a plus button
/// (a plain Slider would keep Up/Down for itself and trap the focus).
class StepSlider extends StatelessWidget {
  const StepSlider({super.key, required this.value, required this.min, required this.max, required this.onChanged, this.step = 1});
  final double value, min, max, step;
  final ValueChanged<double> onChanged;
  @override
  Widget build(BuildContext context) {
    if (!isTv) return Slider(value: value.clamp(min, max), min: min, max: max, onChanged: onChanged);
    final p = context.pal;
    return Row(children: [
      IconBtn(LucideIcons.minus, color: p.ink, onTap: () => onChanged((value - step).clamp(min, max))),
      Expanded(child: ThinBar(((value - min) / (max - min)).clamp(0.0, 1.0), height: 5, color: p.accent)),
      IconBtn(LucideIcons.plus, color: p.ink, onTap: () => onChanged((value + step).clamp(min, max))),
    ]);
  }
}

class ThinBar extends StatelessWidget {
  const ThinBar(this.value, {super.key, this.height = 3, this.color, this.track});
  final double value;
  final double height;
  final Color? color;
  final Color? track;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(children: [
          Positioned.fill(child: ColoredBox(color: track ?? p.ghost)),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: ColoredBox(color: color ?? p.ink),
          ),
        ]),
      ),
    );
  }
}

/// Hover + click feedback without Material ripples (matches the reference).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onSecondaryTapUp,
    this.radius = 8,
    this.hoverColor,
    this.tooltip,
    this.onDoubleTap,
    this.focusable = true,
    this.onFocusChange,
    this.focusNode,
    this.autofocus = false,
  });
  final bool autofocus;
  final bool focusable;
  final ValueChanged<bool>? onFocusChange;
  final FocusNode? focusNode;
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final GestureTapUpCallback? onSecondaryTapUp;
  final double radius;
  final Color? hoverColor;
  final String? tooltip;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _focused = false;

  /// Remote "Menu" key = right-click: opens the item's context menu where it has one.
  void _menu() {
    final cb = widget.onSecondaryTapUp;
    final box = context.findRenderObject();
    if (cb == null || box is! RenderBox) return;
    final pos = box.localToGlobal(box.size.center(Offset.zero));
    cb(TapUpDetails(kind: PointerDeviceKind.unknown, globalPosition: pos, localPosition: box.size.center(Offset.zero)));
  }

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final active = widget.onTap != null || widget.onDoubleTap != null;
    Widget w = FocusableActionDetector(
      enabled: active && widget.focusable,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      mouseCursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onShowHoverHighlight: (v) => setState(() => _hover = v),
      onShowFocusHighlight: (v) {
        setState(() => _focused = v);
        widget.onFocusChange?.call(v);
      },
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
          // A remote has no double-click: where a row has one (play), OK does that.
          (isTv ? (widget.onDoubleTap ?? widget.onTap) : (widget.onTap ?? widget.onDoubleTap))?.call();
          return null;
        }),
        _MenuIntent: CallbackAction<_MenuIntent>(onInvoke: (_) {
          _menu();
          return null;
        }),
      },
      shortcuts: const {SingleActivator(LogicalKeyboardKey.contextMenu): _MenuIntent()},
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Touch has no double-click: a tap does the "open" action directly, a long press the menu.
        onTap: isTouch ? (widget.onDoubleTap ?? widget.onTap) : widget.onTap,
        onDoubleTap: isTouch ? null : widget.onDoubleTap,
        onSecondaryTapUp: widget.onSecondaryTapUp,
        onLongPressStart: isTouch && widget.onSecondaryTapUp != null
            ? (d) => widget.onSecondaryTapUp!(TapUpDetails(
                kind: PointerDeviceKind.touch, globalPosition: d.globalPosition, localPosition: d.localPosition))
            : null,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            border: _focused ? Border.all(color: context.pal.accent, width: 3) : null,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: (_hover || _focused) && widget.onTap != null
                  ? (widget.hoverColor ?? p.ink.withValues(alpha: 0.05))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
    if (widget.tooltip != null && !isTv && !isTouch) w = Tooltip(message: widget.tooltip!, child: w);
    return w;
  }
}

class _MenuIntent extends Intent {
  const _MenuIntent();
}

/// Rounded chip used in toolbars (Sort, ♥, Replay, language chips).
class OutlineBox extends StatelessWidget {
  const OutlineBox({
    super.key,
    required this.child,
    this.onTap,
    this.selected = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 12),
    this.height = 32,
    this.tooltip,
  });
  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final EdgeInsets padding;
  final double height;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final fg = selected ? p.onPill : p.ink;
    final height = isTouch && this.height < 40 ? 40.0 : this.height;
    return Pressable(
      onTap: onTap,
      radius: height / 2,
      tooltip: tooltip,
      hoverColor: selected ? Colors.transparent : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? p.pill : p.ghost,
          borderRadius: BorderRadius.circular(height / 2),
        ),
        // widthFactor 1: hug the content instead of filling the row.
        child: Align(
          widthFactor: 1,
          child: IconTheme.merge(
            data: IconThemeData(color: fg, size: 16),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fg, fontWeight: FontWeight.w500, fontSize: 13),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// White (dark mode) / black (light mode) pill — one main action per view.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.busy = false,
    this.expand = false,
    this.height = 40,
    this.danger = false,
    this.autofocus = false,
    this.focusNode,
  });
  /// On TV the main action starts focused, so the first OK does it.
  final bool autofocus;
  final FocusNode? focusNode;
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;
  final bool expand;
  final double height;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final enabled = onPressed != null && !busy;
    final bg = danger ? p.danger : p.pill;
    final fg = danger ? Colors.white : p.onPill;
    return Opacity(
      opacity: enabled || busy ? 1 : 0.4,
      child: Pressable(
        onTap: enabled ? onPressed : null,
        autofocus: autofocus && isTv,
        focusNode: focusNode,
        radius: height / 2,
        hoverColor: Colors.transparent,
        child: _HoverScale(
          enabled: enabled,
          child: Container(
            height: height,
            width: expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: height * 0.45),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(height / 2)),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (busy)
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                else if (icon != null)
                  Icon(icon, color: fg, size: 19),
                if (busy || icon != null) const SizedBox(width: 7),
                Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Grows a little under the mouse, like focus on Apple TV.
class _HoverScale extends StatefulWidget {
  const _HoverScale({required this.child, this.enabled = true});
  final Widget child;
  final bool enabled;
  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool h = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => h = true),
        onExit: (_) => setState(() => h = false),
        child: AnimatedScale(
          scale: h && widget.enabled ? 1.04 : 1,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

/// Secondary translucent pill button.
class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, this.icon, this.onPressed, this.height = 40});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Opacity(
      opacity: onPressed == null ? 0.4 : 1,
      child: Pressable(
        onTap: onPressed,
        radius: height / 2,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: height * 0.4),
          decoration: BoxDecoration(color: p.ghost, borderRadius: BorderRadius.circular(height / 2)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 7)],
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round translucent icon button (♥ next to Play, player controls).
class RoundIconButton extends StatelessWidget {
  const RoundIconButton(this.icon, {super.key, this.onTap, this.tooltip, this.size = 40, this.color, this.bg, this.filled = false});
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final Color? color;
  final Color? bg;
  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Pressable(
      onTap: onTap,
      radius: size / 2,
      tooltip: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg ?? p.ghost, shape: BoxShape.circle),
        child: filled ? FilledHeart(size: size * 0.5, color: color) : Icon(icon, size: size * 0.48, color: color ?? p.ink),
      ),
    );
  }
}

/// Small icon button with hover.
class IconBtn extends StatelessWidget {
  const IconBtn(this.icon,
      {super.key, this.onTap, this.tooltip, this.size = 20, this.color, this.pad = 7, this.filled = false, this.focusNode});
  final IconData icon;
  final FocusNode? focusNode;

  /// Shows the solid heart (for a favourite). Only used with the heart icon.
  final bool filled;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final Color? color;
  final double pad;

  @override
  Widget build(BuildContext context) => Pressable(
    onTap: onTap,
    focusNode: focusNode,
    radius: 30,
    tooltip: tooltip,
    child: ConstrainedBox(
      // Fingers need at least a 44 px target.
      constraints: BoxConstraints(minWidth: isTouch ? 44 : 0, minHeight: isTouch ? 44 : 0),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: filled ? FilledHeart(size: size, color: color) : Icon(icon, size: size, color: color ?? context.pal.ink),
        ),
      ),
    ),
  );
}

/// 5-star rating from a 0..5 value (half stars supported).
class Stars extends StatelessWidget {
  const Stars(this.value, {super.key, this.size = 13});
  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            value >= i + 0.75
                ? LucideIcons.star
                : value >= i + 0.25
                ? LucideIcons.starHalf
                : LucideIcons.star,
            size: size,
            color: value >= i + 0.25 ? p.star : p.starEmpty,
          ),
      ],
    );
  }
}

/// Network image with a neutral placeholder and graceful failure.
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.placeholderIcon = LucideIcons.image,
    this.cacheWidth,
    this.transparent = false,
  });
  final String? url;
  final BoxFit fit;
  final IconData placeholderIcon;
  final int? cacheWidth;

  /// Placeholder without a background (when the parent draws a tile).
  final bool transparent;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final ph = Container(
      color: transparent ? null : p.ghost,
      alignment: Alignment.center,
      child: Icon(placeholderIcon, color: p.ink3, size: 22),
    );
    final u = url;
    if (u == null || u.isEmpty || !(u.startsWith('http://') || u.startsWith('https://'))) {
      return ph;
    }
    final provider = DiskCachedImage(u);
    return Image(
      image: cacheWidth == null ? provider : ResizeImage(provider, width: cacheWidth),
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, _, _) => ph,
      frameBuilder: (_, child, frame, sync) => frame == null && !sync ? ph : child,
    );
  }
}

/// Section title (Home "Sources", shelves).
class RuledHeader extends StatelessWidget {
  const RuledHeader(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 19, letterSpacing: -0.3)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A settings row: icon, title, subtitle, trailing (chevron/switch).
/// Sits inside a [PaneSection] card.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.danger = false,
    this.chevron,
  });
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;
  final bool? chevron;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final color = danger ? p.danger : p.ink;
    final showChevron = chevron ?? (trailing == null && onTap != null && !danger);
    return Pressable(
      onTap: onTap,
      radius: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 19, color: danger ? p.danger : p.ink2), const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, color: color)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: TextStyle(fontSize: 12, color: p.ink2, height: 1.35)),
                    ],
                  ],
                ),
              ),
              ?trailing,
              if (showChevron) Icon(LucideIcons.chevronRight, color: p.ink3, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => SettingsRow(
    title: title,
    subtitle: subtitle,
    icon: icon,
    onTap: () => onChanged(!value),
    trailing: Transform.scale(
      scale: 0.72,
      child: Switch(value: value, onChanged: onChanged),
    ),
  );
}

/// Grouped settings section: small heading, then the rows in a rounded card.
class PaneSection extends StatelessWidget {
  const PaneSection(this.title, {super.key, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(Divider(height: 0.5, thickness: 0.5, indent: 16, color: p.border));
      rows.add(children[i]);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 7),
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: p.ink2)),
          ),
          if (rows.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Material(
                color: p.card,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
              ),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.message, this.action});
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: p.ink3),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -0.3),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: p.ink2, height: 1.4),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

/// Apple-style segmented control.
class Segmented<T> extends StatelessWidget {
  const Segmented({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.height = 32,
    this.check = false,
  });
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;
  final bool check;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      height: isTouch && height < 40 ? 40 : height,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: p.ghost, borderRadius: BorderRadius.circular(9)),
      child: Row(
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Pressable(
                onTap: () => onChanged(values[i]),
                radius: 7,
                hoverColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  decoration: BoxDecoration(
                    color: values[i] == selected ? p.pill : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    labels[i],
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: values[i] == selected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 13,
                      color: values[i] == selected ? p.onPill : p.ink2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void toast(BuildContext context, String message, {bool error = false}) {
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m.hideCurrentSnackBar();
  m.showSnackBar(
    SnackBar(
      content: Text(message, style: error ? TextStyle(color: context.pal.onPill) : null),
      backgroundColor: error ? context.pal.danger : null,
      duration: Duration(seconds: error ? 6 : 3),
    ),
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String message,
  String action = 'Delete',
  bool danger = true,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Text(message)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(action, style: TextStyle(color: danger ? c.pal.danger : c.pal.ink)),
        ),
      ],
    ),
  );
  return r ?? false;
}

Future<String?> promptText(
  BuildContext context, {
  required String title,
  String? initial,
  String label = 'Name',
  String action = 'Save',
}) {
  final ctl = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: context.dialogW(380),
        child: TvEditGate(child: TextField(
          controller: ctl,
          autofocus: true,
          decoration: InputDecoration(labelText: label),
          onSubmitted: (v) => Navigator.pop(c, v.trim().isEmpty ? null : v.trim()),
        )),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.pop(c, ctl.text.trim().isEmpty ? null : ctl.text.trim()),
          child: Text(action),
        ),
      ],
    ),
  );
}

/// Options dialog returning the chosen value.
Future<T?> pickOption<T>(
  BuildContext context, {
  required String title,
  required List<(T, String)> options,
  T? current,
}) {
  return showDialog<T>(
    context: context,
    builder: (c) => SimpleDialog(
      title: Text(title),
      children: [
        for (final (v, label) in options)
          Pressable(
            onTap: () => Navigator.pop(c, v),
            radius: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                      width: 22,
                      child: v == current ? Icon(LucideIcons.check, size: 19, color: c.pal.accent) : null),
                  const SizedBox(width: 10),
                  Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

String fmtDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}

String two(int v) => v.toString().padLeft(2, '0');
String fmtTime(DateTime t) {
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  return '$h:${two(t.minute)} ${t.hour >= 12 ? 'PM' : 'AM'}';
}
String fmtDateTime(DateTime t) => '${two(t.day)}/${two(t.month)}/${t.year} – ${fmtTime(t)}';

/// Large page title used at the top of each main page.
class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.subtitle, this.trailing = const [], this.padding});
  final String title;
  final String? subtitle;
  final List<Widget> trailing;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(context.gutter, 0, context.gutter, 14),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6, height: 1.15)),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle!, style: TextStyle(fontSize: 13, color: p.ink2)),
              ),
          ]),
        ),
        for (var i = 0; i < trailing.length; i++) ...[if (i > 0) const SizedBox(width: 8), trailing[i]],
      ]),
    );
  }
}

/// Shelf title: bold text with an optional trailing action.
class ShelfTitle extends StatelessWidget {
  const ShelfTitle(this.text, {super.key, this.trailing, this.padding});
  final String text;
  final Widget? trailing;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? EdgeInsets.fromLTRB(context.gutter, context.compact ? 16 : 22, context.gutter, 10),
        child: Row(children: [
          Expanded(
              child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3))),
          ?trailing,
        ]),
      );
}

/// Blue checkmark for the selected option in a list (empty space otherwise).
class CheckMark extends StatelessWidget {
  const CheckMark(this.on, {super.key, this.size = 19});
  final bool on;
  final double size;
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: size + 4, child: on ? Icon(LucideIcons.check, size: size, color: context.pal.accent) : null);
}


/// Solid version of the Lucide heart (Lucide itself only ships the outline), drawn from the same
/// path so it matches the rest of the icons. A thin dark edge keeps it visible on bright artwork.
class FilledHeart extends StatelessWidget {
  const FilledHeart({super.key, this.size = 20, this.color});
  final double size;
  final Color? color;

  static final Path _path = parseSvgPathData(
      'M2 9.5a5.5 5.5 0 0 1 9.591-3.676.56.56 0 0 0 .818 0A5.49 5.49 0 0 1 22 9.5c0 2.29-1.5 4-3 5.5l-5.492 5.313a2 2 0 0 1-3 .019L5 15c-1.5-1.5-3-3.2-3-5.5Z');

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HeartPainter(_path, color ?? p.accent, p.bg)),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter(this.path, this.fill, this.edge);
  final Path path;
  final Color fill, edge;

  @override
  void paint(Canvas canvas, Size size) {
    // The icon grid is 24x24 with a 2 px stroke, so the shape spans about 2..22.
    final k = size.width / 24;
    final scaled = path.transform(Matrix4.diagonal3Values(k, k, 1).storage);
    canvas.drawPath(
        scaled,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6 * k
          ..strokeJoin = StrokeJoin.round
          ..color = edge.withValues(alpha: 0.85));
    canvas.drawPath(scaled, Paint()..style = PaintingStyle.fill..color = fill);
    canvas.drawPath(
        scaled,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2 * k
          ..strokeJoin = StrokeJoin.round
          ..color = fill);
  }

  @override
  bool shouldRepaint(_HeartPainter old) => old.fill != fill || old.edge != edge;
}
