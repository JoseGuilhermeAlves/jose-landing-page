import 'package:feature_showcase/src/realestate/domain/property_type.dart';
import 'package:flutter/material.dart';

/// Ilustracao geometrica do imovel por [PropertyType] — substitui foto
/// real nos cards e na galeria do detalhe (3 angulos via [variant]).
/// Composicao em silhuetas planas com sombra simulada por gradiente,
/// no espirito de revistas de arquitetura ilustradas.
///
/// Performance: paints e gradientes cacheados; `shouldRepaint` so
/// dispara quando type, variant ou cores mudam.
class SolarPropertyIllustration extends StatelessWidget {
  const SolarPropertyIllustration({
    required this.type,
    this.variant = 0,
    this.foregroundColor,
    this.accentColor,
    this.backgroundColor,
    super.key,
  });

  final PropertyType type;

  /// Variacao do angulo na galeria do detalhe — cada variant
  /// re-compoe a cena: 0 = fachada frontal (frente), 1 = perspectiva
  /// 3/4 com volume e arvore (lateral), 2 = vista aerea/implantacao
  /// (topo). Cards usam sempre 0.
  final int variant;

  /// Cor principal da silhueta. Default = primary do tema.
  final Color? foregroundColor;

  /// Cor de destaque (telhado / vegetacao / acentos). Default =
  /// secondary do tema.
  final Color? accentColor;

  /// Cor de fundo da cena (chao / ceu sutil). Default = surfaceMuted.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? scheme.primary;
    final accent = accentColor ?? scheme.secondary;
    final bg = backgroundColor ?? scheme.surface;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SolarPropertyIllustrationPainter(
          type: type,
          variant: variant,
          foregroundColor: fg,
          accentColor: accent,
          backgroundColor: bg,
        ),
      ),
    );
  }
}

class _SolarPropertyIllustrationPainter extends CustomPainter {
  _SolarPropertyIllustrationPainter({
    required this.type,
    required this.variant,
    required this.foregroundColor,
    required this.accentColor,
    required this.backgroundColor,
  });

  final PropertyType type;
  final int variant;
  final Color foregroundColor;
  final Color accentColor;
  final Color backgroundColor;

  late final Paint _fill = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.fill;

  late final Paint _accentFill = Paint()
    ..color = accentColor
    ..style = PaintingStyle.fill;

  late final Paint _shadeFill = Paint()
    ..color = foregroundColor.withValues(alpha: 0.75)
    ..style = PaintingStyle.fill;

  /// Lado iluminado do telhado — clareia o foreground rumo ao branco.
  late final Paint _roofLitFill = Paint()
    ..color = Color.lerp(foregroundColor, const Color(0xFFFFFFFF), 0.22)!
    ..style = PaintingStyle.fill;

  /// Lado sombreado do telhado / beiral — escurece o foreground.
  late final Paint _roofShadeFill = Paint()
    ..color = Color.lerp(foregroundColor, const Color(0xFF000000), 0.28)!
    ..style = PaintingStyle.fill;

  /// Verde de gramado/terreno — clareia o accent rumo a um verde mais
  /// vivo pra nao virar um bloco barrento sobre o creme.
  late final Paint _lawnFill = Paint()
    ..color = Color.lerp(accentColor, const Color(0xFFB8D17A), 0.45)!
    ..style = PaintingStyle.fill;

  /// Verde de gramado mais escuro pro plano de fundo (mata/colina).
  late final Paint _lawnDeepFill = Paint()
    ..color = Color.lerp(accentColor, const Color(0xFF000000), 0.12)!
    ..style = PaintingStyle.fill;

  late final Paint _windowFill = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  /// Caixilho/divisoria das janelas (mullions) — foreground sutil.
  late final Paint _mullionPaint = Paint()
    ..color = foregroundColor.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;

  /// Sombra de contato sob a casa — escurece o accent do chao.
  late final Paint _contactShadowFill = Paint()
    ..color = const Color(0xFF000000).withValues(alpha: 0.16)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Pano de fundo com gradiente sutil ceu->chao pra dar profundidade.
    final bgRect = Offset.zero & size;
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        backgroundColor,
        Color.lerp(backgroundColor, accentColor, 0.10) ?? backgroundColor,
      ],
    ).createShader(bgRect);
    canvas.drawRect(bgRect, Paint()..shader = bgGradient);

    switch (type) {
      case PropertyType.house:
        _paintHouse(canvas, size);
      case PropertyType.chacara:
        _paintChacara(canvas, size);
      case PropertyType.land:
        _paintLand(canvas, size);
      case PropertyType.apartment:
        _paintApartment(canvas, size);
    }
  }

  /// Casa — cada variant e um enquadramento diferente da mesma casa:
  /// 0 = fachada frontal (frente), 1 = perspectiva 3/4 (lateral) com
  /// arvore, 2 = vista aerea / planta de implantacao (topo). Telhado
  /// ganha aguas com sombreado e beiral; janelas tem caixilho; sombra
  /// de contato no chao.
  void _paintHouse(Canvas canvas, Size size) {
    switch (variant) {
      case 2:
        _paintHouseAerial(canvas, size);
      case 1:
        _paintHousePerspective(canvas, size);
      default:
        _paintHouseFront(canvas, size);
    }
  }

  /// Fachada frontal — duas aguas de telhado com beiral, porta central,
  /// duas janelas com caixilho, chamine, sombra de contato.
  void _paintHouseFront(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Gramado.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), _lawnFill);
    // Sol no canto.
    canvas.drawCircle(Offset(w * 0.80, h * 0.20), h * 0.06, _accentFill);

    final bodyL = w * 0.20;
    final bodyR = w * 0.68;
    // Sombra de contato sob a casa.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset((bodyL + bodyR) / 2, h * 0.80),
        width: (bodyR - bodyL) * 1.25,
        height: h * 0.05,
      ),
      _contactShadowFill,
    );

    // Corpo.
    canvas.drawRect(Rect.fromLTRB(bodyL, h * 0.44, bodyR, h * 0.78), _fill);

    // Chamine (atras do telhado).
    canvas.drawRect(
      Rect.fromLTWH(w * 0.56, h * 0.24, w * 0.045, h * 0.12),
      _roofShadeFill,
    );

    // Telhado em duas aguas com beiral (extrapola o corpo).
    final ridgeX = (bodyL + bodyR) / 2;
    final eaveL = bodyL - w * 0.06;
    final eaveR = bodyR + w * 0.06;
    final apexY = h * 0.20;
    final eaveY = h * 0.44;
    // Agua esquerda (iluminada).
    final roofLit = Path()
      ..moveTo(eaveL, eaveY)
      ..lineTo(ridgeX, apexY)
      ..lineTo(ridgeX, eaveY)
      ..close();
    // Agua direita (sombreada).
    final roofShade = Path()
      ..moveTo(ridgeX, apexY)
      ..lineTo(eaveR, eaveY)
      ..lineTo(ridgeX, eaveY)
      ..close();
    canvas
      ..drawPath(roofLit, _roofLitFill)
      ..drawPath(roofShade, _roofShadeFill)
      // Faixa de beiral (sombra fina sob a linha do telhado).
      ..drawRect(
        Rect.fromLTRB(eaveL, eaveY, eaveR, eaveY + h * 0.02),
        _roofShadeFill,
      );

    // Porta central com painel.
    final door = Rect.fromLTWH(w * 0.40, h * 0.58, w * 0.08, h * 0.20);
    canvas
      ..drawRect(door, _accentFill)
      ..drawRect(door.deflate(w * 0.012), _roofShadeFill);

    // Janelas com caixilho.
    _paintMullionedWindow(
      canvas,
      Rect.fromLTWH(w * 0.25, h * 0.52, w * 0.10, h * 0.11),
    );
    _paintMullionedWindow(
      canvas,
      Rect.fromLTWH(w * 0.53, h * 0.52, w * 0.10, h * 0.11),
    );
  }

  /// Perspectiva 3/4 — fachada + parede lateral em sombra, dando volume,
  /// com arvore ao lado. Le claramente diferente da fachada frontal.
  void _paintHousePerspective(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22), _lawnFill);
    canvas.drawCircle(Offset(w * 0.22, h * 0.20), h * 0.06, _accentFill);

    _paintTree(canvas, Offset(w * 0.86, h * 0.78), h * 0.26);

    final faceL = w * 0.16;
    final faceR = w * 0.50;
    const faceTop = 0.44;
    const faceBottom = 0.78;
    // Sombra de contato.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.42, h * 0.80),
        width: w * 0.62,
        height: h * 0.05,
      ),
      _contactShadowFill,
    );

    // Parede lateral (em fuga, sombreada).
    final side = Path()
      ..moveTo(faceR, h * faceTop)
      ..lineTo(w * 0.70, h * 0.40)
      ..lineTo(w * 0.70, h * 0.72)
      ..lineTo(faceR, h * faceBottom)
      ..close();
    canvas.drawPath(side, _roofShadeFill);

    // Fachada.
    canvas.drawRect(
      Rect.fromLTRB(faceL, h * faceTop, faceR, h * faceBottom),
      _fill,
    );

    // Telhado em fuga (duas faces).
    final roofFront = Path()
      ..moveTo(faceL - w * 0.04, h * faceTop)
      ..lineTo(w * 0.33, h * 0.22)
      ..lineTo(faceR + w * 0.02, h * faceTop)
      ..close();
    final roofSide = Path()
      ..moveTo(w * 0.33, h * 0.22)
      ..lineTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.70, h * 0.40)
      ..lineTo(faceR + w * 0.02, h * faceTop)
      ..close();
    canvas
      ..drawPath(roofFront, _roofLitFill)
      ..drawPath(roofSide, _roofShadeFill);

    // Porta + janela na fachada.
    final door = Rect.fromLTWH(w * 0.20, h * 0.60, w * 0.07, h * 0.18);
    canvas
      ..drawRect(door, _accentFill)
      ..drawRect(door.deflate(w * 0.01), _roofShadeFill);
    _paintMullionedWindow(
      canvas,
      Rect.fromLTWH(w * 0.33, h * 0.52, w * 0.10, h * 0.11),
    );
  }

  /// Vista aerea / implantacao — telhado visto de cima, jardim, piscina,
  /// calcada e arvores. Composicao totalmente distinta das elevacoes.
  void _paintHouseAerial(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Lote inteiro como gramado.
    canvas.drawRect(Offset.zero & size, _lawnFill);

    // Calcada/entrada.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.74, w * 0.12, h * 0.26),
      _shadeFill,
    );

    // Telhado visto de cima — duas aguas separadas pela cumeeira.
    final roofRect = Rect.fromLTWH(w * 0.16, h * 0.18, w * 0.46, h * 0.50);
    canvas
      ..drawRect(
        Rect.fromLTRB(
          roofRect.left,
          roofRect.top,
          roofRect.center.dx,
          roofRect.bottom,
        ),
        _roofLitFill,
      )
      ..drawRect(
        Rect.fromLTRB(
          roofRect.center.dx,
          roofRect.top,
          roofRect.right,
          roofRect.bottom,
        ),
        _roofShadeFill,
      )
      // Linha de cumeeira.
      ..drawLine(
        Offset(roofRect.center.dx, roofRect.top),
        Offset(roofRect.center.dx, roofRect.bottom),
        Paint()
          ..color = foregroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );

    // Piscina ao lado.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.68, h * 0.30, w * 0.20, h * 0.26),
        const Radius.circular(6),
      ),
      Paint()..color = Color.lerp(accentColor, Colors.white, 0.35)!,
    );

    // Arvores espalhadas (copas vistas de cima).
    canvas
      ..drawCircle(Offset(w * 0.78, h * 0.72), h * 0.07, _lawnDeepFill)
      ..drawCircle(Offset(w * 0.10, h * 0.40), h * 0.06, _lawnDeepFill);

    // Sol.
    canvas.drawCircle(Offset(w * 0.88, h * 0.12), h * 0.05, _accentFill);
  }

  /// Chacara — casa menor + arvores + horizonte com colina.
  void _paintChacara(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Colina ao fundo.
    final hill = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.35, h * 0.45, w * 0.70, h * 0.65)
      ..quadraticBezierTo(w * 0.90, h * 0.75, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Sol.
    final sunCx = variant == 1 ? w * 0.20 : w * 0.78;
    // Casa central pequena.
    final bodyX = variant == 1 ? w * 0.40 : w * 0.30;
    final body = Rect.fromLTWH(bodyX, h * 0.55, w * 0.30, h * 0.30);
    // Telhado em duas aguas sombreadas, como nas casas.
    final apexX = bodyX + w * 0.15;
    final roofLit = Path()
      ..moveTo(bodyX - w * 0.04, h * 0.55)
      ..lineTo(apexX, h * 0.36)
      ..lineTo(apexX, h * 0.55)
      ..close();
    final roofShade = Path()
      ..moveTo(apexX, h * 0.36)
      ..lineTo(bodyX + w * 0.34, h * 0.55)
      ..lineTo(apexX, h * 0.55)
      ..close();
    canvas
      // Colina ao fundo em verde mais profundo (nao marrom).
      ..drawPath(hill, _lawnDeepFill)
      // Chao em gramado vivo.
      ..drawRect(Rect.fromLTWH(0, h * 0.85, w, h * 0.15), _lawnFill)
      ..drawCircle(Offset(sunCx, h * 0.20), h * 0.05, _accentFill)
      // Sombra de contato sob a casa.
      ..drawOval(
        Rect.fromCenter(
          center: Offset(bodyX + w * 0.15, h * 0.86),
          width: w * 0.40,
          height: h * 0.035,
        ),
        _contactShadowFill,
      )
      ..drawRect(body, _fill)
      ..drawPath(roofLit, _roofLitFill)
      ..drawPath(roofShade, _roofShadeFill)
      ..drawRect(
        Rect.fromLTWH(bodyX + w * 0.04, h * 0.62, w * 0.08, h * 0.08),
        _windowFill,
      )
      ..drawRect(
        Rect.fromLTWH(bodyX + w * 0.18, h * 0.62, w * 0.08, h * 0.08),
        _windowFill,
      )
      ..drawRect(
        Rect.fromLTWH(bodyX + w * 0.11, h * 0.74, w * 0.07, h * 0.11),
        _accentFill,
      );

    // Duas arvores ladeando.
    _paintTree(canvas, Offset(w * 0.12, h * 0.85), h * 0.32);
    _paintTree(canvas, Offset(w * 0.86, h * 0.85), h * 0.28);
  }

  /// Terreno — lote vazio com cerca + horizonte. Sem casa.
  void _paintLand(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizonte com mata ao fundo.
    final mata = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.20, h * 0.40, w * 0.45, h * 0.52)
      ..quadraticBezierTo(w * 0.70, h * 0.62, w, h * 0.50)
      ..lineTo(w, h * 0.65)
      ..lineTo(0, h * 0.65)
      ..close();
    canvas
      // Mata ao fundo em verde mais profundo.
      ..drawPath(mata, _lawnDeepFill)
      // Terreno em verde de gramado vivo.
      ..drawRect(Rect.fromLTWH(0, h * 0.65, w, h * 0.35), _lawnFill)
      // Sol.
      ..drawCircle(Offset(w * 0.78, h * 0.22), h * 0.05, _accentFill);

    // Cerca esquemática — postes e duas linhas horizontais.
    final fencePaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i <= 6; i++) {
      final x = w * 0.10 + (w * 0.80) * (i / 6);
      canvas.drawLine(Offset(x, h * 0.66), Offset(x, h * 0.88), fencePaint);
    }
    canvas
      ..drawLine(
        Offset(w * 0.10, h * 0.72),
        Offset(w * 0.90, h * 0.72),
        fencePaint,
      )
      ..drawLine(
        Offset(w * 0.10, h * 0.82),
        Offset(w * 0.90, h * 0.82),
        fencePaint,
      );

    // Placa "vende-se" simbolica.
    final signX = variant == 1 ? w * 0.20 : w * 0.70;
    final signRect = Rect.fromLTWH(signX, h * 0.50, w * 0.16, h * 0.12);
    canvas
      ..drawRect(signRect, _fill)
      ..drawRect(
        Rect.fromLTWH(signX + w * 0.07, h * 0.62, w * 0.02, h * 0.20),
        _fill,
      );
  }

  /// Apartamento — predio com janelas em grade.
  void _paintApartment(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Chao em gramado.
    canvas.drawRect(Rect.fromLTWH(0, h * 0.82, w, h * 0.18), _lawnFill);

    // Sol.
    final sunCx = variant == 1 ? w * 0.18 : w * 0.82;
    // Corpo do predio.
    final body = Rect.fromLTWH(w * 0.25, h * 0.18, w * 0.50, h * 0.64);
    canvas
      ..drawCircle(Offset(sunCx, h * 0.20), h * 0.05, _accentFill)
      // Sombra de contato sob o predio.
      ..drawOval(
        Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.83),
          width: w * 0.62,
          height: h * 0.04,
        ),
        _contactShadowFill,
      )
      ..drawRect(body, _fill)
      // Parede direita em sombra pra dar volume.
      ..drawRect(
        Rect.fromLTWH(w * 0.63, h * 0.18, w * 0.12, h * 0.64),
        _roofShadeFill,
      )
      // Cobertura — laje com beiral no topo.
      ..drawRect(
        Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.04),
        _accentFill,
      );

    // Janelas em grade 4 colunas x 6 linhas; pula linha do meio
    // pra simular varanda.
    const cols = 4;
    const rows = 6;
    final cellW = w * 0.50 / cols;
    final cellH = h * 0.60 / rows;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (r == 3) continue; // andar de varanda
        final x = w * 0.25 + c * cellW + cellW * 0.18;
        final y = h * 0.22 + r * cellH + cellH * 0.18;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellW * 0.64, cellH * 0.50),
          _windowFill,
        );
      }
    }
    // Varanda corrida na linha pulada.
    canvas.drawRect(
      Rect.fromLTWH(
        w * 0.25 + cellW * 0.12,
        h * 0.22 + 3 * cellH + cellH * 0.10,
        w * 0.50 - cellW * 0.24,
        cellH * 0.50,
      ),
      Paint()..color = accentColor.withValues(alpha: 0.7),
    );
  }

  /// Janela com caixilho (mullions) — vidro de fundo + cruz divisoria +
  /// moldura. Le como janela real em vez de quadrado chapado.
  void _paintMullionedWindow(Canvas canvas, Rect rect) {
    canvas
      ..drawRect(rect, _windowFill)
      // Cruz divisoria.
      ..drawLine(
        Offset(rect.center.dx, rect.top),
        Offset(rect.center.dx, rect.bottom),
        _mullionPaint,
      )
      ..drawLine(
        Offset(rect.left, rect.center.dy),
        Offset(rect.right, rect.center.dy),
        _mullionPaint,
      )
      // Moldura externa.
      ..drawRect(
        rect,
        Paint()
          ..color = foregroundColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
  }

  /// Arvore esquematica — copa circular + tronco. Centro [base] no
  /// chao; [height] inclui copa.
  void _paintTree(Canvas canvas, Offset base, double height) {
    final trunkW = height * 0.12;
    final trunkH = height * 0.30;
    final trunk = Rect.fromLTWH(
      base.dx - trunkW / 2,
      base.dy - trunkH,
      trunkW,
      trunkH,
    );
    canvas
      ..drawRect(trunk, _shadeFill)
      ..drawCircle(
        Offset(base.dx, base.dy - trunkH - height * 0.25),
        height * 0.30,
        _accentFill,
      );
  }

  @override
  bool shouldRepaint(_SolarPropertyIllustrationPainter old) {
    return old.type != type ||
        old.variant != variant ||
        old.foregroundColor != foregroundColor ||
        old.accentColor != accentColor ||
        old.backgroundColor != backgroundColor;
  }
}
