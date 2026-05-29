import 'dart:ui' as ui;

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
                  planets: _heroPlanets(colors, isMobile: isMobile),
                  nebulas: _heroNebulas(isMobile: isMobile),
                  galaxies: _heroGalaxies(isMobile: isMobile),
                  pulsars: _heroPulsars(isMobile: isMobile),
                  asteroidBelts: _heroAsteroidBelts(isMobile: isMobile),
                  wisps: _heroWisps(isMobile: isMobile),
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
///
/// Desktop recebe lista expandida: mais corpos no flanco esquerdo
/// (onde fica a foto), x em {0.03, 0.06, 0.10, 0.14, 0.20} em vez de
/// clusterizar em 0.10. Y distribui em {0.10, 0.24, 0.36, 0.48, 0.60,
/// 0.74, 0.88} pra evitar empilhamento vertical. Mobile mantem a lista
/// compacta original — corpos espacados demais sumiriam no viewport
/// estreito.
List<CosmosPlanet> _heroPlanets(
  AppColorScheme colors, {
  required bool isMobile,
}) {
  if (!isMobile) return _heroPlanetsDesktop();
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
    // Teal-mint world — mid left, dialoga com wisp cyan abaixo.
    CosmosPlanet(
      id: 'teal-world',
      canvasAnchor: Offset(0.05, 0.50),
      radiusPixels: 16,
      pattern: PlanetPattern.bands,
      seed: 53,
      palette: [
        Color(0xFF02100E),
        Color(0xFF0A4A3D),
        Color(0xFF1FE5B5),
        Color(0xFFA5FFE5),
        Color(0xFFE9FFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 26,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFF8),
        phaseOffset: 0.3,
      ),
    ),
    // Amber dwarf — entre ice ringed e teal, preenche meio-esquerda alta.
    CosmosPlanet(
      id: 'amber-dwarf',
      canvasAnchor: Offset(0.04, 0.34),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 61,
      palette: [
        Color(0xFF2A1500),
        Color(0xFF7A4205),
        Color(0xFFFFA82A),
        Color(0xFFFFD58A),
        Color(0xFFFFF1D6),
      ],
    ),
    // Indigo rocky — abaixo do teal, pequeno, ancora canto esquerdo baixo.
    CosmosPlanet(
      id: 'indigo-rocky',
      canvasAnchor: Offset(0.16, 0.68),
      radiusPixels: 11,
      pattern: PlanetPattern.speckled,
      seed: 73,
      palette: [
        Color(0xFF08081C),
        Color(0xFF1F2280),
        Color(0xFF3F66FF),
        Color(0xFF9BB8FF),
        Color(0xFFE0EBFF),
      ],
    ),
    // Coral-rose — entre lime e indigo, densifica canto esquerdo medio.
    CosmosPlanet(
      id: 'coral-rose',
      canvasAnchor: Offset(0.03, 0.72),
      radiusPixels: 8,
      pattern: PlanetPattern.bands,
      seed: 83,
      palette: [
        Color(0xFF2A0610),
        Color(0xFF7A1A30),
        Color(0xFFFF4E78),
        Color(0xFFFFA0B8),
        Color(0xFFFFE0E8),
      ],
    ),
  ];
}

/// Versao desktop da lista de planetas. Mantem os 10 corpos da mobile
/// (mas re-espaca o flanco esquerdo) e adiciona +5 novos (3 esquerda,
/// 2 direita) pra popular wide screens (1920+). Regra de espacamento:
/// esquerda em x ∈ {0.03, 0.05, 0.08, 0.12, 0.16, 0.20}, y distribuido
/// de 0.10 ate 0.92 sem clusterizar em 3 pontos.
List<CosmosPlanet> _heroPlanetsDesktop() {
  return const [
    // Red giant — canto superior direito, off-canvas.
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
    // Ice ringed — flanco esquerdo alto, puxado pra fora (0.12 vs 0.18).
    CosmosPlanet(
      id: 'ice-world',
      canvasAnchor: Offset(0.12, 0.22),
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
    // Magenta giant — canto inferior direito.
    CosmosPlanet(
      id: 'magenta-giant',
      canvasAnchor: Offset(0.88, 0.86),
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
    // Lime rocky — flanco esquerdo baixo, puxado pra fora (0.05 vs 0.10).
    CosmosPlanet(
      id: 'lime-rocky',
      canvasAnchor: Offset(0.05, 0.84),
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
    // Electric blue — topo direita.
    CosmosPlanet(
      id: 'electric-blue',
      canvasAnchor: Offset(0.84, 0.14),
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
    // Violet rocky — borda direita, meio. Puxado pra 0.92 pra fanar.
    CosmosPlanet(
      id: 'violet-rocky',
      canvasAnchor: Offset(0.92, 0.46),
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
    // Teal-mint — flanco esquerdo meio, x 0.03 (vs 0.05).
    CosmosPlanet(
      id: 'teal-world',
      canvasAnchor: Offset(0.03, 0.48),
      radiusPixels: 16,
      pattern: PlanetPattern.bands,
      seed: 53,
      palette: [
        Color(0xFF02100E),
        Color(0xFF0A4A3D),
        Color(0xFF1FE5B5),
        Color(0xFFA5FFE5),
        Color(0xFFE9FFF8),
      ],
      moon: PlanetMoon(
        orbitRadiusPixels: 26,
        moonRadiusPixels: 2,
        color: Color(0xFFE6FFF8),
        phaseOffset: 0.3,
      ),
    ),
    // Amber dwarf — esquerda alta, x 0.02 (mais externo).
    CosmosPlanet(
      id: 'amber-dwarf',
      canvasAnchor: Offset(0.02, 0.32),
      radiusPixels: 9,
      pattern: PlanetPattern.hemispheres,
      seed: 61,
      palette: [
        Color(0xFF2A1500),
        Color(0xFF7A4205),
        Color(0xFFFFA82A),
        Color(0xFFFFD58A),
        Color(0xFFFFF1D6),
      ],
    ),
    // Indigo rocky — esquerda baixa-meio, x 0.20 (mais interno),
    // preenche faixa intermediaria perto da foto.
    CosmosPlanet(
      id: 'indigo-rocky',
      canvasAnchor: Offset(0.20, 0.66),
      radiusPixels: 11,
      pattern: PlanetPattern.speckled,
      seed: 73,
      palette: [
        Color(0xFF08081C),
        Color(0xFF1F2280),
        Color(0xFF3F66FF),
        Color(0xFF9BB8FF),
        Color(0xFFE0EBFF),
      ],
    ),
    // Coral-rose — esquerda baixa, x 0.08.
    CosmosPlanet(
      id: 'coral-rose',
      canvasAnchor: Offset(0.08, 0.74),
      radiusPixels: 8,
      pattern: PlanetPattern.bands,
      seed: 83,
      palette: [
        Color(0xFF2A0610),
        Color(0xFF7A1A30),
        Color(0xFFFF4E78),
        Color(0xFFFFA0B8),
        Color(0xFFFFE0E8),
      ],
    ),
    // === Novos corpos desktop-only (5) — popular o flanco esquerdo ===
    // Cyan-mint dwarf — x 0.16, y 0.10 (topo esquerdo, entre red giant
    // off-canvas e ice ringed).
    CosmosPlanet(
      id: 'cyan-dwarf',
      canvasAnchor: Offset(0.16, 0.10),
      radiusPixels: 7,
      pattern: PlanetPattern.hemispheres,
      seed: 101,
      palette: [
        Color(0xFF021A1F),
        Color(0xFF0A5566),
        Color(0xFF2DE5D8),
        Color(0xFFA5FFF5),
        Color(0xFFE9FFFB),
      ],
    ),
    // Magenta rocky pequeno — x 0.18, y 0.40 (preenche meio-esquerda
    // entre amber dwarf e teal world, lado de fora da foto).
    CosmosPlanet(
      id: 'magenta-dwarf',
      canvasAnchor: Offset(0.18, 0.40),
      radiusPixels: 6,
      pattern: PlanetPattern.speckled,
      seed: 109,
      palette: [
        Color(0xFF24061A),
        Color(0xFF66124A),
        Color(0xFFE040A0),
        Color(0xFFFFA0D5),
        Color(0xFFFFE0F0),
      ],
    ),
    // Pale-gold dwarf — x 0.06, y 0.92 (canto inferior esquerdo,
    // ancora a base do flanco junto com lime-rocky).
    CosmosPlanet(
      id: 'pale-gold',
      canvasAnchor: Offset(0.06, 0.94),
      radiusPixels: 10,
      pattern: PlanetPattern.bands,
      seed: 127,
      palette: [
        Color(0xFF1F1505),
        Color(0xFF6A4A0A),
        Color(0xFFE6C25A),
        Color(0xFFFFE8A5),
        Color(0xFFFFF7DC),
      ],
    ),
    // Deep purple — x 0.94, y 0.74 (flanco direito, abaixo do violet
    // rocky, simetria com pale-gold).
    CosmosPlanet(
      id: 'deep-purple',
      canvasAnchor: Offset(0.94, 0.72),
      radiusPixels: 8,
      pattern: PlanetPattern.speckled,
      seed: 137,
      palette: [
        Color(0xFF0A0420),
        Color(0xFF2E1466),
        Color(0xFF6B40E0),
        Color(0xFFB89BFF),
        Color(0xFFE6DCFF),
      ],
    ),
    // Sun-yellow dwarf — x 0.96, y 0.28 (flanco direito alto, entre
    // electric blue e violet rocky).
    CosmosPlanet(
      id: 'sun-yellow',
      canvasAnchor: Offset(0.96, 0.28),
      radiusPixels: 7,
      pattern: PlanetPattern.hemispheres,
      seed: 149,
      palette: [
        Color(0xFF2A1F00),
        Color(0xFF7A5A05),
        Color(0xFFFFD22A),
        Color(0xFFFFE88A),
        Color(0xFFFFF8D6),
      ],
    ),
  ];
}

/// Nebulosas customizadas pro hero — coladas nas bordas, longe do centro.
/// Default tem nebula em (0.42, 0.38) e (0.42, 0.80) que poluem o eixo de
/// leitura; aqui empurramos pras laterais.
List<CosmosNebula> _heroNebulas({required bool isMobile}) {
  // Desktop puxa as nebulas das bordas pra fora (0.10 -> 0.06, 0.88 ->
  // 0.92) acompanhando o frame expandido.
  final leftX = isMobile ? 0.12 : 0.06;
  final rightX = isMobile ? 0.88 : 0.92;
  return [
    const CosmosNebula(
      canvasAnchor: Offset(0.86, 0.06),
      radiusPixels: 110,
      color: Color(0xFFFF1F8B),
      density: 0.78,
      seed: 4,
    ),
    CosmosNebula(
      canvasAnchor: Offset(leftX, 0.20),
      radiusPixels: 70,
      color: const Color(0xFF0AC4FF),
      density: 0.62,
      seed: 1,
    ),
    CosmosNebula(
      canvasAnchor: Offset(rightX, 0.50),
      radiusPixels: 60,
      color: const Color(0xFF9D3FFF),
      seed: 6,
    ),
    CosmosNebula(
      canvasAnchor: Offset(isMobile ? 0.10 : 0.04, 0.88),
      radiusPixels: 64,
      color: const Color(0xFFE020F2),
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
List<CosmosGalaxy> _heroGalaxies({required bool isMobile}) {
  if (!isMobile) {
    // Desktop: cyan-pink top-left empurrada pra x=0.10 (vs 0.15), e a
    // violet-cream bottom-right pra x=0.92 (vs 0.88) — acompanha o
    // espacamento dos planetas no flanco.
    return const [
      CosmosGalaxy(
        canvasAnchor: Offset(0.92, 0.88),
        radiusPixels: 160,
        coreColor: Color(0xFFFFE8C2),
        armColor: Color(0xFF9D3FFF),
        armCount: 4,
        tiltY: 0.38,
        rotation: -0.7,
        dustCount: 320,
        seed: 41,
      ),
      CosmosGalaxy(
        canvasAnchor: Offset(0.10, 0.18),
        radiusPixels: 90,
        coreColor: Color(0xFFE8FBFF),
        armColor: Color(0xFFFF1F8B),
        tiltY: 0.55,
        rotation: 1.2,
        dustCount: 200,
        seed: 67,
      ),
      // Galaxia violet-cream colada abaixo da foto — espelha a do
      // canto direito (mesma familia de cor + tilt), ancora a base da
      // silhueta dando sensacao de profundidade local sem virar
      // grounding chapado.
      CosmosGalaxy(
        canvasAnchor: Offset(0.30, 0.92),
        radiusPixels: 110,
        coreColor: Color(0xFFFFE8C2),
        armColor: Color(0xFF9D3FFF),
        armCount: 4,
        tiltY: 0.42,
        rotation: 0.4,
        dustCount: 240,
        seed: 89,
      ),
    ];
  }
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
List<CosmosPulsar> _heroPulsars({required bool isMobile}) {
  if (!isMobile) {
    // Desktop: 5 pulsares (vs 4 mobile). Adiciona um cyan extra no
    // flanco esquerdo alto pra popular essa faixa, e re-espaca os
    // existentes nas bordas externas.
    return const [
      CosmosPulsar(
        canvasAnchor: Offset(0.92, 0.32),
        coreColor: Color(0xFF99FFEC),
        beamColor: Color(0xFF0AC4FF),
        beamLengthPixels: 64,
        seed: 31,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.04, 0.56),
        coreColor: Color(0xFFFFCFF8),
        beamColor: Color(0xFFFF1F8B),
        coreRadiusPixels: 2,
        beamLengthPixels: 50,
        phaseOffset: 0.37,
        seed: 47,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.72, 0.08),
        coreColor: Color(0xFFFFF8C8),
        beamColor: Color(0xFFFFB81F),
        coreRadiusPixels: 2,
        beamLengthPixels: 42,
        phaseOffset: 0.62,
        seed: 53,
      ),
      CosmosPulsar(
        canvasAnchor: Offset(0.12, 0.92),
        coreColor: Color(0xFFF0DCFF),
        beamColor: Color(0xFF9D3FFF),
        coreRadiusPixels: 2,
        beamLengthPixels: 38,
        phaseOffset: 0.83,
        seed: 71,
      ),
      // Novo: cyan flare no flanco esquerdo alto, dialogando com a
      // galaxia cyan-pink ali em cima.
      CosmosPulsar(
        canvasAnchor: Offset(0.06, 0.16),
        coreColor: Color(0xFFE8FBFF),
        beamColor: Color(0xFF06D4FF),
        coreRadiusPixels: 2,
        beamLengthPixels: 44,
        phaseOffset: 0.21,
        seed: 89,
      ),
    ];
  }
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
List<CosmosAsteroidBelt> _heroAsteroidBelts({required bool isMobile}) {
  if (!isMobile) {
    // Desktop: re-ancora os dois cinturoes mais pra fora seguindo as
    // galaxias que envolvem.
    return const [
      CosmosAsteroidBelt(
        canvasAnchor: Offset(0.10, 0.20),
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
      CosmosAsteroidBelt(
        canvasAnchor: Offset(0.90, 0.60),
        radiusPixels: 110,
        rockColor: Color(0xFFE8B5C8),
        highlightColor: Color(0xFFFFCFF8),
        tiltY: 0.36,
        rotation: 0.9,
        rockCount: 180,
        arcStart: 0.15,
        arcSweep: 0.80,
        seed: 119,
      ),
    ];
  }
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
    // Segundo cinturao — direita-baixa, envolvendo a galaxy violet,
    // tilt e rotacao opostos pro movimento nao ficar uniforme.
    CosmosAsteroidBelt(
      canvasAnchor: Offset(0.86, 0.62),
      radiusPixels: 110,
      rockColor: Color(0xFFE8B5C8),
      highlightColor: Color(0xFFFFCFF8),
      tiltY: 0.36,
      rotation: 0.9,
      rockCount: 180,
      arcStart: 0.15,
      arcSweep: 0.80,
      seed: 119,
    ),
  ];
}

/// Wisps customizados pro hero — duas nuvens de gas no lado esquerdo
/// pra densificar a area entre foto e borda sem competir com a aura.
/// Tons distintos (cyan-magenta e violet-pink) pra dialogar com a paleta
/// dos planetas vizinhos.
List<CosmosWisp> _heroWisps({required bool isMobile}) {
  if (!isMobile) {
    // Desktop: 3 wisps (vs 2 mobile). Os dois originais sao re-ancorados
    // mais pra fora e ganha um terceiro no flanco direito-baixo pra que
    // ambos os lados respirem.
    return const [
      CosmosWisp(
        canvasAnchor: Offset(0.04, 0.40),
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
      CosmosWisp(
        canvasAnchor: Offset(0.14, 0.62),
        radiusPixels: 90,
        colors: [
          Color(0xFFFF1F8B),
          Color(0xFFFF66F5),
          Color(0xFFFFCFF8),
        ],
        density: 0.45,
        seed: 37,
      ),
      // Novo: wisp violet-blue no flanco direito-baixo pra simetria.
      CosmosWisp(
        canvasAnchor: Offset(0.94, 0.40),
        radiusPixels: 100,
        colors: [
          Color(0xFF8B5CF6),
          Color(0xFF2D7FFF),
          Color(0xFF7CB8FF),
        ],
        driftPixels: 14,
        density: 0.42,
        seed: 79,
      ),
    ];
  }
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
class _HeroPortrait extends StatelessWidget {
  const _HeroPortrait({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final maxWidth = isMobile ? double.infinity : 460.0;
    final maxHeight = isMobile ? 380.0 : 600.0;

    // Paleta da aura: violet/indigo da marca + um rosa-neon quente
    // no halo proximo pra ecoar o gradient do headline.
    const farTint = Color(0xFF7132F5);
    const midTint = Color(0xFF5741D8);
    const closeTint = Color(0xFFFF2D95);

    const assetPath = 'assets/images/foto_recortada.png';

    return Semantics(
      label: 'Foto de Jose Guilherme Alves',
      image: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo silhueta-aware: 3 layers blurradas+tingidas via
              // srcIn. Sigmas crescem do mais externo (mais difuso) ao
              // mais interno (rim quente colado no contorno).
              const _SilhouetteAura(
                assetPath: assetPath,
                farTint: farTint,
                midTint: midTint,
                closeTint: closeTint,
              ),
              // Silhueta crisp por cima — o foco optico do frame.
              Image.asset(
                assetPath,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Halo que respira em torno do recorte. Stack de 3 copias do mesmo
/// PNG, cada uma com ColorFiltered (`srcIn`) preenchendo a silhueta
/// com uma cor solida, depois ImageFiltered (`blur`) dilatando o
/// contorno pra fora. A combinacao produz glow que segue a forma da
/// pessoa, nao o retangulo do frame.
///
/// Performance: cada Image.asset reusa o mesmo arquivo via image
/// cache do Flutter (zero upload extra de textura). `RepaintBoundary`
/// por camada isola o offscreen do `ImageFiltered` — caro quando o
/// sigma muda, mas confinado a sua propria subtree. Apenas as camadas
/// de glow assinam o controller (AnimatedBuilder); a imagem crisp
/// fica fora do ciclo de repaint.
class _SilhouetteAura extends StatefulWidget {
  const _SilhouetteAura({
    required this.assetPath,
    required this.farTint,
    required this.midTint,
    required this.closeTint,
  });

  final String assetPath;
  final Color farTint;
  final Color midTint;
  final Color closeTint;

  @override
  State<_SilhouetteAura> createState() => _SilhouetteAuraState();
}

class _SilhouetteAuraState extends State<_SilhouetteAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  // Sigmas base por camada — far/mid/close. Range animado [0.85x,
  // 1.15x] da sensacao de respiracao sem pulsar agressivo. Pensados
  // pra PNG de ~377px de largura: 42 cobre halo amplo, 20 traz um
  // meio-termo colorido, 7 deixa um rim quente colado no contorno.
  static const double _farSigma = 42;
  static const double _midSigma = 20;
  static const double _closeSigma = 7;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, _) {
          // t oscila 0..1, sigmaMul 0.85..1.15, alphaMul 0.85..1.0.
          final t = _breath.value;
          final sigmaMul = 0.85 + 0.30 * t;
          final alphaMul = 0.85 + 0.15 * t;

          return Stack(
            fit: StackFit.expand,
            children: [
              _AuraLayer(
                assetPath: widget.assetPath,
                tint: widget.farTint,
                baseAlpha: 0.55,
                sigma: _farSigma * sigmaMul,
                alphaMul: alphaMul,
              ),
              _AuraLayer(
                assetPath: widget.assetPath,
                tint: widget.midTint,
                baseAlpha: 0.65,
                sigma: _midSigma * sigmaMul,
                alphaMul: alphaMul,
              ),
              _AuraLayer(
                assetPath: widget.assetPath,
                tint: widget.closeTint,
                baseAlpha: 0.55,
                sigma: _closeSigma * sigmaMul,
                alphaMul: alphaMul,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Uma camada do halo: PNG -> srcIn (tint) -> blur (dilata pra fora).
/// `RepaintBoundary` isola o offscreen do ImageFiltered num display
/// list dedicado.
class _AuraLayer extends StatelessWidget {
  const _AuraLayer({
    required this.assetPath,
    required this.tint,
    required this.baseAlpha,
    required this.sigma,
    required this.alphaMul,
  });

  final String assetPath;
  final Color tint;
  final double baseAlpha;
  final double sigma;
  final double alphaMul;

  @override
  Widget build(BuildContext context) {
    final effectiveAlpha = (baseAlpha * alphaMul).clamp(0.0, 1.0);
    // Usamos DecoratedBox + DecorationImage (ao inves de Image.asset)
    // pra que a busca de testes por widget `Image` continue achando
    // apenas a copia crisp. Mesmo AssetImage provider entra no image
    // cache do Flutter, entao o reuso de textura permanece.
    return RepaintBoundary(
      child: Opacity(
        opacity: effectiveAlpha,
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetPath),
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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
