import 'package:flutter/material.dart';

/// Modelos imutáveis consumidos pelo [CosmosPainter]: padrões de
/// superfície (`PlanetPattern`), corpos celestes (`CosmosPlanet`,
/// `CosmosNebula`, `CosmosGalaxy`, `CosmosPulsar`, `CosmosAsteroidBelt`,
/// `CosmosWisp`, `CosmosComet`) e ornamentos (`PlanetRing`,
/// `PlanetMoon`).
///
/// Extraído do painter pra deixar `cosmos_painter.dart` focado na
/// lógica de renderização. Reexportado pelo barrel via
/// `cosmos_painter.dart` (transitivo).

/// Padrao da superficie do planeta.
enum PlanetPattern {
  /// Faixas horizontais com vortex spot — gas giant.
  bands,

  /// Manchas / "continentes" pseudo-aleatorios — planeta rochoso.
  speckled,

  /// Hemisferio inferior mais escuro + polar caps brilhantes.
  hemispheres,
}

@immutable
class PlanetRing {
  const PlanetRing({
    required this.innerRadiusPixels,
    required this.outerRadiusPixels,
    required this.color,
    this.tiltY = 0.30,
  });

  final int innerRadiusPixels;
  final int outerRadiusPixels;
  final Color color;
  final double tiltY;
}

@immutable
class PlanetMoon {
  const PlanetMoon({
    required this.orbitRadiusPixels,
    required this.moonRadiusPixels,
    required this.color,
    this.steps = 0,
    this.phaseOffset = 0.0,
  });

  final int orbitRadiusPixels;
  final int moonRadiusPixels;
  final Color color;
  final int steps;
  final double phaseOffset;
}

@immutable
class CosmosPlanet {
  const CosmosPlanet({
    required this.id,
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.palette,
    required this.pattern,
    this.ring,
    this.moon,
    this.seed = 0,
  });

  final String id;
  final Offset canvasAnchor;
  final int radiusPixels;

  /// Palette ideal 4-5 cores: [shadow, mid-dark, mid, mid-light, highlight].
  /// O painter usa palette[0] como base do corpo, palette.last como rim/glow,
  /// e os intermediarios pra surface detail.
  final List<Color> palette;

  final PlanetPattern pattern;
  final PlanetRing? ring;
  final PlanetMoon? moon;
  final int seed;
}

@immutable
class CosmosNebula {
  const CosmosNebula({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.color,
    this.density = 0.55,
    this.seed = 0,
  });

  final Offset canvasAnchor;
  final int radiusPixels;
  final Color color;
  final double density;
  final int seed;
}

/// Galaxia espiral — pinwheel com nucleo bright, bracos em espiral
/// logaritmica e poeira/estrelas dispersas. Suporta inclinacao `tiltY`
/// (achatamento vertical pra sensacao de plano galactico inclinado) e
/// rotacao lenta amarrada ao `tick` do painter.
///
/// Usada como centerpiece de fundo (renderiza antes das nebulosas).
/// Cores tipicas: nucleo creme/branco quente, bracos em tom frio (cyan,
/// violet, magenta).
@immutable
class CosmosGalaxy {
  const CosmosGalaxy({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.coreColor,
    required this.armColor,
    this.armCount = 2,
    this.tiltY = 0.45,
    this.rotation = 0.0,
    this.dustCount = 220,
    this.seed = 0,
  });

  final Offset canvasAnchor;
  final int radiusPixels;

  /// Cor do nucleo brilhante (centro denso).
  final Color coreColor;

  /// Cor dominante dos bracos espirais (poeira + estrelas).
  final Color armColor;

  /// 2 ou 4 dao melhor leitura visual.
  final int armCount;

  /// Achatamento vertical (0.05..1.0). Valor < 1 simula plano inclinado.
  final double tiltY;

  /// Offset estatico de rotacao em radianos. O painter adiciona drift
  /// derivado de `tick`.
  final double rotation;

  /// Quantidade de pontos de poeira espalhados ao longo dos bracos.
  /// Renderizados em batch via `drawPoints(PointMode.points)`.
  final int dustCount;

  final int seed;
}

/// Pulsar — estrela de neutrons pequena e brilhante com dois feixes de
/// luz girando radialmente, estilo farol. Pulso de brilho rapido
/// (sine sync com `tick`) reforca o ritmo. Compacto e pontual, ideal
/// como acento ornamental.
@immutable
class CosmosPulsar {
  const CosmosPulsar({
    required this.canvasAnchor,
    required this.coreColor,
    required this.beamColor,
    this.coreRadiusPixels = 3,
    this.beamLengthPixels = 80,
    this.beamWidthRadians = 0.10,
    this.phaseOffset = 0.0,
    this.seed = 0,
  });

  final Offset canvasAnchor;
  final Color coreColor;
  final Color beamColor;

  /// Raio do nucleo brilhante (logico, antes do `pixelSize`).
  final int coreRadiusPixels;

  /// Comprimento dos feixes (logico, antes do `pixelSize`).
  final int beamLengthPixels;

  /// Abertura angular do feixe em radianos. ~0.10 da um leque estreito
  /// estilo farol; valores maiores espalham demais.
  final double beamWidthRadians;

  /// Offset de fase em [0,1] pra dessincronizar pulsares vizinhos.
  final double phaseOffset;

  final int seed;
}

/// Cinturao de asteroides — ribbon de pequenas rochas distribuidas em uma
/// elipse inclinada (plano orbital visto em perspectiva). Roda lentamente
/// em torno do centro (~25% de uma volta por ciclo). Cada rocha tem
/// tamanho e tinta variados (cinza rochoso + highlights quentes ou
/// gelados), seed-determinista. Renderizadas em batch via
/// `drawPoints(PointMode.points)` pra suportar densidade alta sem custo
/// por-rocha.
///
/// Usado como camada mid (entre planetas e pulsares). Distinto do anel de
/// planeta porque nao orbita um corpo especifico — flutua livre.
@immutable
class CosmosAsteroidBelt {
  const CosmosAsteroidBelt({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.rockColor,
    required this.highlightColor,
    this.tiltY = 0.30,
    this.rotation = 0.0,
    this.thicknessFactor = 0.18,
    this.rockCount = 140,
    this.arcStart = 0.0,
    this.arcSweep = 1.0,
    this.seed = 0,
  });

  final Offset canvasAnchor;

  /// Raio medio do cinturao (eixo maior da elipse).
  final int radiusPixels;

  /// Cor dominante das rochas (cinza rochoso ou tom escuro frio).
  final Color rockColor;

  /// Cor dos brilhos pontuais (gold quente, white gelado).
  final Color highlightColor;

  /// Achatamento vertical (0.05..1.0). Valor < 1 simula plano orbital
  /// inclinado em perspectiva.
  final double tiltY;

  /// Offset estatico de rotacao em radianos. O painter adiciona drift
  /// derivado de `tick`.
  final double rotation;

  /// Espessura radial relativa ao raio (0..1). 0.18 = banda fina como
  /// cinturao classico; valores maiores espalham mais.
  final double thicknessFactor;

  /// Quantidade de rochas. Renderizadas em batch via `drawPoints`.
  final int rockCount;

  /// Fracao [0,1] de onde comeca o arco. 0 = leste do centro.
  final double arcStart;

  /// Fracao [0,1] de quanto do circulo cobrir. 1 = completo;
  /// 0.6 = ribbon parcial pra sensacao de arco.
  final double arcSweep;

  final int seed;
}

/// Wisp — nuvem de gas concentrada com multiplas bolhas de cor soft
/// sobrepostas, drift turbulento via offsets seed-deterministas. Distinta
/// de nebulosa por ser mais densa, concentrada e visivelmente animada
/// (cada blob respira numa fase diferente).
///
/// Usado como camada atmosferica (entre nebulosas e planetas). Boa pra
/// preencher cantos vazios sem competir com focal points.
@immutable
class CosmosWisp {
  const CosmosWisp({
    required this.canvasAnchor,
    required this.radiusPixels,
    required this.colors,
    this.blobCount = 5,
    this.driftPixels = 12,
    this.density = 0.6,
    this.seed = 0,
  });

  final Offset canvasAnchor;

  /// Raio aparente do cluster como um todo (envelope externo).
  final int radiusPixels;

  /// 2-4 cores soft. Cada blob escolhe ciclicamente — overlap de tintas
  /// distintas gera profundidade tipo gas iridescente.
  final List<Color> colors;

  /// Quantidade de blobs sobrepostos. 4-7 da volume sem virar mancha.
  final int blobCount;

  /// Amplitude maxima do drift (logico, antes do `pixelSize`).
  final int driftPixels;

  /// Multiplicador global de alpha (0..1).
  final double density;

  final int seed;
}

@immutable
class CosmosComet {
  const CosmosComet({
    required this.startAnchor,
    required this.endAnchor,
    required this.tailLengthPixels,
    required this.color,
    this.windowStart = 0.0,
    this.windowEnd = 0.18,
  });

  final Offset startAnchor;
  final Offset endAnchor;
  final int tailLengthPixels;
  final Color color;
  final double windowStart;
  final double windowEnd;
}
