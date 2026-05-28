import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Silhueta de barra olimpica com placas representadas em cada lado.
/// O algoritmo de empacotamento usa anilhas padrao (25, 20, 15, 10, 5,
/// 2.5, 1.25kg) e ignora a propria barra (20kg) — apenas o "peso
/// adicionado". Pra mock visual; nao tenta resolver casos extremos.
class PulsoBarbellLoader extends StatelessWidget {
  const PulsoBarbellLoader({
    required this.totalKg,
    this.height = 100,
    this.barWeightKg = 20,
    super.key,
  });

  final double totalKg;
  final double barWeightKg;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _BarbellPainter(totalKg: totalKg, barWeightKg: barWeightKg),
      ),
    );
  }
}

class _BarbellPainter extends CustomPainter {
  _BarbellPainter({required this.totalKg, required this.barWeightKg});

  final double totalKg;
  final double barWeightKg;

  static const List<double> _plates = [25, 20, 15, 10, 5, 2.5, 1.25];

  /// Cores por anilha — padronizado por convencao de Powerlifting.
  /// Map evitado em const por `double` quebrar `==` semantics; switch
  /// resolve em tempo de paint sem alocacao extra.
  static Color _plateColor(double plate) {
    if (plate >= 24.9) return const Color(0xFFFF5C5C);
    if (plate >= 19.9) return const Color(0xFF5AC8FA);
    if (plate >= 14.9) return const Color(0xFFFFB020);
    if (plate >= 9.9) return const Color(0xFFF2F2F5);
    if (plate >= 4.9) return const Color(0xFF00D982);
    if (plate >= 2.4) return const Color(0xFFB47BFF);
    return const Color(0xFF7E7E8A);
  }

  static final Paint _barPaint = Paint()
    ..color = const Color(0xFFC8C8D0)
    ..style = PaintingStyle.fill;

  static final Paint _sleevePaint = Paint()
    ..color = const Color(0xFF8E8E9A)
    ..style = PaintingStyle.fill;

  static final Paint _platePaint = Paint()..style = PaintingStyle.fill;

  static final Paint _plateBorderPaint = Paint()
    ..color = const Color(0xFF26262F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final barHeight = 6.0;
    final sleeveHeight = 12.0;
    final centerWidth = size.width * 0.42;
    final sleeveWidth = (size.width - centerWidth) / 2;
    final leftSleeveStart = (size.width - centerWidth) / 2 - sleeveWidth;

    // Barra central.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          leftSleeveStart + sleeveWidth,
          cy - barHeight / 2,
          centerWidth,
          barHeight,
        ),
        const Radius.circular(2),
      ),
      _barPaint,
    );

    // Sleeves (luva onde anilhas encaixam).
    final leftSleeve = Rect.fromLTWH(
      leftSleeveStart,
      cy - sleeveHeight / 2,
      sleeveWidth,
      sleeveHeight,
    );
    final rightSleeve = Rect.fromLTWH(
      leftSleeveStart + sleeveWidth + centerWidth,
      cy - sleeveHeight / 2,
      sleeveWidth,
      sleeveHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftSleeve, const Radius.circular(3)),
      _sleevePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightSleeve, const Radius.circular(3)),
      _sleevePaint,
    );

    final perSide = ((totalKg - barWeightKg) / 2).clamp(0, double.infinity);
    final loadout = _packPlates(perSide.toDouble());

    // Desenha anilhas a partir do centro pra fora em ambos os lados.
    final innerEdgeLeft = leftSleeveStart + sleeveWidth - 2;
    final innerEdgeRight = leftSleeveStart + sleeveWidth + centerWidth + 2;
    var leftCursor = innerEdgeLeft;
    var rightCursor = innerEdgeRight;
    for (final plate in loadout) {
      final width = 6 + (plate * 0.4); // anilha maior = barra mais larga
      final h = 30 + (plate * 0.9);
      _platePaint.color = _plateColor(plate);
      // Esquerda.
      final leftRect = Rect.fromLTWH(leftCursor - width, cy - h / 2, width, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftRect, const Radius.circular(3)),
        _platePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(leftRect, const Radius.circular(3)),
        _plateBorderPaint,
      );
      leftCursor -= width + 2;

      // Direita (espelho).
      final rightRect = Rect.fromLTWH(rightCursor, cy - h / 2, width, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightRect, const Radius.circular(3)),
        _platePaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rightRect, const Radius.circular(3)),
        _plateBorderPaint,
      );
      rightCursor += width + 2;
    }

    // Label central com totalKg.
    final tp = TextPainter(
      text: TextSpan(
        text:
            '${totalKg.toStringAsFixed(totalKg.truncateToDouble() == totalKg ? 0 : 1)} kg',
        style: const TextStyle(
          color: Color(0xFFF2F2F5),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          fontFamily: FitnessBrand.displayMonoFontFamily,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, cy + sleeveHeight / 2 + 12),
    );
  }

  /// Empacota o peso por lado em anilhas padrao. Greedy: maior anilha
  /// primeiro. Resto < 1.25 kg e ignorado.
  static List<double> _packPlates(double perSide) {
    final out = <double>[];
    var remaining = perSide;
    for (final plate in _plates) {
      while (remaining >= plate - 0.01) {
        out.add(plate);
        remaining -= plate;
      }
    }
    return out;
  }

  @override
  bool shouldRepaint(_BarbellPainter old) =>
      old.totalKg != totalKg || old.barWeightKg != barWeightKg;
}
