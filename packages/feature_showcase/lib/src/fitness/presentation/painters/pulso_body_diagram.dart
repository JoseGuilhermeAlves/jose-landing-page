import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_recovery.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Diagrama anatomico simplificado (vista frontal). Cada regiao e
/// pintada na cor da banda de recovery do grupo muscular
/// correspondente, com fill em gradiente suave dentro de uma silhueta
/// continua anti-aliased. Tap em uma regiao chama [onTap] com o
/// [MuscleGroup].
class PulsoBodyDiagram extends StatelessWidget {
  const PulsoBodyDiagram({
    required this.recovery,
    this.onTap,
    this.aspectRatio = 0.55,
    super.key,
  });

  final MuscleRecovery recovery;
  final void Function(MuscleGroup group)? onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, c) {
          return GestureDetector(
            onTapUp: onTap == null
                ? null
                : (details) {
                    final hit = _hitTest(details.localPosition, c.biggest);
                    if (hit != null) onTap!(hit);
                  },
            child: CustomPaint(
              painter: _BodyDiagramPainter(recovery: recovery),
              size: c.biggest,
            ),
          );
        },
      ),
    );
  }

  /// Mapeia coordenada local pra grupo muscular. Coordenadas
  /// normalizadas (0..1) em ambos os eixos. As bandas espelham o
  /// layout desenhado pelo painter — manter em sincronia se a
  /// geometria mudar.
  MuscleGroup? _hitTest(Offset local, Size size) {
    final x = local.dx / size.width;
    final y = local.dy / size.height;
    if (y < 0.1) return null;
    if (y < 0.18) return MuscleGroup.shoulders;
    if (y < 0.32) return MuscleGroup.chest;
    if (y < 0.42) {
      return (x < 0.3 || x > 0.7) ? MuscleGroup.biceps : MuscleGroup.core;
    }
    if (y < 0.55) {
      return (x < 0.3 || x > 0.7) ? MuscleGroup.forearms : MuscleGroup.core;
    }
    if (y < 0.72) return MuscleGroup.quads;
    if (y < 0.88) return MuscleGroup.calves;
    return null;
  }
}

/// Uma regiao muscular pronta pra pintar: a [path] suavizada e o
/// [center] usado pra ancorar o gradiente radial. Calculada uma vez por
/// tamanho e cacheada — `paint()` so percorre a lista.
class _Region {
  const _Region(this.group, this.path, this.center);

  final MuscleGroup group;
  final Path path;
  final Offset center;
}

class _BodyDiagramPainter extends CustomPainter {
  _BodyDiagramPainter({required this.recovery});

  final MuscleRecovery recovery;

  // Paints estaticos reutilizados — nenhum alocado dentro de paint().
  static final Paint _bgPaint = Paint()..color = const Color(0xFF111116);
  static final Paint _silhouetteFill = Paint()
    ..color = const Color(0xFF17171F)
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  static final Paint _silhouetteStroke = Paint()
    ..color = const Color(0xFF2C2C38)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  static final Paint _regionFill = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;
  static final Paint _regionStroke = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  static final Paint _detailPaint = Paint()
    ..color = const Color(0xFF2C2C38)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  static final Paint _neutralFill = Paint()
    ..color = const Color(0xFF1A1A22)
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  // Geometria cacheada por tamanho — recomputada so quando size muda.
  Size? _cachedSize;
  late RRect _bgRRect;
  late Path _silhouette;
  late Rect _headRect;
  late List<_Region> _regions;
  late Path _chestSeam;
  late Path _coreSeam;
  late List<Path> _feet;

  @override
  void paint(Canvas canvas, Size size) {
    if (_cachedSize != size) {
      _rebuildGeometry(size);
      _cachedSize = size;
    }

    canvas
      // Background sutil pra destacar silhueta sem peso.
      ..drawRRect(_bgRRect, _bgPaint)
      // Silhueta continua anti-aliased atras das regioes.
      ..drawPath(_silhouette, _silhouetteFill)
      ..drawPath(_silhouette, _silhouetteStroke)
      // Cabeca.
      ..drawOval(_headRect, _neutralFill)
      ..drawOval(_headRect, _silhouetteStroke);

    // Regioes musculares com gradiente radial dentro de cada uma.
    for (final region in _regions) {
      final base = FitnessBrand.recoveryColor(recovery.scoreFor(region.group));
      final bounds = region.path.getBounds();
      // Gradiente radial: nucleo mais vivo, borda esmaecida — da
      // profundidade sem fugir da cor de recovery mapeada.
      _regionFill.shader =
          RadialGradient(
            radius: 0.95,
            colors: [
              base.withValues(alpha: 0.72),
              base.withValues(alpha: 0.34),
            ],
            stops: const [0.0, 1.0],
          ).createShader(
            Rect.fromCircle(
              center: region.center,
              radius: bounds.longestSide * 0.62,
            ),
          );
      canvas.drawPath(region.path, _regionFill);

      _regionStroke.color = base.withValues(alpha: 0.55);
      canvas.drawPath(region.path, _regionStroke);
    }
    _regionFill.shader = null;

    // Seams anatomicos (esterno + linha alba) por cima das regioes.
    canvas
      ..drawPath(_chestSeam, _detailPaint)
      ..drawPath(_coreSeam, _detailPaint);

    // Pes (sem cor — so silhueta).
    for (final foot in _feet) {
      canvas.drawPath(foot, _neutralFill);
    }
  }

  /// Reconstroi todas as Paths suavizadas em funcao do tamanho. Usa
  /// contornos com `quadraticBezierTo`/`RRect` pra que cada bloco leia
  /// como regiao anatomica, nao trapezio. Espelha as bandas de
  /// `_hitTest`.
  void _rebuildGeometry(Size size) {
    final w = size.width;
    final h = size.height;

    _bgRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    _headRect = Rect.fromCircle(
      center: Offset(w * 0.5, h * 0.075),
      radius: h * 0.058,
    );

    _silhouette = _buildSilhouette(w, h);

    // --- Regioes (centro = ancora do gradiente radial). ---
    final shoulders = Path()
      ..moveTo(w * 0.26, h * 0.165)
      ..quadraticBezierTo(w * 0.5, h * 0.115, w * 0.74, h * 0.165)
      ..quadraticBezierTo(w * 0.80, h * 0.20, w * 0.77, h * 0.225)
      ..quadraticBezierTo(w * 0.5, h * 0.20, w * 0.23, h * 0.225)
      ..quadraticBezierTo(w * 0.20, h * 0.20, w * 0.26, h * 0.165)
      ..close();

    final chest = Path()
      ..moveTo(w * 0.27, h * 0.225)
      ..quadraticBezierTo(w * 0.5, h * 0.21, w * 0.73, h * 0.225)
      ..quadraticBezierTo(w * 0.745, h * 0.30, w * 0.70, h * 0.355)
      ..quadraticBezierTo(w * 0.5, h * 0.375, w * 0.30, h * 0.355)
      ..quadraticBezierTo(w * 0.255, h * 0.30, w * 0.27, h * 0.225)
      ..close();

    final leftBicep = _limbPath(
      w,
      h,
      topInner: const Offset(0.225, 0.235),
      topOuter: const Offset(0.135, 0.30),
      botOuter: const Offset(0.135, 0.42),
      botInner: const Offset(0.215, 0.42),
    );
    final rightBicep = _limbPath(
      w,
      h,
      topInner: const Offset(0.775, 0.235),
      topOuter: const Offset(0.865, 0.30),
      botOuter: const Offset(0.865, 0.42),
      botInner: const Offset(0.785, 0.42),
    );

    final leftFore = _limbPath(
      w,
      h,
      topInner: const Offset(0.215, 0.42),
      topOuter: const Offset(0.135, 0.42),
      botOuter: const Offset(0.115, 0.55),
      botInner: const Offset(0.205, 0.55),
    );
    final rightFore = _limbPath(
      w,
      h,
      topInner: const Offset(0.785, 0.42),
      topOuter: const Offset(0.865, 0.42),
      botOuter: const Offset(0.885, 0.55),
      botInner: const Offset(0.795, 0.55),
    );

    final core = Path()
      ..moveTo(w * 0.30, h * 0.355)
      ..quadraticBezierTo(w * 0.5, h * 0.375, w * 0.70, h * 0.355)
      ..quadraticBezierTo(w * 0.685, h * 0.46, w * 0.655, h * 0.55)
      ..quadraticBezierTo(w * 0.5, h * 0.57, w * 0.345, h * 0.55)
      ..quadraticBezierTo(w * 0.315, h * 0.46, w * 0.30, h * 0.355)
      ..close();

    final leftQuad = _limbPath(
      w,
      h,
      topInner: const Offset(0.485, 0.55),
      topOuter: const Offset(0.345, 0.55),
      botOuter: const Offset(0.305, 0.72),
      botInner: const Offset(0.46, 0.72),
      bulge: 0.018,
    );
    final rightQuad = _limbPath(
      w,
      h,
      topInner: const Offset(0.515, 0.55),
      topOuter: const Offset(0.655, 0.55),
      botOuter: const Offset(0.695, 0.72),
      botInner: const Offset(0.54, 0.72),
      bulge: 0.018,
    );

    final leftCalf = _limbPath(
      w,
      h,
      topInner: const Offset(0.46, 0.72),
      topOuter: const Offset(0.305, 0.72),
      botOuter: const Offset(0.325, 0.88),
      botInner: const Offset(0.45, 0.88),
      bulge: 0.022,
    );
    final rightCalf = _limbPath(
      w,
      h,
      topInner: const Offset(0.54, 0.72),
      topOuter: const Offset(0.695, 0.72),
      botOuter: const Offset(0.675, 0.88),
      botInner: const Offset(0.55, 0.88),
      bulge: 0.022,
    );

    _regions = [
      _Region(MuscleGroup.shoulders, shoulders, Offset(w * 0.5, h * 0.18)),
      _Region(MuscleGroup.chest, chest, Offset(w * 0.5, h * 0.29)),
      _Region(MuscleGroup.biceps, leftBicep, Offset(w * 0.175, h * 0.33)),
      _Region(MuscleGroup.biceps, rightBicep, Offset(w * 0.825, h * 0.33)),
      _Region(MuscleGroup.forearms, leftFore, Offset(w * 0.165, h * 0.485)),
      _Region(MuscleGroup.forearms, rightFore, Offset(w * 0.835, h * 0.485)),
      _Region(MuscleGroup.core, core, Offset(w * 0.5, h * 0.45)),
      _Region(MuscleGroup.quads, leftQuad, Offset(w * 0.40, h * 0.635)),
      _Region(MuscleGroup.quads, rightQuad, Offset(w * 0.60, h * 0.635)),
      _Region(MuscleGroup.calves, leftCalf, Offset(w * 0.39, h * 0.80)),
      _Region(MuscleGroup.calves, rightCalf, Offset(w * 0.61, h * 0.80)),
    ];

    _chestSeam = Path()
      ..moveTo(w * 0.5, h * 0.235)
      ..lineTo(w * 0.5, h * 0.35);
    _coreSeam = Path()
      ..moveTo(w * 0.5, h * 0.37)
      ..lineTo(w * 0.5, h * 0.545);

    _feet = [_footPath(w, h, w * 0.305), _footPath(w, h, w * 0.545)];
  }

  /// Contorno externo continuo do corpo (cabeca -> ombros -> bracos ->
  /// pernas) com bordas curvas. Um unico Path anti-aliased.
  Path _buildSilhouette(double w, double h) {
    return Path()
      // lado direito descendo
      ..moveTo(w * 0.5, h * 0.135)
      ..quadraticBezierTo(w * 0.62, h * 0.135, w * 0.74, h * 0.16)
      ..quadraticBezierTo(w * 0.90, h * 0.30, w * 0.885, h * 0.55)
      ..quadraticBezierTo(w * 0.80, h * 0.50, w * 0.745, h * 0.42)
      ..quadraticBezierTo(w * 0.74, h * 0.50, w * 0.70, h * 0.55)
      ..quadraticBezierTo(w * 0.715, h * 0.72, w * 0.695, h * 0.72)
      ..quadraticBezierTo(w * 0.70, h * 0.86, w * 0.67, h * 0.905)
      ..lineTo(w * 0.54, h * 0.905)
      ..quadraticBezierTo(w * 0.525, h * 0.80, w * 0.52, h * 0.72)
      ..quadraticBezierTo(w * 0.5, h * 0.58, w * 0.48, h * 0.72)
      ..quadraticBezierTo(w * 0.475, h * 0.80, w * 0.46, h * 0.905)
      ..lineTo(w * 0.33, h * 0.905)
      ..quadraticBezierTo(w * 0.30, h * 0.86, w * 0.305, h * 0.72)
      ..quadraticBezierTo(w * 0.285, h * 0.72, w * 0.30, h * 0.55)
      ..quadraticBezierTo(w * 0.26, h * 0.50, w * 0.255, h * 0.42)
      ..quadraticBezierTo(w * 0.20, h * 0.50, w * 0.115, h * 0.55)
      ..quadraticBezierTo(w * 0.10, h * 0.30, w * 0.26, h * 0.16)
      ..quadraticBezierTo(w * 0.38, h * 0.135, w * 0.5, h * 0.135)
      ..close();
  }

  /// Constroi um segmento de membro (bracos/pernas) como quadrilatero
  /// de cantos arredondados via beziers. [bulge] empurra as laterais
  /// pra fora pra dar volume de musculo.
  Path _limbPath(
    double w,
    double h, {
    required Offset topInner,
    required Offset topOuter,
    required Offset botOuter,
    required Offset botInner,
    double bulge = 0.01,
  }) {
    Offset p(Offset n) => Offset(n.dx * w, n.dy * h);
    final ti = p(topInner);
    final to = p(topOuter);
    final bo = p(botOuter);
    final bi = p(botInner);
    final outerMid = Offset(
      (to.dx + bo.dx) / 2 + (to.dx < ti.dx ? -bulge * w : bulge * w),
      (to.dy + bo.dy) / 2,
    );
    final innerMid = Offset((ti.dx + bi.dx) / 2, (ti.dy + bi.dy) / 2);
    return Path()
      ..moveTo(ti.dx, ti.dy)
      ..quadraticBezierTo(to.dx, to.dy, outerMid.dx, outerMid.dy)
      ..quadraticBezierTo(bo.dx, bo.dy, bi.dx, bi.dy)
      ..quadraticBezierTo(innerMid.dx, innerMid.dy, ti.dx, ti.dy)
      ..close();
  }

  /// Pe arredondado posicionado em [left].
  Path _footPath(double w, double h, double left) {
    final rect = Rect.fromLTWH(left, h * 0.885, w * 0.15, h * 0.04);
    return Path()..addRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
        bottomLeft: const Radius.circular(6),
        bottomRight: const Radius.circular(6),
      ),
    );
  }

  @override
  bool shouldRepaint(_BodyDiagramPainter old) => old.recovery != recovery;
}
