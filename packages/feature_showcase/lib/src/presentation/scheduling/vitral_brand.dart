import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de agendamento — "Vitral", um estudio de
/// servicos tecnicos por hora (consultoria, fotografia, design,
/// marketing). Tom profissional, organizado, claro — sem floreio.
///
/// Paleta indigo / pao / cinza, light, pra contrastar com o dark da
/// landing. Indigo como primary (autoridade, plano, profissional),
/// pao como background (calor, leitura agradavel), cinza como
/// neutro de suporte. Toda a paleta e tema sao locais ao demo via
/// `Theme` widget; widgets internos que leem `context.colors`
/// recebem a paleta da marca sem propagacao manual.
abstract final class VitralBrand {
  static const String name = 'Vitral';
  static const String tagline = 'Sua agenda, organizada.';

  /// Paleta indigo / pao / cinza. Indigo escuro como primary (CTAs,
  /// destaque), pao claro como background (acolhedor), cinza neutro
  /// pro texto secundario e bordas. Ocre quente como accent para os
  /// timestamps e detalhes editoriais.
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFF2A3B70),
    primaryHover: Color(0xFF3A4D8C),
    onPrimary: Color(0xFFF2DDB6),
    accent: Color(0xFFB07A2C),
    onAccent: Color(0xFFFFFFFF),
    background: Color(0xFFF2DDB6),
    surface: Color(0xFFFBF3DF),
    surfaceMuted: Color(0xFFE6CFA1),
    border: Color(0xFFCBB58A),
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
