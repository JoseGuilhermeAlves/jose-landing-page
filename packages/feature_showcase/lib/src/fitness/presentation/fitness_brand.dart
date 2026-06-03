import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de fitness — narrativa propria pra que o
/// demo nao pareca extensao da landing. "Pulso" e um nome curto e
/// energetico em pt-br.
///
/// Paleta **dark Whoop-style** — superficie quase preta, tipografia
/// branca, accents de recovery (verde eletrico), strain (cyan) e
/// alerta (ambar/vermelho). Inspiracao: Whoop, Apple Fitness rest
/// screens em dark. Toda a paleta e tema sao locais ao demo via
/// `Theme` widget; widgets internos que leem `context.colors` recebem
/// a paleta da marca sem propagacao.
abstract final class FitnessBrand {
  static const String name = 'Pulso';
  static const String tagline = 'Treinar com leitura.';

  /// Familia dos numerais grandes (recovery, strain, biometrics). Usa a
  /// IBMPlexSans bundlada (mesma do design_system) com tabular figures
  /// via [numFeatures] — antes era o fallback 'monospace', que resolvia
  /// pra Courier/Cascadia e dava cara de prototipo. Plex tabular entrega
  /// digitos alinhados e premium na propria face da landing.
  static const String displayMonoFontFamily = 'IBMPlexSans';

  /// Tabular figures pros KPIs — digitos de largura fixa pra os numeros
  /// nao "pularem" quando o valor muda.
  static const List<FontFeature> numFeatures = [FontFeature.tabularFigures()];

  /// Paleta dark recovery-first — referencia: Whoop. Superficies
  /// quase pretas pra que os accents (verde recovery, cyan strain)
  /// soem como leitura biometrica de aparelho, nao decoracao.
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFF00D982),
    primaryHover: Color(0xFF33E099),
    onPrimary: Color(0xFF06140C),
    accent: Color(0xFF5AC8FA),
    onAccent: Color(0xFF06141A),
    background: Color(0xFF08080B),
    surface: Color(0xFF111116),
    surfaceMuted: Color(0xFF1A1A22),
    border: Color(0xFF26262F),
    onSurface: Color(0xFFF2F2F5),
    onSurfaceMuted: Color(0xFF7E7E8A),
    success: Color(0xFF00D982),
    warning: Color(0xFFE0A93D),
    error: Color(0xFFFF5C5C),
    info: Color(0xFF5AC8FA),
  );

  /// Bandas de cor pro score de recovery (0–100). Mapeia o cinza
  /// fora-da-leitura, vermelho/amarelo/verde do Whoop em valores
  /// que combinam com a paleta dark.
  static Color recoveryColor(double percent) {
    if (percent < 34) return const Color(0xFFFF5C5C);
    if (percent < 67) return const Color(0xFFE0A93D);
    return const Color(0xFF00D982);
  }

  /// Bandas de strain (0–21, logaritmico). 0–10 calmo, 10–14 moderado,
  /// 14–18 alto, 18–21 all-out. Cores progridem azul -> roxo -> magenta.
  static Color strainColor(double score) {
    if (score < 10) return const Color(0xFF5AC8FA);
    if (score < 14) return const Color(0xFF7B8FFF);
    if (score < 18) return const Color(0xFFB47BFF);
    return const Color(0xFFFF5CC8);
  }

  /// Constroi um `ThemeData` a partir do tema corrente, substituindo
  /// a `AppColorsExtension` e os hooks de Material que leem cor pra
  /// que tudo dentro do demo herde a identidade da marca. Mantem
  /// `brightness: dark` — a landing ja e dark, mas o demo dobra a
  /// aposta com superficie quase preta.
  static ThemeData buildTheme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
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
        labelStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      iconTheme: IconThemeData(color: palette.onSurface),
      textTheme: base.textTheme.apply(
        bodyColor: palette.onSurface,
        displayColor: palette.onSurface,
      ),
      // ignore: prefer_const_constructors
      extensions: <ThemeExtension<dynamic>>[AppColorsExtension(palette)],
    );
  }
}
