import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de e-commerce — "Garoa", uma cafe-livraria
/// urbana. Inspiracao visual: Blue Bottle, cafe-livrarias paulistanas
/// e curitibanas, MUJI. Tom: caseiro, brasileiro, ritual.
///
/// Paleta cafe/creme/musgo intencionalmente terrosa e light — oposta
/// ao dark da landing — pra dar a impressao de "manha calma". Toda
/// a paleta e tema sao locais ao demo via `Theme` widget; widgets
/// internos que leem `context.colors` recebem a paleta da marca sem
/// propagacao manual.
abstract final class GaroaBrand {
  static const String name = 'Garoa';
  static const String tagline = 'Cafe que rende uma conversa.';

  /// Paleta cafe-escuro / creme / musgo. Cafe como primary (acao,
  /// CTA, ancoragem), creme como background (leveza, conforto), musgo
  /// como accent secundario pra success e elementos editoriais.
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFF2B1A12),
    primaryHover: Color(0xFF3D2719),
    onPrimary: Color(0xFFF2E8D9),
    accent: Color(0xFF5C6E47),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF6EFE0),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFEFE5D2),
    border: Color(0xFFDDCDB1),
    onSurface: Color(0xFF2B1A12),
    onSurfaceMuted: Color(0xFF6E5A48),
    success: Color(0xFF5C6E47),
    warning: Color(0xFFC18A2A),
    error: Color(0xFFAE2E2A),
    info: Color(0xFF5C6E47),
  );

  /// `fontFamily` serif do sistema — Flutter resolve pra Times/Cambria
  /// no Windows, .AppleSystemUIFontSerif no macOS e Noto Serif onde
  /// disponivel. Usado nos display headlines pra dar ar editorial sem
  /// puxar dependencia de google_fonts. Body fica no sans default.
  static const String displayFontFamily = 'serif';

  /// Constroi um `ThemeData` light Garoa a partir do tema corrente.
  /// Substitui a [AppColorsExtension] e os hooks de Material que leem
  /// cor (scaffold, canvas, tabbar) pra que tudo dentro do demo herde
  /// a identidade visual da marca. Forca `brightness: light` no
  /// colorScheme pra que widgets Material (modais, ripples, etc.)
  /// tratem o demo como tema claro mesmo com a landing em dark.
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
            // Headlines viram serif pra dar ar de revista/livraria. Body
            // segue sans pra legibilidade.
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
