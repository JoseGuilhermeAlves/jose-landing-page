import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fundo animado da landing Arcade: campo de estrelas em parallax + grid
/// Outrun em perspectiva varrendo na direcao do observador. Desenha por
/// baixo de todo o conteudo (a moldura CRT entra por cima via overlay).
///
/// O painter recebe o controller direto em `super(repaint:)` — o
/// RenderCustomPaint ouve o tick e pula build/layout (regra de painter do
/// CLAUDE.md). Geometria das estrelas e cacheada (gerada uma vez com seed
/// fixa); so as posicoes derivam do tempo em paint().
class ArcadeBackdrop extends StatefulWidget {
  const ArcadeBackdrop({
    required this.background,
    required this.gridNear,
    required this.gridFar,
    required this.starColor,
    super.key,
  });

  /// Fundo do tubo CRT (quase-preto roxo).
  final Color background;

  /// Cor das linhas do grid perto do observador (magenta neon).
  final Color gridNear;

  /// Cor das linhas no horizonte (ciano neon).
  final Color gridFar;

  /// Cor base das estrelas (branco-lavanda).
  final Color starColor;

  @override
  State<ArcadeBackdrop> createState() => _ArcadeBackdropState();
}

class _ArcadeBackdropState extends State<ArcadeBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Loop longo e continuo — a fase do grid e das estrelas deriva do
    // valor 0..1 multiplicado por velocidades diferentes.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Acessibilidade: sem animacao o backdrop fica estatico.
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Anima sozinho atras de uma arvore que rola — RepaintBoundary isola
    // o repaint de 60 Hz do scroll.
    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: true,
        painter: _ArcadeBackdropPainter(
          animation: _controller,
          background: widget.background,
          gridNear: widget.gridNear,
          gridFar: widget.gridFar,
          starColor: widget.starColor,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Uma estrela do campo: posicao normalizada (0..1), raio e camada de
/// parallax (camadas mais "perto" driftam mais rapido e brilham mais).
class _Star {
  const _Star(this.x, this.y, this.radius, this.layer);

  final double x;
  final double y;
  final double radius;
  final double layer; // 0..1
}

class _ArcadeBackdropPainter extends CustomPainter {
  _ArcadeBackdropPainter({
    required Animation<double> animation,
    required this.background,
    required this.gridNear,
    required this.gridFar,
    required this.starColor,
  }) : _animation = animation,
       _bgPaint = Paint()..color = background,
       _starPaint = Paint()..color = starColor,
       _gridPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = 1.4,
       _glowPaint = Paint()
         ..style = PaintingStyle.stroke
         ..strokeWidth = 3
         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
       super(repaint: animation) {
    // Estrelas geradas uma vez com seed fixa — determinismo entre frames
    // e entre rebuilds, sem alocacao em paint().
    final rng = math.Random(8016);
    _stars = List<_Star>.generate(110, (_) {
      final layer = rng.nextDouble();
      return _Star(
        rng.nextDouble(),
        rng.nextDouble(),
        0.4 + layer * 1.3,
        layer,
      );
    });
  }

  final Animation<double> _animation;
  final Color background;
  final Color gridNear;
  final Color gridFar;
  final Color starColor;

  final Paint _bgPaint;
  final Paint _starPaint;
  final Paint _gridPaint;
  final Paint _glowPaint;

  late final List<_Star> _stars;

  /// Fracao da altura ocupada pelo "ceu" (acima do horizonte do grid).
  static const double _horizonFraction = 0.62;

  /// Numero de linhas verticais do grid (convergem pro ponto de fuga).
  static const int _verticalLines = 17;

  /// Numero de linhas horizontais do grid (recuam com perspectiva).
  static const int _horizontalLines = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final t = _animation.value;
    canvas.drawRect(Offset.zero & size, _bgPaint);

    _paintStars(canvas, size, t);
    _paintGrid(canvas, size, t);
  }

  void _paintStars(Canvas canvas, Size size, double t) {
    final skyHeight = size.height * _horizonFraction;
    for (final star in _stars) {
      // Camadas mais "perto" driftam mais rapido pra esquerda (parallax).
      final speed = 0.05 + star.layer * 0.20;
      var x = (star.x - t * speed) % 1.0;
      if (x < 0) x += 1.0;
      final y = star.y * skyHeight;

      // Twinkle: alpha oscila por estrela em fase propria.
      final twinkle =
          0.45 + 0.55 * (0.5 + 0.5 * math.sin((t + star.x + star.y) * 6.283));
      _starPaint.color = starColor.withValues(
        alpha: (0.25 + star.layer * 0.6) * twinkle,
      );
      canvas.drawCircle(Offset(x * size.width, y), star.radius, _starPaint);
    }
  }

  void _paintGrid(Canvas canvas, Size size, double t) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * _horizonFraction;
    final vanishingX = w / 2;

    // --- Linhas verticais: do horizonte (ponto de fuga) ate a base,
    // abrindo em leque. Cor interpola magenta(perto)->ciano(fundo).
    for (var i = 0; i <= _verticalLines; i++) {
      final f = i / _verticalLines; // 0..1 da esquerda pra direita
      // Na base as linhas se espalham largo; no horizonte convergem.
      final baseX = (f - 0.5) * w * 2.2 + vanishingX;
      _gridPaint.color = Color.lerp(
        gridFar,
        gridNear,
        0.5,
      )!.withValues(alpha: 0.35);
      canvas.drawLine(
        Offset(vanishingX, horizonY),
        Offset(baseX, h),
        _gridPaint,
      );
    }

    // --- Linhas horizontais: recuam com perspectiva e rolam na direcao
    // do observador. A fase scrollada vem de t; cada linha usa uma
    // posicao perspectivada (quadratica) pra adensar perto do horizonte.
    for (var i = 0; i < _horizontalLines; i++) {
      // p: 0 (horizonte) -> 1 (base), com scroll continuo.
      final p = (i / _horizontalLines + t) % 1.0;
      // Perspectiva: linhas perto do horizonte ficam coladas (p^2.4).
      final yp = math.pow(p, 2.4).toDouble();
      final y = horizonY + yp * (h - horizonY);
      // Largura visivel da linha cresce conforme se aproxima.
      final spread = 0.06 + yp * 1.07;
      final leftX = vanishingX - w * spread;
      final rightX = vanishingX + w * spread;

      final color = Color.lerp(gridFar, gridNear, yp)!;
      final alpha = (0.15 + yp * 0.55).clamp(0.0, 0.8);

      // Glow embaixo (linhas perto) — so nas mais proximas pra nao pesar.
      if (yp > 0.45) {
        _glowPaint.color = color.withValues(alpha: alpha * 0.5);
        canvas.drawLine(Offset(leftX, y), Offset(rightX, y), _glowPaint);
      }
      _gridPaint.color = color.withValues(alpha: alpha);
      canvas.drawLine(Offset(leftX, y), Offset(rightX, y), _gridPaint);
    }

    // Linha do horizonte — ciano forte com glow, o "sol" Outrun nasce dela.
    _glowPaint.color = gridFar.withValues(alpha: 0.6);
    canvas.drawLine(Offset(0, horizonY), Offset(w, horizonY), _glowPaint);
    _gridPaint.color = gridFar.withValues(alpha: 0.9);
    canvas.drawLine(Offset(0, horizonY), Offset(w, horizonY), _gridPaint);
  }

  @override
  bool shouldRepaint(_ArcadeBackdropPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.gridNear != gridNear ||
      oldDelegate.gridFar != gridFar ||
      oldDelegate.starColor != starColor;
}
