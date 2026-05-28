import 'dart:math' as math;

import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Topo da landing. Composicao em camadas:
/// 1. glow radial sutil atras do texto (depth);
/// 2. ParticleField como background (custom painter §5.1) — particulas
///    com alpha reduzido pra nao competir com headline;
/// 3. fade-out gradient no rodape — particulas escorregam pro
///    background da proxima secao em vez de cortar abrupto;
/// 4. conteudo centralizado: eyebrow chip, headline em 2 linhas (a
///    segunda em gradient brand), subhead, CTAs e trust strip.
///
/// Layout responsivo: tudo center-aligned em desktop, start-aligned
/// em mobile.
class HeroSection extends StatelessWidget {
  const HeroSection({
    this.onContactPressed,
    this.onSeeProjectsPressed,
    super.key,
  });

  /// Disparado pelo CTA primario "Falar no WhatsApp". Espera-se que o
  /// shell abra `wa.me/...` (PROJECT.md §4.1).
  final VoidCallback? onContactPressed;

  /// Disparado pelo CTA secundario "Ver projetos". Espera-se que o
  /// shell scrolle ate a secao de showcase.
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final headlineStyle =
        (isMobile ? textTheme.displaySmall : textTheme.displayMedium)?.copyWith(
          color: colors.onSurface,
          height: 1.05,
          letterSpacing: -1.2,
        );

    // Com a foto presente em desktop, o eixo de leitura passa a ser
    // horizontal (foto a esquerda -> headline -> CTA, padrao Linear/
    // Vercel quando apresentam fundador). Texto fica start-aligned em
    // ambos breakpoints — center-aligned ao lado de uma foto cria um
    // raggedness desconfortavel.
    const crossAxisAlignment = CrossAxisAlignment.start;
    const textAlign = TextAlign.start;

    final textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        const EyebrowBadge(label: 'Disponivel pra freelas'),
        SizedBox(height: isMobile ? AppSpacing.lg : AppSpacing.xl),
        Semantics(
          header: true,
          child: Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Front end mobile com Flutter.',
                style: headlineStyle,
                textAlign: textAlign,
              ),
              _AnimatedNeonHeadline(
                text: 'Do MVP ao app em producao.',
                style: headlineStyle,
                textAlign: textAlign,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            '7+ anos construindo o front end de apps mobile (e web '
            'quando faz sentido) — atuando do varejo B2B a produto '
            'fintech em escala.',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
            textAlign: textAlign,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _CtaRow(
          isMobile: isMobile,
          onContactPressed: onContactPressed,
          onSeeProjectsPressed: onSeeProjectsPressed,
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _TrustStrip(),
      ],
    );

    // Foto ancora o cosmos abstrato com presenca humana. Tamanhos
    // diferentes por breakpoint: desktop fica em coluna 3:4 limitada,
    // mobile espalha full-width acima do texto.
    final photo = _HeroPortrait(isMobile: isMobile);

    final inner = isMobile
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              photo,
              const SizedBox(height: AppSpacing.xl),
              textColumn,
            ],
          )
        : Row(
            children: [
              photo,
              const SizedBox(width: AppSpacing.xxl),
              Expanded(child: textColumn),
            ],
          );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSpacing.lg : AppSpacing.huge,
        vertical: AppSpacing.huge,
      ),
      child: ConstrainedBox(
        // Limite reduzido (1180 -> 1080) pra que em viewport ultra-wide
        // foto+texto fiquem agrupados ao inves de boiando isolados no
        // centro. Gap entre foto e texto tambem cai pra xxl pelo mesmo
        // motivo.
        constraints: BoxConstraints(maxWidth: isMobile ? 920 : 1080),
        child: inner,
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Glow radial atras do headline — sumindo pras bordas.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.glow(
                  colors.primary,
                  opacity: 0.16,
                  radius: 0.55,
                ),
              ),
            ),
          ),
        ),
        // ParticleField com alphas reduzidos pra nao competir com texto.
        // Densidade aumentada (72) pra reforcar a sensacao de "ceu
        // estrelado" — sem ofuscar o texto nem o trabalho do
        // ConstellationField acima.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: ParticleField(
              particleCount: 72,
              particleColor: colors.primary.withValues(alpha: 0.55),
              linkColor: colors.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        // Cosmos 8-bit — nebulosas, planetas com anel, lua orbitando
        // stepped e cometa cruzando o canvas. Vai *acima* das particulas
        // (pra que planetas dominem visualmente) e *abaixo* das
        // constelacoes (pra que estrelas nomeadas continuem dialogando
        // com o headline). Pixel-art rasterizado a 4 logical px por
        // 8-bit pixel.
        // Cosmos ancorado num frame de 1280px centralizado em vez do
        // viewport inteiro. Resolve a raiz do problema: anchors (0..1)
        // ficavam relativos ao viewport, entao em wide screen (1920+) os
        // corpos nas bordas (0.10/0.88) caiam longe do conteudo (max
        // 1080). SizedBox auto-clampa pro viewport em mobile (sem
        // mudanca de comportamento) e prende em 1280 em desktop (corpos
        // ladeiam o conteudo com bleed de ~100px cada lado). Particle
        // e Constellation Field seguem full-bleed pra que estrelas
        // ainda preencham as margens.
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: SizedBox(
                width: 1280,
                child: CosmosField(
                  planets: _heroPlanets(colors),
                  nebulas: _heroNebulas(),
                  galaxies: _heroGalaxies(),
                  pulsars: _heroPulsars(),
                  asteroidBelts: _heroAsteroidBelts(),
                  wisps: _heroWisps(),
                ),
              ),
            ),
          ),
        ),
        // Constelacoes com flare em cruz e twinkle — pontos
        // reconheciveis (Cruzeiro do Sul, Orion, Triangulo de Verao).
        // Vai por cima do cosmos pra que estrelas e linhas dialoguem
        // direto com o texto.
        const Positioned.fill(
          child: IgnorePointer(child: ConstellationField()),
        ),
        // Fade-out no rodape — particulas escorregam pro background.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 160,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, colors.background],
                ),
              ),
            ),
          ),
        ),
        // Conteudo.
        Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: content,
          ),
        ),
        // Scroll cue. Posicionado dentro do fade-out gradient pra que
        // se misture com a transicao — atmosfera, nao destaque
        // gritante. Indica que tem conteudo abaixo, sem competir com
        // os CTAs do hero.
        const Positioned(
          left: 0,
          right: 0,
          bottom: AppSpacing.lg,
          child: Center(child: _ScrollHint()),
        ),
      ],
    );
  }
}

/// Planetas customizados pro hero. CosmosField espalha por todo o
/// viewport — em wide screen, anchors nos extremos (0.04 / 0.96) ficam
/// muito longe do conteudo centralizado (maxWidth 1080) e a cena perde
/// coesao. Anchors aqui ficam em corona apertada (0.10..0.20 / 0.80..0.90)
/// pra ladearem foto+texto sem sobrepor.
List<CosmosPlanet> _heroPlanets(AppColorScheme colors) {
  return const [
    // Red giant — canto superior direito, off-canvas (igual default).
    CosmosPlanet(
      id: 'red-giant',
      canvasAnchor: Offset(1.02, -0.08),
      radiusPixels: 150,
      pattern: PlanetPattern.speckled,
      seed: 7,
      palette: [
        Color(0xFF1A0008),
        Color(0xFF7A0E2A),
        Color(0xFFFF1F44),
        Color(0xFFFF6679),
        Color(0xFFFFDADE),
      ],
    ),
    // Ice ringed — borda esquerda, alto, pequeno (era 0.10, 0.34 grande).
    CosmosPlanet(
      id: 'ice-world',
      canvasAnchor: Offset(0.18, 0.25),
      radiusPixels: 32,
      pattern: PlanetPattern.hemispheres,
      seed: 9,
      palette: [
        Color(0xFF010E1A),
        Color(0xFF0A446A),
        Color(0xFF0AC4FF),
        Color(0xFF7FE9FF),
        Color(0xFFE8FBFF),
      ],
      ring: PlanetRing(
        innerRadiusPixels: 44,
        outerRadiusPixels: 62,
        color: Color(0xEE0AE0FF),
        tiltY: 0.28,
      ),
    ),
    // Magenta giant — canto inferior direito off-screen, era central.
    CosmosPlanet(
      id: 'magenta-giant',
      canvasAnchor: Offset(0.86, 0.86),
      radiusPixels: 28,
      pattern: PlanetPattern.bands,
      seed: 13,
      palette: [
        Color(0xFF1A0524),
        Color(0xFF5C0F7A),
        Color(0xFFE020F2),
        Color(0xFFFF66F5),
        Color(0xFFFFCFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 40,
        moonRadiusPixels: 4,
        color: Color(0xFFFFFFFF),
        phaseOffset: 0.15,
      ),
    ),
    // Lime rocky — borda esquerda baixa.
    CosmosPlanet(
      id: 'lime-rocky',
      canvasAnchor: Offset(0.10, 0.82),
      radiusPixels: 14,
      pattern: PlanetPattern.speckled,
      seed: 3,
      palette: [
        Color(0xFF020F08),
        Color(0xFF0A4023),
        Color(0xFF1FFF6E),
        Color(0xFFA5FFC1),
        Color(0xFFE9FFEC),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 24,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFD9),
        phaseOffset: 0.55,
      ),
    ),
    // Electric blue — topo direita, longe do headline.
    CosmosPlanet(
      id: 'electric-blue',
      canvasAnchor: Offset(0.82, 0.16),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 19,
      palette: [
        Color(0xFF020B26),
        Color(0xFF0A2B70),
        Color(0xFF2D7FFF),
        Color(0xFF7CB8FF),
        Color(0xFFE0EEFF),
      ],
    ),
    // Violet rocky — borda direita, meio. Era 0.36, 0.46 (dentro do texto).
    CosmosPlanet(
      id: 'violet-rocky',
      canvasAnchor: Offset(0.88, 0.46),
      radiusPixels: 12,
      pattern: PlanetPattern.speckled,
      seed: 17,
      palette: [
        Color(0xFF120428),
        Color(0xFF391066),
        Color(0xFF9D3FFF),
        Color(0xFFD58BFF),
        Color(0xFFF0DCFF),
      ],
    ),
  ];
}

/// Nebulosas customizadas pro hero — coladas nas bordas, longe do centro.
/// Default tem nebula em (0.42, 0.38) e (0.42, 0.80) que poluem o eixo de
/// leitura; aqui empurramos pras laterais.
List<CosmosNebula> _heroNebulas() {
  return const [
    CosmosNebula(
      canvasAnchor: Offset(0.86, 0.06),
      radiusPixels: 110,
      color: Color(0xFFFF1F8B),
      density: 0.78,
      seed: 4,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.12, 0.20),
      radiusPixels: 70,
      color: Color(0xFF0AC4FF),
      density: 0.62,
      seed: 1,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.88, 0.50),
      radiusPixels: 60,
      color: Color(0xFF9D3FFF),
      density: 0.55,
      seed: 6,
    ),
    CosmosNebula(
      canvasAnchor: Offset(0.10, 0.88),
      radiusPixels: 64,
      color: Color(0xFFE020F2),
      density: 0.60,
      seed: 5,
    ),
  ];
}

/// Galaxias customizadas pro hero — duas espirais grandes em cantos
/// opostos pra dar profundidade sem competir com foto ou texto. A do
/// canto inferior direito ancora visualmente o trust strip; a do canto
/// superior esquerdo entra atras do halo do red giant pra criar layered
/// depth.
List<CosmosGalaxy> _heroGalaxies() {
  return const [
    // Galaxia violet-cream — bottom-right, grande, tilt acentuado.
    CosmosGalaxy(
      canvasAnchor: Offset(0.88, 0.88),
      radiusPixels: 160,
      coreColor: Color(0xFFFFE8C2),
      armColor: Color(0xFF9D3FFF),
      armCount: 4,
      tiltY: 0.38,
      rotation: -0.7,
      dustCount: 320,
      seed: 41,
    ),
    // Galaxia cyan-pink — top-left, menor, tilt diferente pra variar.
    CosmosGalaxy(
      canvasAnchor: Offset(0.15, 0.19),
      radiusPixels: 90,
      coreColor: Color(0xFFE8FBFF),
      armColor: Color(0xFFFF1F8B),
      tiltY: 0.55,
      rotation: 1.2,
      dustCount: 200,
      seed: 67,
    ),
  ];
}

/// Pulsares customizados pro hero — quatro acentos pontuais ritmicos
/// nas bordas, com fases dessincronizadas pra criar pulso contagiante
/// sem batida coletiva. Cores variadas dialogam com a paleta dos
/// planetas.
List<CosmosPulsar> _heroPulsars() {
  return const [
    // Direita, altura do headline — cyan farol.
    CosmosPulsar(
      canvasAnchor: Offset(0.88, 0.34),
      coreColor: Color(0xFF99FFEC),
      beamColor: Color(0xFF0AC4FF),
      beamLengthPixels: 64,
      seed: 31,
    ),
    // Esquerda baixa, abaixo da foto — hot pink curto.
    CosmosPulsar(
      canvasAnchor: Offset(0.10, 0.58),
      coreColor: Color(0xFFFFCFF8),
      beamColor: Color(0xFFFF1F8B),
      coreRadiusPixels: 2,
      beamLengthPixels: 50,
      phaseOffset: 0.37,
      seed: 47,
    ),
    // Topo central-direito — gold pulsando em ritmo diferente.
    CosmosPulsar(
      canvasAnchor: Offset(0.72, 0.10),
      coreColor: Color(0xFFFFF8C8),
      beamColor: Color(0xFFFFB81F),
      coreRadiusPixels: 2,
      beamLengthPixels: 42,
      phaseOffset: 0.62,
      seed: 53,
    ),
    // Inferior central-esquerdo — violet acento curto.
    CosmosPulsar(
      canvasAnchor: Offset(0.18, 0.90),
      coreColor: Color(0xFFF0DCFF),
      beamColor: Color(0xFF9D3FFF),
      coreRadiusPixels: 2,
      beamLengthPixels: 38,
      phaseOffset: 0.83,
      seed: 71,
    ),
  ];
}

/// Cinturoes de asteroides do hero — densificam o lado esquerdo com
/// textura mid-layer. Banda principal envolve a galaxia cyan-pink em
/// arco parcial, criando profundidade entre ela e o ice ringed.
List<CosmosAsteroidBelt> _heroAsteroidBelts() {
  return const [
    CosmosAsteroidBelt(
      canvasAnchor: Offset(0.16, 0.22),
      radiusPixels: 96,
      rockColor: Color(0xFFB69BD9),
      highlightColor: Color(0xFFFFE8C2),
      tiltY: 0.28,
      rotation: -0.4,
      rockCount: 160,
      arcStart: 0.05,
      arcSweep: 0.72,
      seed: 91,
    ),
  ];
}

/// Wisps customizados pro hero — duas nuvens de gas no lado esquerdo
/// pra densificar a area entre foto e borda sem competir com a aura.
/// Tons distintos (cyan-magenta e violet-pink) pra dialogar com a paleta
/// dos planetas vizinhos.
List<CosmosWisp> _heroWisps() {
  return const [
    // Wisp principal — torco cyan/violet logo abaixo do ice ringed.
    CosmosWisp(
      canvasAnchor: Offset(0.08, 0.42),
      radiusPixels: 130,
      colors: [
        Color(0xFF0AC4FF),
        Color(0xFF9D3FFF),
        Color(0xFFE020F2),
      ],
      blobCount: 6,
      driftPixels: 16,
      density: 0.55,
      seed: 23,
    ),
    // Wisp secundario — magenta/pink mais alto na lateral esquerda.
    CosmosWisp(
      canvasAnchor: Offset(0.20, 0.62),
      radiusPixels: 90,
      colors: [
        Color(0xFFFF1F8B),
        Color(0xFFFF66F5),
        Color(0xFFFFCFF8),
      ],
      driftPixels: 12,
      density: 0.45,
      seed: 37,
    ),
  ];
}

/// Headline animado com gradient neon deslizando — combina com o tema
/// cosmos (cores hot-pink, magenta, violet, cyan e electric-blue sao as
/// mesmas dos planetas e nebulosas no fundo). Sweep horizontal em loop
/// de 8s com `TileMode.mirror` pra repeticao seamless.
class _AnimatedNeonHeadline extends StatefulWidget {
  const _AnimatedNeonHeadline({
    required this.text,
    required this.style,
    required this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  State<_AnimatedNeonHeadline> createState() => _AnimatedNeonHeadlineState();
}

class _AnimatedNeonHeadlineState extends State<_AnimatedNeonHeadline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  /// Paleta neon — mesma familia das nebulosas do cosmos.
  /// Color stops sao distribuidos pra dar fluxo: pink -> magenta ->
  /// violet -> cyan -> blue -> magenta -> pink (loop seamless).
  static const List<Color> _neonColors = [
    Color(0xFFFF2D95),
    Color(0xFFD946EF),
    Color(0xFF8B5CF6),
    Color(0xFF06D4FF),
    Color(0xFF2D7FFF),
    Color(0xFFD946EF),
    Color(0xFFFF2D95),
  ];

  static const List<double> _neonStops = [
    0.00,
    0.16,
    0.34,
    0.50,
    0.66,
    0.84,
    1.00,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        // Slide horizontal — gradient axis se move 4 alignment units por
        // loop, com tileMode mirror pra repetir seamless.
        final shift = _controller.value * 4;
        return GradientText(
          text: widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
          gradient: LinearGradient(
            begin: Alignment(-3 + shift, 0),
            end: Alignment(3 + shift, 0),
            colors: _neonColors,
            stops: _neonStops,
            tileMode: TileMode.mirror,
          ),
        );
      },
    );
  }
}

/// Indicador "role para baixo" no rodape do hero. Chevron + label
/// muted bouncing devagar — afirmacao discreta de que tem mais conteudo
/// abaixo do fold.
class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, _) {
        // Curva sutil de easeInOut — Tween linear daria stop-and-go.
        final t = Curves.easeInOut.transform(_bounce.value);
        return Transform.translate(
          offset: Offset(0, 4 * t),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'role para continuar'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: colors.onSurfaceMuted,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CtaRow extends StatelessWidget {
  const _CtaRow({
    required this.isMobile,
    required this.onContactPressed,
    required this.onSeeProjectsPressed,
  });

  final bool isMobile;
  final VoidCallback? onContactPressed;
  final VoidCallback? onSeeProjectsPressed;

  @override
  Widget build(BuildContext context) {
    final whatsapp = AppButton(
      label: 'Falar no WhatsApp',
      onPressed: onContactPressed,
      size: AppButtonSize.large,
      icon: Icons.chat_bubble_outline,
      expand: isMobile,
    );

    final projects = AppButton(
      label: 'Ver projetos',
      onPressed: onSeeProjectsPressed,
      size: AppButtonSize.large,
      variant: AppButtonVariant.secondary,
      icon: Icons.arrow_forward,
      expand: isMobile,
    );

    if (isMobile) {
      // SizedBox.expand-width converte a constraint frouxa do Column pai
      // em tight, condicao necessaria para `crossAxisAlignment.stretch`
      // e para `expand:true` do AppButton funcionarem sem overflow.
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            whatsapp,
            const SizedBox(height: AppSpacing.md),
            projects,
          ],
        ),
      );
    }

    // Desktop agora le da esquerda (foto) pra direita (texto + CTA);
    // CTAs alinhados a start seguem esse eixo de leitura.
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [whatsapp, projects],
    );
  }
}

/// Strip de prova social abaixo dos CTAs. Cada chip e vertical
/// (valor em destaque, label uppercase abaixo) — formato compacto
/// que cabe ate em viewport mobile estreito sem overflow.
class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  static const List<_TrustStat> _stats = [
    _TrustStat(value: '7+', label: 'anos de Flutter'),
    _TrustStat(value: '5+', label: 'dominios atuados'),
    _TrustStat(value: 'Mobile · Web', label: 'plataformas-alvo'),
  ];

  @override
  Widget build(BuildContext context) {
    // Sempre start-aligned: o hero agora lidera com a foto a esquerda,
    // entao centralizar a trust strip quebraria o eixo de leitura.
    return Wrap(
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.lg,
      children: [
        for (final stat in _stats)
          _TrustStatChip(
            stat: stat,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
      ],
    );
  }
}

class _TrustStat {
  const _TrustStat({required this.value, required this.label});
  final String value;
  final String label;
}

/// Foto de perfil tratada pra dialogar com o cosmos atras: aura anime
/// multi-blob animada (mesma paleta neon do headline) + grounding glow
/// concentrado onde a silhueta termina. Aspect ratio 3:4 retrato pra
/// enquadrar do busto pra cima. `BoxFit.contain` + `bottomCenter` mantem
/// a silhueta inteira ancorada na base do frame.
class _HeroPortrait extends StatefulWidget {
  const _HeroPortrait({required this.isMobile});

  final bool isMobile;

  @override
  State<_HeroPortrait> createState() => _HeroPortraitState();
}

class _HeroPortraitState extends State<_HeroPortrait>
    with SingleTickerProviderStateMixin {
  // Um unico controller alimenta toda a aura via `super(repaint:)` —
  // 8s ciclo lento bate com o headline neon (ambos em 8s, mas com fases
  // dessincronizadas pelo seed dos blobs).
  late final AnimationController _aura = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  )..repeat();

  @override
  void dispose() {
    _aura.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = widget.isMobile;

    // Tamanhos por breakpoint. Desktop ampliado (460x600) pra dar mais
    // presenca a foto — ela e o ancora humano do hero. Mobile full-width
    // limitado em altura pra nao empurrar headline pra fora do fold.
    final maxWidth = isMobile ? double.infinity : 460.0;
    final maxHeight = isMobile ? 380.0 : 600.0;

    return Semantics(
      label: 'Foto de Jose Guilherme Alves',
      image: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: RepaintBoundary(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Aura anime: 6 blobs radiais com drift senoidal, em
                // BlendMode.plus pra que sobreposicoes acendam (ki aura
                // / nebula emanando) em vez de chapar. Painter recebe
                // o controller via `super(repaint:)` — sem rebuild do
                // widget a cada tick.
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      isComplex: true,
                      willChange: true,
                      painter: _AnimeAuraPainter(
                        progress: _aura,
                        primary: colors.primary,
                        accent: colors.accent,
                      ),
                    ),
                  ),
                ),
                // Grounding: glow eliptico ancorando a silhueta na base
                // do frame. Sem arco — a silhueta e busto pra cima, nao
                // tem "pe" pra apoiar; o glow agora le como "silhueta
                // emergindo de luz".
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GroundingPainter(color: colors.primary),
                    ),
                  ),
                ),
                // Silhueta recortada (PNG transparente). `contain` preserva
                // a figura inteira sem clip. Asset vive em apps/landing.
                Image.asset(
                  'assets/images/foto_recortada.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  // errorBuilder evita exception em test bundle sem asset.
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aura anime-style: 6 blobs radiais sobrepostos em torno da silhueta,
/// cada um com fase propria e drift senoidal lento. Renderizado com
/// `BlendMode.plus` — sobreposicoes acendem aditivamente (ki/nebula) em
/// vez de chapar num retangulo violeta. Paleta espelha a do headline
/// neon (violet/magenta/cyan/pink hot) pra costurar com o resto do hero.
///
/// Performance: 6 `drawCircle` com shader radial cacheado por blob. Paint
/// objects e RNG de seed sao campos; shaders ficam invalidados apenas
/// quando o tamanho do frame muda.
class _AnimeAuraPainter extends CustomPainter {
  _AnimeAuraPainter({
    required this.progress,
    required this.primary,
    required this.accent,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color primary;
  final Color accent;

  // Hot pink + cyan pra dialogar com a paleta neon do headline e do
  // cosmos (mesmas familias das nebulosas).
  static const Color _hotPink = Color(0xFFFF2D95);
  static const Color _cyan = Color(0xFF06D4FF);

  // 6 blobs: cada tupla = (anchor x, anchor y, raio relativo a min(w,h),
  // amplitude do drift x, amplitude do drift y, offset de fase, cor).
  late final List<_AuraBlob> _blobs = [
    // Central-baixo no torso — nucleo violeta saturado.
    _AuraBlob(0.50, 0.62, 0.55, 0.04, 0.05, 0, primary),
    // Mid-esquerda — accent profundo.
    _AuraBlob(0.22, 0.50, 0.40, 0.05, 0.06, 0.21, accent),
    // Mid-direita — magenta hot.
    const _AuraBlob(0.78, 0.48, 0.42, 0.05, 0.06, 0.44, _hotPink),
    // Topo (cabeca) — cyan suave.
    const _AuraBlob(0.50, 0.18, 0.32, 0.03, 0.04, 0.67, _cyan),
    // Inferior-esquerdo — pink emergindo.
    const _AuraBlob(0.32, 0.82, 0.30, 0.04, 0.03, 0.13, _hotPink),
    // Inferior-direito — accent emergindo.
    _AuraBlob(0.70, 0.82, 0.32, 0.04, 0.03, 0.87, accent),
  ];

  // Cache de shaders por (tamanho, indice de blob). Invalidado quando
  // size muda. `_lastSize` evita reconstruir shaders 60Hz.
  Size? _lastSize;
  final List<Shader?> _shaderCache = List<Shader?>.filled(6, null);

  // Paint reutilizavel — BlendMode.plus faz sobreposicoes acenderem.
  final Paint _paint = Paint()..blendMode = BlendMode.plus;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final unit = math.min(w, h);
    final t = progress.value * 2 * math.pi;

    // Rebuild shader cache somente quando o frame redimensionar.
    if (_lastSize != size) {
      for (var i = 0; i < _blobs.length; i++) {
        final b = _blobs[i];
        final r = b.radius * unit;
        _shaderCache[i] = RadialGradient(
          colors: [
            // Alpha baixo no nucleo — em BlendMode.plus, baixo alpha ja
            // produz brilho perceptivel sem clipping.
            b.color.withValues(alpha: 0.55),
            b.color.withValues(alpha: 0.28),
            b.color.withValues(alpha: 0.10),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
      }
      _lastSize = size;
    }

    for (var i = 0; i < _blobs.length; i++) {
      final b = _blobs[i];
      final phase = b.phase * 2 * math.pi;
      // Drift senoidal lento — duas frequencias diferentes em x/y pra
      // que o movimento nao seja circular previsivel.
      final dx = math.sin(t + phase) * b.driftX * w;
      final dy = math.cos(t * 0.85 + phase) * b.driftY * h;
      final cx = b.anchorX * w + dx;
      final cy = b.anchorY * h + dy;
      final r = b.radius * unit;
      canvas
        ..save()
        ..translate(cx, cy);
      _paint.shader = _shaderCache[i];
      canvas
        ..drawCircle(Offset.zero, r, _paint)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_AnimeAuraPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primary != primary ||
        oldDelegate.accent != accent;
  }
}

class _AuraBlob {
  const _AuraBlob(
    this.anchorX,
    this.anchorY,
    this.radius,
    this.driftX,
    this.driftY,
    this.phase,
    this.color,
  );

  final double anchorX;
  final double anchorY;
  final double radius;
  final double driftX;
  final double driftY;
  final double phase;
  final Color color;
}

/// Ancoragem da silhueta: glow eliptico concentrado onde a silhueta
/// termina (quadril/jeans, ~96% da altura do frame), estendendo pra cima
/// dentro do corpo da figura pra que ela leia como "emergindo de luz" em
/// vez de "flutuando sobre uma linha". Sem arco — silhueta busto-pra-cima
/// nao tem pe pra apoiar, e a gramatica de horizonte curvo (planeta)
/// estava sugerindo isso erradamente. Painter estatico; `shouldRepaint`
/// compara cor pra reagir a troca de tema.
class _GroundingPainter extends CustomPainter {
  _GroundingPainter({required this.color});

  final Color color;

  // Eixo Y onde a silhueta termina visualmente. 0.96 = linha do quadril
  // na foto recortada (PNG ~0.628 aspect num frame 3:4 = a silhueta
  // ocupa altura cheia e encerra perto da base do proprio PNG).
  static const double _baseY = 0.96;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * _baseY;

    // Glow eliptico centrado na base da silhueta. Largura ampla (1.1 *
    // w), altura significativa (scaleY 0.75) pra estender pra cima e
    // fundir com o corpo — a silhueta parece nascer da luz em vez de
    // ficar pousada sobre faixa fina.
    final glowCenter = Offset(w / 2, cy);
    final glowRadius = w * 0.55;
    final glowRect = Rect.fromCircle(center: glowCenter, radius: glowRadius);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          // Alpha 0.5 no nucleo (era 0.38) — interage visivelmente com
          // a silhueta na base, dando a leitura de luz subindo pelo
          // corpo em vez de simples sombra no chao.
          color.withValues(alpha: 0.50),
          color.withValues(alpha: 0.18),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(glowRect);
    canvas
      ..save()
      // Achatamento vertical local — scaleY 0.75 (era 0.55) faz o glow
      // estender mais alto, cruzando a base da silhueta e dissipando.
      ..translate(glowCenter.dx, glowCenter.dy)
      ..scale(1, 0.75)
      ..translate(-glowCenter.dx, -glowCenter.dy)
      ..drawCircle(glowCenter, glowRadius, glowPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(_GroundingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _TrustStatChip extends StatelessWidget {
  const _TrustStatChip({required this.stat, required this.crossAxisAlignment});
  final _TrustStat stat;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          stat.value,
          style: textTheme.titleMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          stat.label.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
