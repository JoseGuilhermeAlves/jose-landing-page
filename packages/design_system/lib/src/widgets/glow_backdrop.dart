import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_gradients.dart';
import 'package:flutter/material.dart';

/// Wrapper que adiciona um glow radial atras de [child]. Usado nas
/// secoes da landing pra dar profundidade sem perder o look "flat
/// dark" — Linear, Vercel e Stripe usam o mesmo truque.
///
/// O glow e puramente decorativo: vai num `Positioned.fill` com
/// `IgnorePointer`, entao nao rouba taps nem hover.
class GlowBackdrop extends StatelessWidget {
  const GlowBackdrop({
    required this.child,
    this.color,
    this.alignment = Alignment.center,
    this.intensity = 0.18,
    this.radius = 0.6,
    super.key,
  });

  final Widget child;

  /// Default: `colors.primary` do tema.
  final Color? color;

  /// Onde o pico do glow fica dentro do retangulo do widget.
  final Alignment alignment;

  /// Alpha no centro do glow (0..1). Default 0.18 — discreto.
  final double intensity;

  /// Raio em fracao do menor lado. Default 0.6.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final glowColor = color ?? colors.primary;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppGradients.glow(
                  glowColor,
                  opacity: intensity,
                  radius: radius,
                  center: alignment,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
