import 'dart:ui' as ui;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Foto recortada do José posicionada visualmente ancorada no cosmos:
/// floor glow brand-purple + contact shadow soft + bob suave (3.8s
/// repeat reverse, dy ±7px) + silhouette aura multi-layer + rim light
/// apontando pra fonte de luz dominante. Stack de 3 camadas detras
/// (grounding/shadow estáticos) + 1 camada bobando à frente (aura +
/// rim + crisp).
///
/// Extraído de `hero_section.dart` (era a maior subárvore do arquivo
/// 1789 LOC); agora vive como widget público importado pelo shell.
class HeroPortrait extends StatelessWidget {
  const HeroPortrait({required this.isMobile, super.key});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxWidth = isMobile ? double.infinity : 460.0;
    final maxHeight = isMobile ? 380.0 : 600.0;

    const farTint = Color(0xFF7132F5);
    const midTint = Color(0xFF5741D8);
    const closeTint = Color(0xFFFF2D95);

    const assetPath = 'assets/images/foto_recortada.png';

    return Semantics(
      label: context.l10n.hero_portraitSemantics,
      image: true,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GroundingPainter(color: colors.primary),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ContactShadowPainter(
                      scale: 1,
                      alpha: 1,
                    ),
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const _SilhouetteAura(
                    assetPath: assetPath,
                    farTint: farTint,
                    midTint: midTint,
                    closeTint: closeTint,
                  ),
                  _RimLight(assetPath: assetPath, tint: colors.primary),
                  Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    alignment: Alignment.bottomCenter,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rim light: copia da silhueta tingida com cor primary, blur leve
/// e deslocada upper-left (offset -1.8, -1.8). Stack-ada atras da
/// imagem crisp — a tinta vaza no contorno superior-esquerdo formando
/// um halo proximo que sugere luz incidindo dos planetas brilhantes
/// do canto.
class _RimLight extends StatelessWidget {
  const _RimLight({required this.assetPath, required this.tint});

  final String assetPath;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-1.8, -1.8),
      child: IgnorePointer(
        child: RepaintBoundary(
          child: Opacity(
            opacity: 0.55,
            child: ImageFiltered(
              imageFilter: ui.ImageFilter.blur(sigmaX: 2, sigmaY: 2),
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

/// Contact shadow soft sob a figura. Elipse blurrada via MaskFilter
/// em y=0.97 do frame. Escala e alpha controlados externamente pelo
/// bob — quando a figura sobe, a sombra encolhe e perde opacidade.
class _ContactShadowPainter extends CustomPainter {
  _ContactShadowPainter({required this.scale, required this.alpha});

  final double scale;
  final double alpha;

  static const double _baseY = 0.97;
  static const Color _shadowColor = Color(0xFF000000);
  static const double _baseAlpha = 0.35;

  late final Paint _paint = Paint()
    ..style = PaintingStyle.fill
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * _baseY;
    final ellipseW = size.width * 0.42 * scale;
    final ellipseH = size.height * 0.025 * scale;
    _paint.color = _shadowColor.withValues(alpha: _baseAlpha * alpha);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy),
        width: ellipseW,
        height: ellipseH,
      ),
      _paint,
    );
  }

  @override
  bool shouldRepaint(_ContactShadowPainter old) =>
      old.scale != scale || old.alpha != alpha;
}

/// Floor glow radial brand purple ancorado em y=0.95. ScaleY 0.7
/// estende verticalmente sem virar disco perfeito; o glow sobe pelo
/// corpo da silhueta dando leitura de "figura emergindo de luz" em
/// vez de "figura largada no cosmos".
class _GroundingPainter extends CustomPainter {
  _GroundingPainter({required this.color});

  final Color color;

  static const double _baseY = 0.95;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cy = h * _baseY;
    final glowCenter = Offset(w / 2, cy);
    final glowRadius = w * 0.55;
    final glowRect = Rect.fromCircle(center: glowCenter, radius: glowRadius);
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.40),
          color.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(glowRect);
    canvas
      ..save()
      ..translate(glowCenter.dx, glowCenter.dy)
      ..scale(1, 0.7)
      ..translate(-glowCenter.dx, -glowCenter.dy)
      ..drawCircle(glowCenter, glowRadius, glowPaint)
      ..restore();
  }

  @override
  bool shouldRepaint(_GroundingPainter old) => old.color != color;
}
