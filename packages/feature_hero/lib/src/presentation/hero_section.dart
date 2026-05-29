import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_hero/src/presentation/hero/hero_planets_catalog.dart';
import 'package:feature_hero/src/presentation/hero/hero_portrait.dart';
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
    final photo = HeroPortrait(isMobile: isMobile);

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
        // Frame expande de 1280 -> 1600 em desktop pra que os corpos
        // do flanco esquerdo (proximos da foto) fanem por mais largura
        // e populem viewports wide (1920+). Mobile auto-clampa pro
        // viewport via SizedBox, sem mudanca de comportamento.
        Positioned.fill(
          child: IgnorePointer(
            child: Center(
              child: SizedBox(
                width: isMobile ? 1280 : 1600,
                child: CosmosField(
                  planets: heroPlanets(colors, isMobile: isMobile),
                  nebulas: heroNebulas(isMobile: isMobile),
                  galaxies: heroGalaxies(isMobile: isMobile),
                  pulsars: heroPulsars(isMobile: isMobile),
                  asteroidBelts: heroAsteroidBelts(isMobile: isMobile),
                  wisps: heroWisps(isMobile: isMobile),
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

/// Foto de perfil tratada pra dialogar com o cosmos atras. Em vez de
/// um RadialGradient no frame retangular (que vazava cor pros cantos
/// vazios), a aura agora **segue a silhueta**: 3 copias da mesma PNG
/// empilhadas, cada uma tingida com `srcIn` (a cor mora dentro do
/// alpha do PNG) e desfocada com `ImageFilter.blur` — o blur dilata o
/// contorno pra fora, produzindo um halo que abraca o recorte do
/// corpo, nao o frame. Sob a silhueta, um pequeno planeta
/// (CustomPainter) emerge da base do frame, ancorando o busto a algo
/// tangivel sem invocar a metafora de "chao sob os pes" — que nao
/// caberia num recorte que termina na altura do quadril.
///
/// Aspect ratio 3:4; `BoxFit.contain` + `bottomCenter` mantem a
/// silhueta ancorada na base, alinhada com o topo do planeta.

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
