import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de agendamento — "Vitral", um estudio de
/// servicos tecnicos por hora (consultoria, fotografia, design,
/// marketing). Tom profissional, organizado, claro — sem floreio.
///
/// Paleta indigo / off-white frio / cinza, light, pra contrastar com
/// o dark da landing **e** com os demais mocks creme da vitrine
/// (Aurora, Solar). Indigo como primary (autoridade, plano,
/// profissional), off-white frio como background (ar de papel
/// reciclado de escritorio), cinza como neutro de suporte. O tom de
/// pao `#F2DDB6` agora aparece **so** como `onPrimary` — vira o beijo
/// de marca nos CTAs indigo, sem dominar a tela. Toda a paleta e
/// tema sao locais ao demo via `Theme` widget; widgets internos que
/// leem `context.colors` recebem a paleta da marca sem propagacao
/// manual.
abstract final class VitralBrand {
  static const String name = 'Vitral';
  static const String tagline = 'Sua agenda, organizada.';

  /// Paleta indigo / off-white / cinza. Indigo escuro como primary
  /// (CTAs, destaque), off-white frio como background, cinza neutro
  /// pro texto secundario e bordas. Ocre quente como accent para
  /// timestamps e detalhes editoriais. Pao `#F2DDB6` resta apenas em
  /// `onPrimary` — toque de marca no texto sobre CTA indigo.
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFF2A3B70),
    primaryHover: Color(0xFF3A4D8C),
    onPrimary: Color(0xFFF2DDB6),
    accent: Color(0xFFB07A2C),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF4F1EA),
    surface: Color(0xFFFBFAF6),
    surfaceMuted: Color(0xFFE7E1D2),
    border: Color(0xFFD2CCBC),
    onSurface: Color(0xFF1F243A),
    onSurfaceMuted: Color(0xFF6B6F75),
    success: Color(0xFF2F6B3F),
    warning: Color(0xFFB07A2C),
    error: Color(0xFFA0392E),
    info: Color(0xFF2A3B70),
  );

  /// Fonte default sans — Vitral nao puxa serif pra deixar a UI mais
  /// "ficha de trabalho" que "revista". Mantido aqui pra parity com
  /// `displayFontFamily` das outras marcas, caso a futura iteracao
  /// queira trocar (ex.: para "Inter" via google_fonts).
  static const String displayFontFamily = 'sans-serif';

  /// Fonte monoespacada usada nos timestamps da grade do calendario
  /// e nos chips de hora. Da a sensacao "ficha tecnica / planilha".
  /// Flutter resolve pro mono do sistema (Consolas / Menlo / Mono).
  static const String monoFontFamily = 'monospace';

  /// Constroi um `ThemeData` light Vitral a partir do tema corrente.
  /// Substitui [AppColorsExtension] e os hooks de Material que leem
  /// cor (scaffold, canvas, tabbar) pra que tudo dentro do demo herde
  /// a identidade da marca. Forca `brightness: light` no colorScheme
  /// pra que widgets Material (modais, ripples) tratem o demo como
  /// tema claro mesmo com a landing em dark.
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
            // Display fica sans bold + tighter letter spacing pra dar
            // ar de "tabela bem diagramada".
            displayLarge: baseText.displayLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              color: palette.onSurface,
            ),
            displayMedium: baseText.displayMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: palette.onSurface,
            ),
            displaySmall: baseText.displaySmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: palette.onSurface,
            ),
            headlineLarge: baseText.headlineLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.onSurface,
            ),
            headlineMedium: baseText.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.onSurface,
            ),
            headlineSmall: baseText.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.onSurface,
            ),
          ),
      // ignore: prefer_const_constructors
      extensions: <ThemeExtension<dynamic>>[AppColorsExtension(palette)],
    );
  }
}
