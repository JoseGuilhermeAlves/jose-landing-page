import 'package:flutter/material.dart';

/// Paleta semantica do design system. Cada esquema (dark/light) implementa
/// os mesmos slots — o widget consome via [Theme.of] e nao precisa saber
/// qual modo esta ativo.
///
/// Para alterar a identidade visual, edite [AppColorScheme.dark] e
/// [AppColorScheme.light] aqui — todo o app reflete a mudanca.
@immutable
class AppColorScheme {
  const AppColorScheme({
    required this.primary,
    required this.primaryHover,
    required this.onPrimary,
    required this.accent,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  final Color primary;
  final Color primaryHover;
  final Color onPrimary;
  final Color accent;
  final Color onAccent;
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color onSurface;
  final Color onSurfaceMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  /// Dark-first — paleta default da landing (CRT neon).
  static const AppColorScheme dark = AppColorScheme(
    primary: Color(0xFFFF2E97),
    primaryHover: Color(0xFFFF5CAD),
    onPrimary: Color(0xFF0A0612),
    accent: Color(0xFF00E5FF),
    onAccent: Color(0xFF0A0612),
    background: Color(0xFF0A0612),
    surface: Color(0xFF150C26),
    surfaceMuted: Color(0xFF0F0819),
    border: Color(0xFF34215C),
    onSurface: Color(0xFFF2E9FF),
    onSurfaceMuted: Color(0xFF9A86C4),
    success: Color(0xFF39FF14),
    warning: Color(0xFFFFC400),
    error: Color(0xFFFF3355),
    info: Color(0xFF00E5FF),
  );

  /// Modo claro — nao usado no Arcade (a landing e CRT dark-only). Mantido
  /// pra nao quebrar o contrato de slots; espelha o dark com fundo claro.
  static const AppColorScheme light = AppColorScheme(
    primary: Color(0xFFD6177A),
    primaryHover: Color(0xFFB30F63),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF008CA8),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF4EEFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEDE6FB),
    border: Color(0xFFD9CCF2),
    onSurface: Color(0xFF170A2E),
    onSurfaceMuted: Color(0xFF6A5A8C),
    success: Color(0xFF1A9E2E),
    warning: Color(0xFFB37A00),
    error: Color(0xFFD11F3F),
    info: Color(0xFF008CA8),
  );
}

/// Extensao para acessar a paleta semantica via `Theme.of(context).extension`.
@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension(this.scheme);

  final AppColorScheme scheme;

  @override
  AppColorsExtension copyWith({AppColorScheme? scheme}) =>
      AppColorsExtension(scheme ?? this.scheme);

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return t < 0.5 ? this : other;
  }
}

/// Acesso conveniente: `context.colors.primary`.
extension AppColorsContext on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorsExtension>()!.scheme;
}
