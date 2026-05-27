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

  // Valores alinhados a identidade Kraken (DESIGN.md §2) — dark base preservado.
  /// Dark-first — paleta default da landing.
  static const AppColorScheme dark = AppColorScheme(
    primary: Color(0xFF7132F5),
    primaryHover: Color(0xFF855BFB),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF5741D8),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFF0A0A0F),
    surface: Color(0xFF14121C),
    surfaceMuted: Color(0xFF1E1B2A),
    border: Color(0xFF2A2638),
    onSurface: Color(0xFFE8E6F0),
    onSurfaceMuted: Color(0xFF9497A9),
    success: Color(0xFF149E61),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    info: Color(0xFF60A5FA),
  );

  /// Modo claro — opcional, ativavel via toggle.
  static const AppColorScheme light = AppColorScheme(
    primary: Color(0xFF7132F5),
    primaryHover: Color(0xFF5741D8),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF5741D8),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF5F4F8),
    border: Color(0xFFDEDEE5),
    onSurface: Color(0xFF101114),
    onSurfaceMuted: Color(0xFF9497A9),
    success: Color(0xFF149E61),
    warning: Color(0xFFD97706),
    error: Color(0xFFDC2626),
    info: Color(0xFF2563EB),
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
    // Paleta nao interpola — toggling dark/light troca instantaneamente.
    if (other is! AppColorsExtension) return this;
    return t < 0.5 ? this : other;
  }
}

/// Acesso conveniente: `context.colors.primary`.
extension AppColorsContext on BuildContext {
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorsExtension>()!.scheme;
}
