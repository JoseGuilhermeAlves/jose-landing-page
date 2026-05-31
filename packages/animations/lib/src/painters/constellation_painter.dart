import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Padrao estelar nomeado — coordenadas das estrelas em espaco local
/// 0..1, lista de arestas conectando pares de indices, ancoragem no
/// canvas em coords fracionais (0..1 do canvas) e tamanho relativo
/// (fracao do menor lado do canvas).
@immutable
class Constellation {
  const Constellation({
    required this.id,
    required this.stars,
    required this.edges,
    required this.canvasAnchor,
    this.size = 0.2,
  });

  /// Identificador estavel (ex.: 'crux', 'orion').
  final String id;

  /// Posicao de cada estrela no espaco local 0..1 (centro do recorte
  /// fica em (0.5, 0.5)).
  final List<Offset> stars;

  /// Pares de indices [stars] que devem ser ligados por linha.
  final List<(int, int)> edges;

  /// Onde o centro da constelacao fica no canvas, em fracoes 0..1.
  final Offset canvasAnchor;

  /// Tamanho da constelacao como fracao do menor lado do canvas.
  /// Default 0.2 = 20%.
  final double size;
}

/// Catalogo canonico de constelacoes incluidas por default no
/// `ConstellationPainter`. Coordenadas aproximadas — orientadas pro
/// look visual, nao pra precisao astronomica.
abstract final class KnownConstellations {
  /// Cruzeiro do Sul — toque cultural BR. 5 estrelas: Acrux, Mimosa,
  /// Gacrux, Imai e Ginan (esta ultima menor, dentro do recorte).
  static const Constellation cruzeiroDoSul = Constellation(
    id: 'crux',
    stars: [
      Offset(0.5, 0.0), // Gacrux (topo)
      Offset(1.0, 0.5), // Mimosa (leste)
      Offset(0.5, 1.0), // Acrux (sul)
      Offset(0.0, 0.5), // Imai (oeste)
      Offset(0.42, 0.55), // Ginan (interna)
    ],
    edges: [(0, 2), (1, 3)],
    canvasAnchor: Offset(0.85, 0.32),
    size: 0.18,
  );

  /// Orion — Bellatrix, Betelgeuse, cinturao (3 estrelas), Saiph e
  /// Rigel.
  static const Constellation orion = Constellation(
    id: 'orion',
    stars: [
      Offset(0.2, 0.1), // Bellatrix (ombro esq)
      Offset(0.8, 0.15), // Betelgeuse (ombro dir)
      Offset(0.35, 0.5), // Mintaka (cinturao 1)
      Offset(0.5, 0.55), // Alnilam (cinturao 2)
      Offset(0.65, 0.6), // Alnitak (cinturao 3)
      Offset(0.3, 0.95), // Saiph (pe esq)
      Offset(0.75, 1.0), // Rigel (pe dir)
    ],
    edges: [
      (0, 2), // ombro esq -> cinturao
      (1, 4), // ombro dir -> cinturao
      (2, 3), (3, 4), // cinturao
      (2, 5), // cinturao -> pe esq
      (4, 6), // cinturao -> pe dir
      (5, 6), // pes
    ],
    canvasAnchor: Offset(0.18, 0.28),
    size: 0.24,
  );

  /// Triangulo de Verao — 3 estrelas (Vega, Altair, Deneb).
  static const Constellation trianguloDeVerao = Constellation(
    id: 'summer_triangle',
    stars: [
      Offset(0.5, 0.0), // Vega
      Offset(0.0, 1.0), // Altair
      Offset(1.0, 0.7), // Deneb
    ],
    edges: [(0, 1), (1, 2), (2, 0)],
    canvasAnchor: Offset(0.55, 0.18),
    size: 0.16,
  );

  static const List<Constellation> all = [
    orion,
    trianguloDeVerao,
    cruzeiroDoSul,
  ];
}

/// Desenha um conjunto de constelacoes — estrelas em pequeno disco com
/// flare em cruz (4 pontas), conectadas por linhas finas. Cada estrela
/// pisca (twinkle) em fase propria, alimentada pelo `tick` global.
///
/// Performance:
/// - `Paint` cacheados em campos finais;
/// - varredura O(numero de estrelas) — geometria leve, dezenas de
///   estrelas no maximo;
/// - `shouldRepaint` so volta `true` quando algo do estado visual muda.
class ConstellationPainter extends CustomPainter {
  ConstellationPainter({
    double? tick,
    this.animation,
    required this.starColor,
    required this.linkColor,
    this.constellations = KnownConstellations.all,
    this.starRadius = 1.6,
    this.flareLength = 4.5,
    this.linkStrokeWidth = 0.5,
  })  : _tick = tick ?? 0,
        super(repaint: animation);

  final Animation<double>? animation;
  final double _tick;
  double get tick => animation?.value ?? _tick;

  final Color starColor;
  final Color linkColor;
  final List<Constellation> constellations;

  /// Raio do disco central da estrela.
  final double starRadius;

  /// Comprimento de cada uma das 4 pontas de luz.
  final double flareLength;

  final double linkStrokeWidth;

  late final Paint _starPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  late final Paint _flarePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..strokeWidth = 0.6;

  late final Paint _linkPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = linkStrokeWidth
    ..isAntiAlias = true
    ..color = linkColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || constellations.isEmpty) return;

    final shortest = math.min(size.width, size.height);

    for (final c in constellations) {
      final scale = c.size * shortest;
      final anchorX = c.canvasAnchor.dx * size.width;
      final anchorY = c.canvasAnchor.dy * size.height;

      // Posicoes globais das estrelas — recortadas de coords locais
      // (0..1) pro canvas, com (0.5, 0.5) caindo na ancora.
      final positions = List<Offset>.generate(c.stars.length, (i) {
        final s = c.stars[i];
        return Offset(
          anchorX + (s.dx - 0.5) * scale,
          anchorY + (s.dy - 0.5) * scale,
        );
      });

      // Linhas conectando as estrelas (desenhadas antes pra ficarem
      // atras dos discos).
      for (final (a, b) in c.edges) {
        canvas.drawLine(positions[a], positions[b], _linkPaint);
      }

      // Estrelas com twinkle independente por indice.
      for (var i = 0; i < positions.length; i++) {
        final phase = i * 1.7;
        final twinkle =
            0.65 + 0.35 * (0.5 + 0.5 * math.sin(tick * 2 * math.pi + phase));
        final p = positions[i];

        _starPaint.color = starColor.withValues(alpha: starColor.a * twinkle);
        _flarePaint.color = starColor.withValues(
          alpha: starColor.a * twinkle * 0.55,
        );

        canvas.drawCircle(p, starRadius, _starPaint);

        // Flare em cruz (4 pontas).
        canvas
          ..drawLine(
            Offset(p.dx - flareLength, p.dy),
            Offset(p.dx + flareLength, p.dy),
            _flarePaint,
          )
          ..drawLine(
            Offset(p.dx, p.dy - flareLength),
            Offset(p.dx, p.dy + flareLength),
            _flarePaint,
          );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConstellationPainter old) {
    return old.tick != tick ||
        old.starColor != starColor ||
        old.linkColor != linkColor ||
        old.constellations != constellations ||
        old.starRadius != starRadius ||
        old.flareLength != flareLength ||
        old.linkStrokeWidth != linkStrokeWidth;
  }

  /// Hint para o `CustomPaint` host: poucas formas, nao vale rasterizar.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima continuamente (twinkle).
  bool get willChange => true;
}
