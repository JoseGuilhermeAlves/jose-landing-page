import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de delivery — "Aurora", um marketplace de
/// hortifruti/emporio com entrega no mesmo dia. Inspiracao visual:
/// Daki, Cornershop, mas com cara de emporio de bairro. Tom: caloroso,
/// sazonal, cuidado com produto.
///
/// Paleta verde-folha / creme / ocre — terrosa, oposta ao dark da
/// landing. Verde como primary (vegetal, ancoragem), creme como
/// background (luz, frescor), ocre como accent (carinho, sazonalidade).
/// Toda a paleta e tema sao locais ao demo via `Theme` widget; widgets
/// internos que leem `context.colors` recebem a paleta da marca sem
/// propagacao manual.
abstract final class AuroraBrand {
  static const String name = 'Aurora';
  static const String tagline = 'Da feira ate sua mesa.';

  /// Paleta verde / creme / ocre. Verde escuro como primary (CTA,
  /// ancoragem), creme como background (frescor, luz natural), ocre
  /// como accent secundario (carinho editorial, sazonalidade).
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFF2F6B3F),
    primaryHover: Color(0xFF3B7E4D),
    onPrimary: Color(0xFFF5EDDE),
    accent: Color(0xFFC9883A),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF5EDDE),
    surface: Color(0xFFFFFBF1),
    surfaceMuted: Color(0xFFE9DEC3),
    border: Color(0xFFD9C9A2),
    onSurface: Color(0xFF1F2D1F),
    onSurfaceMuted: Color(0xFF6B6452),
    success: Color(0xFF2F6B3F),
    warning: Color(0xFFC9883A),
    error: Color(0xFFA0392E),
    info: Color(0xFF356D80),
  );

  /// `fontFamily` serif do sistema — usado nos display headlines pra
  /// dar ar de revista/empório. Body fica no sans default.
  static const String displayFontFamily = 'serif';

  /// Constroi um `ThemeData` light Aurora a partir do tema corrente.
  /// Substitui [AppColorsExtension] e os hooks de Material que leem
  /// cor (scaffold, canvas, tabbar) pra que tudo dentro do demo herde
  /// a identidade visual da marca. Forca `brightness: light` no
  /// colorScheme pra que widgets Material (modais, ripples) tratem o
  /// demo como tema claro mesmo com a landing em dark.
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
          .apply(bodyColor: palette.onSurface, displayColor: palette.onSurface)
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

/// Sombra warm uniforme dos cards padrao do Aurora. Tinta verde primary
/// em alpha baixo pra que os cards "levantem" do background creme sem
/// virar drop-shadow cinza generico — segue a chave do card de pedido
/// ativo, mas mais sutil. Reutilizada por vendor card, chip de
/// categoria, cards de pedido/historico e demais superficies padrao.
List<BoxShadow> auroraCardShadow(AppColorScheme colors) => [
  BoxShadow(
    color: colors.primary.withValues(alpha: 0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
];

/// Preenchimento dos cards padrao. Nudge sutil do `surface` (creme
/// morno) rumo ao branco pra dar mais contraste contra o background
/// creme — os cards separam melhor sem perder o calor da marca.
Color auroraCardFill(AppColorScheme colors) =>
    Color.lerp(colors.surface, const Color(0xFFFFFFFF), 0.55)!;
