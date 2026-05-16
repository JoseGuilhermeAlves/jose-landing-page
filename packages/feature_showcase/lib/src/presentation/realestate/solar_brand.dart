import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de imoveis — "Solar", uma imobiliaria de
/// casas, chacaras e terrenos no interior. Tom caseiro, expansivo, de
/// terra. Inspiracao visual: revistas de arquitetura (Casa Vogue,
/// Wallpaper) com pegada de imobiliaria de campo.
///
/// Paleta terracota / musgo / creme. Terracota como primary (acao,
/// terra, calor), musgo como accent (vegetacao, calma), creme como
/// background (papel, claridade do interior). Toda a paleta e tema
/// sao locais ao demo via `Theme` widget; widgets internos que leem
/// `context.colors` recebem a paleta da marca sem propagacao manual.
abstract final class SolarBrand {
  static const String name = 'Solar';
  static const String tagline = 'Sua nova casa cabe aqui.';

  /// Paleta terracota / musgo / creme. Terracota como primary, musgo
  /// como accent (success natural pra "disponivel"), creme como
  /// background. Onde se contrasta com terracota fundo, usa-se um
  /// tom mais escuro de marrom-tijolo pra texto.
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFFB25A38),
    primaryHover: Color(0xFFC66A45),
    onPrimary: Color(0xFFF4EDDA),
    accent: Color(0xFF4B5D3A),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF4EDDA),
    surface: Color(0xFFFBF5E5),
    surfaceMuted: Color(0xFFE9DFC4),
    border: Color(0xFFD0C49E),
    onSurface: Color(0xFF3A2A1F),
    onSurfaceMuted: Color(0xFF6F5E48),
    success: Color(0xFF4B5D3A),
    warning: Color(0xFFB07A2C),
    error: Color(0xFFA0392E),
    info: Color(0xFF4B5D3A),
  );

  /// Fonte serif do sistema — Flutter resolve pro serif default
  /// (Times no Windows / .AppleSystemUIFontSerif no macOS / Noto Serif
  /// onde disponivel). Usado nos display headlines pra dar ar de
  /// revista de arquitetura.
  static const String displayFontFamily = 'serif';

  /// Constroi um `ThemeData` light Solar a partir do tema corrente.
  /// Substitui [AppColorsExtension] e os hooks de Material que leem
  /// cor (scaffold, canvas, tabbar) pra que tudo dentro do demo herde
  /// a identidade da marca. Forca `brightness: light` no colorScheme
  /// pra que widgets Material tratem o demo como tema claro.
  static ThemeData buildTheme(BuildContext context) {
    final base = Theme.of(context);
    final baseText = base.textTheme;
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.light,
        primary: palette.primary,
        onPrimary: palette.onPrimary,
        secondary: palette.accent,
        onSecondary: palette.onAccent,
        surface: palette.surface,
        onSurface: palette.onSurface,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.onSurface,
        unselectedLabelColor: palette.onSurfaceMuted,
        indicatorColor: palette.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: baseText.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      iconTheme: IconThemeData(color: palette.onSurface),
      textTheme: baseText
          .apply(
            bodyColor: palette.onSurface,
            displayColor: palette.onSurface,
          )
          .copyWith(
            displayLarge: baseText.displayLarge?.copyWith(
              fontFamily: displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
              color: palette.onSurface,
            ),
            displayMedium: baseText.displayMedium?.copyWith(
              fontFamily: displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              color: palette.onSurface,
            ),
            displaySmall: baseText.displaySmall?.copyWith(
              fontFamily: displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: palette.onSurface,
            ),
            headlineLarge: baseText.headlineLarge?.copyWith(
              fontFamily: displayFontFamily,
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
            headlineMedium: baseText.headlineMedium?.copyWith(
              fontFamily: displayFontFamily,
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
            headlineSmall: baseText.headlineSmall?.copyWith(
              fontFamily: displayFontFamily,
              fontWeight: FontWeight.w600,
              color: palette.onSurface,
            ),
          ),
      // ignore: prefer_const_constructors
      extensions: <ThemeExtension<dynamic>>[AppColorsExtension(palette)],
    );
  }
}
