import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Grupos musculares destacaveis no diagrama. Cada exercicio do plano
/// pode mapear pra um ou mais grupos — o caller passa o `Set` ativo
/// pro [PulsoBodyDiagram].
enum MuscleGroup {
  chest,
  shoulders,
  biceps,
  triceps,
  abs,
  quads,
  calves,
  glutes,
  back,
}

/// Diagrama anatomico estilizado em vista frontal — silhueta humana
/// com regioes musculares preenchidas conforme o `active` set. E o
/// elemento visual mais "app de academia" do mock: mostra ao usuario
/// o que vai trabalhar hoje sem precisar ler a lista de exercicios.
///
/// Tudo desenhado com `Path` + `Paint` — sem assets. Estilizado, nao
/// medicamente preciso; o objetivo e legibilidade na escala do card
/// (~120-200px de altura).
class PulsoBodyDiagram extends StatelessWidget {
  const PulsoBodyDiagram({required this.active, this.height = 180, super.key});

  /// Grupos musculares acesos com a cor primary. Demais ficam em
  /// cinza-borda (silhueta visivel mas neutra).
  final Set<MuscleGroup> active;

  /// Altura do diagrama. Largura sai pelo aspectRatio (~0.45).
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      key: const Key('pulso-body-diagram'),
      height: height,
      child: AspectRatio(
        aspectRatio: 0.45,
        child: CustomPaint(
          painter: _PulsoBodyDiagramPainter(
            active: active,
            bodyColor: colors.surfaceMuted,
            bodyStroke: colors.border,
            highlightColor: colors.primary,
            highlightStroke: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _PulsoBodyDiagramPainter extends CustomPainter {
  _PulsoBodyDiagramPainter({
    required this.active,
    required this.bodyColor,
    required this.bodyStroke,
    required this.highlightColor,
    required this.highlightStroke,
  });

  final Set<MuscleGroup> active;
  final Color bodyColor;
  final Color bodyStroke;
  final Color highlightColor;
  final Color highlightStroke;

  late final Paint _bodyFill = Paint()
    ..color = bodyColor
    ..style = PaintingStyle.fill;

  late final Paint _bodyOutline = Paint()
    ..color = bodyStroke
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..strokeJoin = StrokeJoin.round;

  late final Paint _muscleFill = Paint()
    ..color = highlightColor.withValues(alpha: 0.85)
    ..style = PaintingStyle.fill;

  late final Paint _muscleHalo = Paint()
    ..color = highlightColor.withValues(alpha: 0.22)
    ..style = PaintingStyle.fill;

  late final Paint _midline = Paint()
    ..color = bodyStroke
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Coordenadas normalizadas — todo o diagrama vive em [0..1] x [0..1]
    // e e escalado pelo `size` real do canvas. Facilita ajustar
    // proporcao sem refazer toda a geometria.
    final scale = size.height;
    final cx = size.width / 2;
    Offset p(double x, double y) => Offset(cx + x * scale, y * scale);

    final body = _buildBodyPath(p);
    canvas
      ..drawPath(body, _bodyFill)
      ..drawPath(body, _bodyOutline)
      // Linha central sutil pra dar leitura "anatomica".
      ..drawLine(p(0, 0.16), p(0, 0.62), _midline);

    _paintMuscles(canvas, p);
  }

  /// Path principal da silhueta — composta de cabeca (oval) + pescoco
  /// + torso (trapezio com ombros largos) + cintura + pernas.
  Path _buildBodyPath(Offset Function(double x, double y) p) {
    final path = Path();

    // Cabeca — oval pequeno no topo.
    final headRect = Rect.fromCenter(
      center: p(0, 0.07),
      width: 0.13 * _scaleHint,
      height: 0.13 * _scaleHint,
    );

    // Pescoco + ombros + torso + cintura — desenhado como um polígono
    // suavizado por quadraticBezierTo nos cantos.
    path
      ..addOval(headRect)
      ..moveTo(p(-0.04, 0.135).dx, p(-0.04, 0.135).dy)
      ..lineTo(p(-0.04, 0.155).dx, p(-0.04, 0.155).dy) // base do pescoco esq
      ..quadraticBezierTo(
        p(-0.22, 0.16).dx,
        p(-0.22, 0.16).dy,
        p(-0.22, 0.20).dx,
        p(-0.22, 0.20).dy,
      ) // ombro esq
      ..lineTo(p(-0.20, 0.35).dx, p(-0.20, 0.35).dy) // braco superior esq
      ..lineTo(p(-0.16, 0.55).dx, p(-0.16, 0.55).dy) // antebraco esq
      ..lineTo(p(-0.12, 0.58).dx, p(-0.12, 0.58).dy) // pulso esq
      ..lineTo(p(-0.14, 0.36).dx, p(-0.14, 0.36).dy) // volta torso esq
      ..lineTo(p(-0.13, 0.42).dx, p(-0.13, 0.42).dy) // cintura esq
      ..lineTo(p(-0.14, 0.60).dx, p(-0.14, 0.60).dy) // quadril esq
      ..lineTo(p(-0.13, 0.95).dx, p(-0.13, 0.95).dy) // perna esq
      ..lineTo(p(-0.04, 0.97).dx, p(-0.04, 0.97).dy) // pe esq
      ..lineTo(p(-0.02, 0.66).dx, p(-0.02, 0.66).dy) // virilha
      ..lineTo(p(0.02, 0.66).dx, p(0.02, 0.66).dy)
      ..lineTo(p(0.04, 0.97).dx, p(0.04, 0.97).dy) // pe dir
      ..lineTo(p(0.13, 0.95).dx, p(0.13, 0.95).dy) // perna dir
      ..lineTo(p(0.14, 0.60).dx, p(0.14, 0.60).dy)
      ..lineTo(p(0.13, 0.42).dx, p(0.13, 0.42).dy)
      ..lineTo(p(0.14, 0.36).dx, p(0.14, 0.36).dy)
      ..lineTo(p(0.12, 0.58).dx, p(0.12, 0.58).dy) // pulso dir
      ..lineTo(p(0.16, 0.55).dx, p(0.16, 0.55).dy)
      ..lineTo(p(0.20, 0.35).dx, p(0.20, 0.35).dy)
      ..lineTo(p(0.22, 0.20).dx, p(0.22, 0.20).dy)
      ..quadraticBezierTo(
        p(0.22, 0.16).dx,
        p(0.22, 0.16).dy,
        p(0.04, 0.155).dx,
        p(0.04, 0.155).dy,
      ) // ombro dir
      ..lineTo(p(0.04, 0.135).dx, p(0.04, 0.135).dy)
      ..close();

    return path;
  }

  /// Hint usado por shapes que precisam de scale relativo (cabeca).
  /// Mantido constante pra que a cabeca nao desproporcione conforme
  /// o tamanho do canvas muda.
  static const double _scaleHint = 1;

  void _paintMuscles(Canvas canvas, Offset Function(double x, double y) p) {
    // Peito — dois ovais lado a lado no torso superior.
    if (active.contains(MuscleGroup.chest)) {
      _fillOval(canvas, p, dx: -0.07, dy: 0.21, w: 0.10, h: 0.08);
      _fillOval(canvas, p, dx: 0.07, dy: 0.21, w: 0.10, h: 0.08);
    }
    // Ombros — pequenos circulos nas pontas.
    if (active.contains(MuscleGroup.shoulders)) {
      _fillOval(canvas, p, dx: -0.18, dy: 0.20, w: 0.07, h: 0.06);
      _fillOval(canvas, p, dx: 0.18, dy: 0.20, w: 0.07, h: 0.06);
    }
    // Biceps — ovais no braco superior.
    if (active.contains(MuscleGroup.biceps)) {
      _fillOval(canvas, p, dx: -0.18, dy: 0.30, w: 0.05, h: 0.10);
      _fillOval(canvas, p, dx: 0.18, dy: 0.30, w: 0.05, h: 0.10);
    }
    // Triceps — atras dos bracos; na frente, representamos como
    // pequena marca lateral pra indicar que esta sendo trabalhado.
    if (active.contains(MuscleGroup.triceps)) {
      _fillOval(canvas, p, dx: -0.21, dy: 0.31, w: 0.04, h: 0.10);
      _fillOval(canvas, p, dx: 0.21, dy: 0.31, w: 0.04, h: 0.10);
    }
    // Abs — coluna de pequenos retangulos no torso medio.
    if (active.contains(MuscleGroup.abs)) {
      for (var i = 0; i < 3; i++) {
        final yOff = 0.32 + i * 0.04;
        _fillRoundRect(canvas, p, dx: -0.04, dy: yOff, w: 0.08, h: 0.03);
      }
    }
    // Quadriceps — ovais grandes nas pernas superiores.
    if (active.contains(MuscleGroup.quads)) {
      _fillOval(canvas, p, dx: -0.07, dy: 0.72, w: 0.10, h: 0.16);
      _fillOval(canvas, p, dx: 0.07, dy: 0.72, w: 0.10, h: 0.16);
    }
    // Panturrilhas — ovais nas pernas inferiores.
    if (active.contains(MuscleGroup.calves)) {
      _fillOval(canvas, p, dx: -0.08, dy: 0.88, w: 0.07, h: 0.08);
      _fillOval(canvas, p, dx: 0.08, dy: 0.88, w: 0.07, h: 0.08);
    }
    // Gluteos / costas / lats — sem vista posterior aqui; indicamos
    // com uma "etiqueta" lateral discreta (linha + circulo).
    if (active.contains(MuscleGroup.glutes) ||
        active.contains(MuscleGroup.back)) {
      _fillOval(canvas, p, dx: -0.08, dy: 0.26, w: 0.05, h: 0.14);
      _fillOval(canvas, p, dx: 0.08, dy: 0.26, w: 0.05, h: 0.14);
    }
  }

  void _fillOval(
    Canvas canvas,
    Offset Function(double x, double y) p, {
    required double dx,
    required double dy,
    required double w,
    required double h,
  }) {
    // `w` e `h` sao relativos a altura do canvas (scale).
    final center = p(dx, dy);
    // Como p() ja multiplica por scale, w/h tambem devem ser em
    // unidades de scale (= altura total).
    final scale = p(0, 1).dy - p(0, 0).dy;
    final rect = Rect.fromCenter(
      center: center,
      width: w * scale,
      height: h * scale,
    );
    canvas
      ..drawOval(rect.inflate(2), _muscleHalo)
      ..drawOval(rect, _muscleFill);
  }

  void _fillRoundRect(
    Canvas canvas,
    Offset Function(double x, double y) p, {
    required double dx,
    required double dy,
    required double w,
    required double h,
  }) {
    final center = p(dx, dy);
    final scale = p(0, 1).dy - p(0, 0).dy;
    final rect = Rect.fromCenter(
      center: center,
      width: w * scale,
      height: h * scale,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(rect.height / 2),
    );
    canvas
      ..drawRRect(rrect.inflate(2), _muscleHalo)
      ..drawRRect(rrect, _muscleFill);
  }

  @override
  bool shouldRepaint(_PulsoBodyDiagramPainter old) {
    return old.active != active ||
        old.highlightColor != highlightColor ||
        old.bodyColor != bodyColor;
  }
}
