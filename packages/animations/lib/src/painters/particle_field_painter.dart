import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Campo de particulas reativo ao mouse — usado como background do Hero
/// (PROJECT.md §5.1). Particulas se deslocam suavemente por seno/cosseno
/// e sao empurradas radialmente quando o ponteiro entra no raio de
/// influencia. Linhas conectam pares proximos (efeito "constelacao").
///
/// Decisoes de performance:
/// - Posicoes iniciais geradas por [math.Random] *seedado* (deterministico,
///   testavel e estavel entre reinicios);
/// - [Paint] cacheados como campos finais (regra invariavel do projeto);
/// - `shouldRepaint` so volta `true` quando `tick` ou `pointer` mudam;
/// - `willChange = true` (anima continuamente);
/// - `isComplex = true` (com 50+ particulas vale rasterizar em layer).
///
/// Throttle de eventos do ponteiro NAO acontece aqui — fica a cargo do
/// widget host (`ParticleField`) pra manter o painter puro e testavel.
class ParticleFieldPainter extends CustomPainter {
  ParticleFieldPainter({
    required this.tick,
    required this.particleColor,
    required this.linkColor,
    this.pointer,
    this.particleCount = 36,
    this.seed = 7,
    this.linkDistance = 90,
    this.pointerInfluence = 80,
    this.pointerPushStrength = 18,
    this.particleRadius = 1.6,
    this.driftAmplitude = 14,
  });

  /// Fase global da animacao (0..1 em loop).
  final double tick;

  /// Posicao do ponteiro em coordenadas do canvas. `null` desativa
  /// o efeito de empurrao.
  final Offset? pointer;

  final int particleCount;
  final int seed;
  final Color particleColor;
  final Color linkColor;
  final double linkDistance;
  final double pointerInfluence;
  final double pointerPushStrength;
  final double particleRadius;
  final double driftAmplitude;

  late final Paint _particlePaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true
    ..color = particleColor;

  late final Paint _linkPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.6
    ..isAntiAlias = true
    ..color = linkColor;

  /// Sementes precomputadas — fase e velocidade angular de cada
  /// particula. Como [math.Random] e seedado, o resultado e estavel.
  late final List<_Seed> _seeds = _buildSeeds();

  List<_Seed> _buildSeeds() {
    final rng = math.Random(seed);
    return List.generate(particleCount, (_) {
      return _Seed(
        anchorXFraction: rng.nextDouble(),
        anchorYFraction: rng.nextDouble(),
        phase: rng.nextDouble() * math.pi * 2,
        speed: 0.5 + rng.nextDouble() * 1.2,
        angle: rng.nextDouble() * math.pi * 2,
      );
    });
  }

  /// Calcula posicoes finais para o frame atual em [size].
  /// O parametro [t] permite override em testes (default usa `tick`).
  @visibleForTesting
  List<Offset> debugPositionsAt(Size size, {double? t}) {
    return _computePositions(size, t ?? tick);
  }

  /// Posicoes ancora antes do drift (uteis para asserts deterministicos
  /// do seeding).
  @visibleForTesting
  List<Offset> debugInitialPositions(Size size) {
    return _seeds
        .map((s) => Offset(s.anchorXFraction * size.width,
            s.anchorYFraction * size.height))
        .toList(growable: false);
  }

  List<Offset> _computePositions(Size size, double t) {
    if (size.isEmpty) return const [];

    final result = List<Offset>.filled(_seeds.length, Offset.zero);
    final phaseTime = t * 2 * math.pi;

    for (var i = 0; i < _seeds.length; i++) {
      final s = _seeds[i];
      final anchor = Offset(
        s.anchorXFraction * size.width,
        s.anchorYFraction * size.height,
      );
      // Drift suave em circulo elastico.
      final dx = math.cos(phaseTime * s.speed + s.phase) * driftAmplitude;
      final dy = math.sin(phaseTime * s.speed + s.phase) * driftAmplitude;
      var p = anchor + Offset(dx, dy);

      // Empurrao radial pelo pointer — quanto mais perto, mais forte.
      final pointer = this.pointer;
      if (pointer != null && pointerInfluence > 0) {
        final delta = p - pointer;
        final dist = delta.distance;
        if (dist > 0 && dist < pointerInfluence) {
          final falloff = 1 - (dist / pointerInfluence);
          final push = (delta / dist) * pointerPushStrength * falloff;
          p += push;
        }
      }

      // Clamp final dentro dos bounds.
      p = Offset(
        p.dx.clamp(0, size.width),
        p.dy.clamp(0, size.height),
      );
      result[i] = p;
    }

    return result;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final positions = _computePositions(size, tick);

    // Linhas entre pares proximos. O custo e O(n^2) mas n <= 60.
    if (linkDistance > 0) {
      final linkSqr = linkDistance * linkDistance;
      for (var i = 0; i < positions.length; i++) {
        for (var j = i + 1; j < positions.length; j++) {
          final delta = positions[i] - positions[j];
          final dSqr =
              delta.dx * delta.dx + delta.dy * delta.dy;
          if (dSqr <= linkSqr) {
            canvas.drawLine(positions[i], positions[j], _linkPaint);
          }
        }
      }
    }

    // Particulas em cima das linhas.
    for (final p in positions) {
      canvas.drawCircle(p, particleRadius, _particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleFieldPainter old) {
    return old.tick != tick ||
        old.pointer != pointer ||
        old.particleColor != particleColor ||
        old.linkColor != linkColor ||
        old.linkDistance != linkDistance ||
        old.particleCount != particleCount ||
        old.seed != seed;
  }

  /// Hint para o `CustomPaint` host: com 24+ particulas vale rasterizar
  /// em layer.
  bool get isComplex => particleCount >= 24;

  /// Hint para o `CustomPaint` host: anima continuamente.
  bool get willChange => true;
}

class _Seed {
  const _Seed({
    required this.anchorXFraction,
    required this.anchorYFraction,
    required this.phase,
    required this.speed,
    required this.angle,
  });

  final double anchorXFraction;
  final double anchorYFraction;
  final double phase;
  final double speed;
  final double angle;
}
