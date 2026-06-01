import 'package:animations/src/painters/constellation_painter.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Widget host pro `ConstellationPainter`. Cuida do controller em loop
/// e respeita as cores semanticas do tema quando nenhuma e provida.
///
/// Use em background de hero — junto com `ParticleField` rende uma
/// camada de "ceu noturno" com pontos reconheciveis (Cruzeiro do Sul,
/// Orion, Triangulo de Verao).
class ConstellationField extends StatefulWidget {
  const ConstellationField({
    this.duration = const Duration(seconds: 6),
    this.constellations = KnownConstellations.all,
    this.starColor,
    this.linkColor,
    this.starRadius = 1.6,
    this.flareLength = 4.5,
    super.key,
  });

  final Duration duration;
  final List<Constellation> constellations;

  /// Default: `colors.onSurface` (claro contra background dark).
  final Color? starColor;

  /// Default: `colors.primary` com alpha baixo.
  final Color? linkColor;

  final double starRadius;
  final double flareLength;

  @override
  State<ConstellationField> createState() => _ConstellationFieldState();
}

class _ConstellationFieldState extends State<ConstellationField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didUpdateWidget(covariant ConstellationField old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final starColor = widget.starColor ?? colors.onSurface;
    final linkColor =
        widget.linkColor ?? colors.primary.withValues(alpha: 0.22);

    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: true,
        painter: ConstellationPainter(
          animation: _controller,
          starColor: starColor,
          linkColor: linkColor,
          constellations: widget.constellations,
          starRadius: widget.starRadius,
          flareLength: widget.flareLength,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
