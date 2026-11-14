import 'package:flutter/material.dart';

/// Semantic colours: the TVflow design tokens.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.bg,
    required this.pane,
    required this.card,
    required this.cardHover,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.border,
    required this.rule,
    required this.field,
    required this.pill,
    required this.onPill,
    required this.danger,
    required this.star,
    required this.starEmpty,
    required this.live,
    required this.overlay,
    required this.side,
    required this.sel,
    required this.ghost,
    required this.raised,
    required this.accent,
  });

  final Color bg, pane, card, cardHover, ink, ink2, ink3, border, rule, field;
  final Color pill, onPill, danger, star, starEmpty, live, overlay;

  /// Sidebar background.
  final Color side;

  /// Selected row / nav item fill.
  final Color sel;

  /// Translucent fill for chips and secondary buttons.
  final Color ghost;

  /// Menus, dialogs and other floating surfaces.
  final Color raised;

  /// Electric yellow, for switches, links and focus.
  final Color accent;

  /// TVflow "Midnight Glass" palette (brand/TV_FLOW_BRAND_AND_UI_DESIGN_SYSTEM.md, section 2). Dark only.
  static const brand = Palette(
    bg: Color(0xFF080D0F),
    pane: Color(0xFF101A1D),
    card: Color(0xFF20383D),
    cardHover: Color(0xFF294D53),
    ink: Color(0xFFFFFFFF),
    ink2: Color(0xFFB8C4C5),
    ink3: Color(0xFF66777A),
    border: Color(0x24FFFFFF),
    rule: Color(0x24FFFFFF),
    field: Color(0xFF17272B),
    pill: Color(0xFFF5C400),
    onPill: Color(0xFF080D0F),
    danger: Color(0xFFF05A5A),
    star: Color(0xFFF5C400),
    starEmpty: Color(0xFF294D53),
    live: Color(0xFFFF4545),
    overlay: Color(0xCC080D0F),
    side: Color(0xFF101A1D),
    sel: Color(0xFF294D53),
    ghost: Color(0xFF20383D),
    raised: Color(0xFF17272B),
    accent: Color(0xFFF5C400),
  );


  static const light = brand;
  static const dark = brand;

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) {
    if (other is! Palette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      bg: l(bg, other.bg),
      pane: l(pane, other.pane),
      card: l(card, other.card),
      cardHover: l(cardHover, other.cardHover),
      ink: l(ink, other.ink),
      ink2: l(ink2, other.ink2),
      ink3: l(ink3, other.ink3),
      border: l(border, other.border),
      rule: l(rule, other.rule),
      field: l(field, other.field),
      pill: l(pill, other.pill),
      onPill: l(onPill, other.onPill),
      danger: l(danger, other.danger),
      star: l(star, other.star),
      starEmpty: l(starEmpty, other.starEmpty),
      live: l(live, other.live),
      overlay: l(overlay, other.overlay),
      side: l(side, other.side),
      sel: l(sel, other.sel),
      ghost: l(ghost, other.ghost),
      raised: l(raised, other.raised),
      accent: l(accent, other.accent),
    );
  }
}

extension PaletteX on BuildContext {
  Palette get pal => Theme.of(this).extension<Palette>()!;
}

/// Typography: Inter everywhere (design system, section 3).
abstract class Fonts {
  /// Kept for call sites that used a condensed face; now the system font.
  static const String? condensed = null;

  /// Inter, bundled with the app.
  static const String? ui = 'Inter';
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Palette.dark : Palette.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: p.accent,
    onPrimary: p.onPill,
    secondary: p.pill,
    onSecondary: p.onPill,
    error: p.danger,
    onError: p.onPill,
    surface: p.bg,
    onSurface: p.ink,
    onSurfaceVariant: p.ink2,
    outline: p.border,
    surfaceContainerHighest: p.raised,
    surfaceContainerHigh: p.raised,
    surfaceContainer: p.card,
    surfaceContainerLow: p.card,
  );
  OutlineInputBorder ob(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    fontFamily: Fonts.ui,
    scaffoldBackgroundColor: p.bg,
    canvasColor: p.bg,
    dividerColor: p.border,
    dividerTheme: DividerThemeData(color: p.border, thickness: 0.5, space: 1),
    splashFactory: NoSplash.splashFactory,
    hoverColor: p.ink.withValues(alpha: 0.05),
    highlightColor: Colors.transparent,
    extensions: [p],
    iconTheme: IconThemeData(color: p.ink, size: 20),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent, selectionColor: p.accent.withValues(alpha: 0.3)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.field,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      hintStyle: TextStyle(color: p.ink3, fontSize: 14),
      labelStyle: TextStyle(color: p.ink2, fontSize: 14),
      floatingLabelStyle: TextStyle(color: p.ink2, fontSize: 13),
      border: ob(Colors.transparent),
      enabledBorder: ob(Colors.transparent),
      focusedBorder: ob(p.accent, 2),
      errorBorder: ob(p.danger),
      focusedErrorBorder: ob(p.danger, 2),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.ghost),
      thumbColor: WidgetStatePropertyAll(p.ink),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      thumbIcon: const WidgetStatePropertyAll(null),
    ),
    radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? p.accent : p.ink3)),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : Colors.transparent),
      checkColor: WidgetStatePropertyAll(p.onPill),
      side: BorderSide(color: p.ink3, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.raised,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), side: BorderSide(color: p.border, width: 0.5)),
      textStyle: TextStyle(color: p.ink, fontSize: 13.5, fontFamily: Fonts.ui),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(p.raised),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titleTextStyle: TextStyle(
          color: p.ink, fontSize: 19, fontWeight: FontWeight.w600, fontFamily: Fonts.ui, letterSpacing: -0.3),
      contentTextStyle: TextStyle(color: p.ink2, fontSize: 14, height: 1.4, fontFamily: Fonts.ui),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: p.accent,
      unselectedLabelColor: p.ink2,
      indicatorColor: p.accent,
      dividerColor: p.border,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.raised,
      contentTextStyle: TextStyle(color: p.ink, fontFamily: Fonts.ui, fontSize: 13.5),
      actionTextColor: p.accent,
      behavior: SnackBarBehavior.floating,
      elevation: 8,
      width: 480,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.accent, linearTrackColor: p.ghost, circularTrackColor: Colors.transparent),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.accent,
      inactiveTrackColor: p.ghost,
      thumbColor: p.ink,
      overlayShape: SliderComponentShape.noOverlay,
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9, elevation: 2),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(p.ink3),
      thickness: const WidgetStatePropertyAll(6),
      radius: const Radius.circular(3),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: p.raised,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: p.border, width: 0.5),
        boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
      textStyle: TextStyle(color: p.ink, fontSize: 12, fontFamily: Fonts.ui),
      waitDuration: const Duration(milliseconds: 500),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, fontFamily: Fonts.ui)),
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
  );
}
