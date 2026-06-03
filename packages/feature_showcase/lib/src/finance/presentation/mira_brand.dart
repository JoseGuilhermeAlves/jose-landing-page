import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Marca ficticia do mock de investimentos — "Mira", plataforma de
/// renda variavel pra investidor pessoa fisica. Tom analitico, calmo,
/// sem barulho — anti-Robinhood. Dark-mode nativo (oposto editorial
/// aos demais mocks light) pra criar contraste forte na vitrine e
/// dar credibilidade de "produto serio" tipico do segmento.
///
/// Paleta deep-navy / verde-up / vermelho-down. Verde como primary
/// (CTAs principais + variacao positiva); vermelho como `error`/down;
/// dourado como accent (alertas e destaques editoriais). Numeros sao
/// renderizados em fonte monoespacada via `MiraBrand.monoFontFamily`
/// pra que precos e quantidades alinhem coluna a coluna.
abstract final class MiraBrand {
  static const String name = 'Mira';
  static const String tagline = 'Sua carteira, em tempo real.';

  /// Paleta dark-mode. `success`/`error` carregam o semantic de
  /// "ativo subiu / caiu" — tela inteira usa estes slots em vez de
  /// cores hard-coded.
  static const AppColorScheme palette = AppColorScheme(
    primary: Color(0xFF22D17E),
    primaryHover: Color(0xFF18B069),
    onPrimary: Color(0xFF06101F),
    accent: Color(0xFFF7B233),
    onAccent: Color(0xFF06101F),
    background: Color(0xFF070D1C),
    surface: Color(0xFF101A2D),
    surfaceMuted: Color(0xFF19233A),
    border: Color(0xFF22304B),
    onSurface: Color(0xFFE6E9F2),
    onSurfaceMuted: Color(0xFF8B95AE),
    success: Color(0xFF22D17E),
    warning: Color(0xFFF7B233),
    error: Color(0xFFFF4F6B),
    info: Color(0xFF4FB8FF),
  );

  /// Cor neon-mint usada em destaques editoriais — eyebrows, divisores
  /// de secao, glow accents. NAO faz parte do AppColorScheme (que ja
  /// esta saturado de slots), e exclusiva da Mira. Empurrada
  /// deliberadamente pro lado cyan/aqua (vs. o `success` #22D17E
  /// semantico de "ativo subiu") pra ler como highlight editorial
  /// intencional, e nao como um segundo verde acidental ao lado das
  /// sparklines verdes.
  static const Color neonMint = Color(0xFF2BF5C4);

  /// Gradiente "lit glass" pros cards principais — passo sutil de
  /// luminosidade (branco @ 0.04 no topo, [surface] no resto) que cria
  /// um highlight interno de 1px no topo do card. Sem ele, cards
  /// `surface` + borda de baixo contraste mal se separam do fundo
  /// escuro; com ele ganham o look premium-dark de vidro iluminado.
  static LinearGradient litGlassGradient(Color surface) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.alphaBlend(Colors.white.withValues(alpha: 0.04), surface),
        surface,
      ],
      stops: const [0.0, 0.18],
    );
  }

  /// `fontFamily` sans default — Mira nao puxa serif. Em prod, seria
  /// "Inter" via google_fonts. Aqui resolve no sans do sistema.
  static const String displayFontFamily = 'sans-serif';

  /// Fonte monoespacada para precos, codigos de ordem e tickers.
  /// Garante alinhamento vertical numa lista de ativos com precos
  /// de comprimento variavel.
  static const String monoFontFamily = 'monospace';

  /// Constroi um `ThemeData` dark Mira a partir do tema corrente.
  /// Forca `brightness: dark` no colorScheme — modais, sheets e
  /// ripples herdam o tratamento dark Material correto (oposto aos
  /// demais mocks da vitrine, que sao light).
  static ThemeData buildTheme(BuildContext context) {
    final base = Theme.of(context);
    final baseText = base.textTheme;
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
        error: palette.error,
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
