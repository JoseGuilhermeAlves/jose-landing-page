import 'package:flutter/material.dart';

/// Portal black-hole no FIM da estrada — so o hemisferio SUPERIOR aparece
/// (a "boca" emergindo do ponto de fuga, colada no horizonte). Reaproveita
/// a linguagem do retrato Gargantua (`BlackHolePortrait`) mas ENXUTO: so o
/// horizonte de eventos (disco preto) + o brilho da BORDA (event horizon) +
/// um bloom sutil. **Sem disco de acrescimo.**
///
/// O host posiciona a caixa com o CENTRO do circulo sobre o ponto de fuga;
/// o painter corta a metade de baixo, deixando a aresta plana (diametro)
/// pousada na linha do horizonte.
class RoadPortal extends StatelessWidget {
  const RoadPortal({
    this.hot = const Color(0xFFFF2E86),
    this.cool = const Color(0xFF36E0FF),
    super.key,
  });

  /// Cor quente da borda (magenta neon).
  final Color hot;

  /// Cor fria da borda (ciano neon).
  final Color cool;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _RoadPortalPainter(hot: hot, cool: cool),
      ),
    );
  }
}

class _RoadPortalPainter extends CustomPainter {
  _RoadPortalPainter({required this.hot, required this.cool});

  final Color hot;
  final Color cool;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final c = size.center(Offset.zero);
    final r = (size.shortestSide / 2) * 0.88;

    // So o hemisferio de cima: corta APENAS na base (linha do centro =
    // horizonte). Topo/laterais ficam livres (bounds enormes) pra o bloom
    // circular NAO virar um quadrado recortado pela caixa.
    canvas
      ..save()
      ..clipRect(
        Rect.fromLTRB(-size.width, -size.height, size.width * 2, c.dy + 1),
      );

    // 1) Bloom: halo quente/frio difuso por tras da boca.
    final bloom = Paint()
      ..blendMode = BlendMode.plus
      ..shader = RadialGradient(
        colors: [
          hot.withValues(alpha: 0.5),
          cool.withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r * 1.7));
    canvas.drawCircle(c, r * 1.7, bloom);

    // 2) Horizonte de eventos: disco quase-preto.
    final black = Paint()..color = const Color(0xFF05010A);

    // 3) Borda do event horizon: anel grosso com gradiente quente->frio +
    //    blur (o "brilho" lensado), aditivo.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.1
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..blendMode = BlendMode.plus
      ..shader = SweepGradient(
        colors: [cool, hot, Colors.white, hot, cool],
      ).createShader(Rect.fromCircle(center: c, radius: r));

    // 4) Photon ring fino crisp colado na borda. Ordem: preto -> glow ->
    //    photon (disco cobre o bloom, borda brilha por cima).
    final photon = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.02
      ..color = Colors.white.withValues(alpha: 0.9);
    canvas
      ..drawCircle(c, r, black)
      ..drawCircle(c, r, glow)
      ..drawCircle(c, r * 1.005, photon)
      ..restore();
  }

  @override
  bool shouldRepaint(_RoadPortalPainter old) =>
      old.hot != hot || old.cool != cool;
}
