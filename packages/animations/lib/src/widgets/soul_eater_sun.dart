import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

/// Sol "Soul Eater" como FINAL BOSS de arcade synthwave: uma **mascara de
/// deus-sol** gigante (conceito "Eclipse Sun-God Mask"). Diferente da versao
/// pixel-art antiga (grid de blocos), aqui tudo e **neon liso**: corpo em
/// shader radial, rosto esculpido em NEGATIVO (testa/olhos/bocarra sao vazios
/// onde o brilho some), corona de espinhos girando devagar, brasas orbitando
/// em batched `drawRawPoints` (mesma linguagem de particula do buraco negro) e
/// olhos ciano que pulsam. Fica enorme no FUNDO, cortado no canto, espreitando.
///
/// Tecnicas (ver regras de painter no CLAUDE.md): geometria estatica em `Path`
/// cacheada por tamanho, `Paint`/shaders em campos, zero alocacao no hot loop,
/// glow aditivo via `BlendMode.plus`, bloom dos olhos com `MaskFilter.blur`
/// (cor solida — nunca blur+shader no mesmo `Paint`, bug do Impeller).
class SoulEaterSun extends StatefulWidget {
  const SoulEaterSun({super.key});

  @override
  State<SoulEaterSun> createState() => _SoulEaterSunState();
}

class _SoulEaterSunState extends State<SoulEaterSun>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // Rotacao lenta e ominosa da corona (1 volta / 48s). Pulso dos olhos e
    // drift das brasas derivam do mesmo tick em frequencias maiores.
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 48))
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: true,
        painter: _SunBossPainter(_c),
      ),
    );
  }
}

/// Uma brasa orbitando a corona: angulo base, raio (fracao de R), faixa de cor
/// (slot no buffer batched) e velocidade angular. Posicao recalculada por frame
/// dentro de um `Float32List` reusado — sem alocacao.
class _Ember {
  const _Ember(this.band, this.angle, this.radius, this.speed);

  final int band;
  final double angle;
  final double radius;
  final double speed;
}

class _SunBossPainter extends CustomPainter {
  _SunBossPainter(this._anim) : super(repaint: _anim);

  final Animation<double> _anim;

  // ---- Paints cacheados (reusados todo frame) ----
  final Paint _haloPaint = Paint()..blendMode = BlendMode.plus;
  final Paint _coronaPaint = Paint();
  final Paint _bodyPaint = Paint();
  final Paint _voidPaint = Paint()..color = _ink;
  final Paint _rimGlowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7)
    ..blendMode = BlendMode.plus;
  final Paint _rimCorePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round
    ..blendMode = BlendMode.plus;
  final Paint _fangPaint = Paint()..blendMode = BlendMode.plus;
  final Paint _eyeGlowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
    ..blendMode = BlendMode.plus;
  final Paint _eyeCorePaint = Paint()..blendMode = BlendMode.plus;
  final Paint _emberPaint = Paint()
    ..strokeCap = StrokeCap.round
    ..blendMode = BlendMode.plus;

  // ---- Geometria estatica (recomputada so quando o tamanho muda) ----
  Size _builtFor = Size.zero;
  late Offset _c; // centro do disco
  late double _r; // raio do disco
  late double _tilt; // inclinacao da face (rad) — assimetria/menace
  late Path _coronaPath; // espinhos da corona
  late Path _browPath; // testa em chevron
  late Path _mawPath; // bocarra
  late final List<Path> _socketPaths = []; // orbitas oculares (L, R)
  late final List<Path> _fangPaths = []; // presas (bone glow)
  late Path _nosePath; // fenda do nariz
  late final List<Offset> _eyeCenters = []; // centro das pupilas
  late double _pupilR;
  // Listas agrupadas pre-montadas (evita alocar list-literal no hot loop).
  late final List<Path> _voidPaths = []; // tudo que vira vazio escuro
  late final List<Path> _rimPaths = []; // vazios que ganham borda neon
  late final List<int> _emberCursor = List.filled(_emberColors.length, 0);

  // ---- Brasas: buffers por faixa de cor, escritos in-place todo frame ----
  static const int _emberCount = 360;
  static const List<Color> _emberColors = [
    Color(0xFFFFE7A6), // dourado quente
    Color(0xFFFF8A3C), // laranja
    Color(0xFFFF3C96), // magenta
    Color(0xFF8A52FF), // violeta
  ];
  final List<_Ember> _embers = [];
  late final List<Float32List> _emberBuf = []; // [band] -> xy pares
  late final List<int> _emberBandCount = List.filled(_emberColors.length, 0);

  // ---- Paleta ----
  static const Color _ink = Color(0xFF06070D); // vazio quase-preto
  static const Color _eyeCyan = Color(0xFF38F0FF); // pupila alien

  static const List<Color> _bodyColors = [
    Color(0xFFFFF6E0), // branco-quente
    Color(0xFFFFC24B), // dourado
    Color(0xFFFF6A2C), // laranja
    Color(0xFFFF2E88), // magenta
    Color(0xFF7C3DEF), // violeta
    Color(0x0006070D), // some no preto
  ];
  static const List<double> _bodyStops = [0.0, 0.30, 0.56, 0.78, 0.93, 1.0];

  static const List<Color> _coronaColors = [
    Color(0x00FF6A2C),
    Color(0xCCFF6A2C),
    Color(0xCCFF2E88),
    Color(0x408A52FF),
  ];
  static const List<double> _coronaStops = [0.62, 0.74, 0.9, 1.0];

  @override
  void paint(Canvas canvas, Size size) {
    _ensureBuilt(size);
    final t = _anim.value;
    final coronaAngle = t * 2 * math.pi;
    // Pulso dos olhos: ~1 batida / 3s (16 batidas no ciclo de 48s).
    final pulse = 0.5 + 0.5 * math.sin(t * 2 * math.pi * 16);

    // 1) HALO traseiro — bloom difuso alem do disco.
    // 2) CORONA — espinhos girando devagar (rotaciona a geometria, shader fixo).
    canvas
      ..drawCircle(_c, _r * 1.5, _haloPaint)
      ..save()
      ..translate(_c.dx, _c.dy)
      ..rotate(coronaAngle)
      ..translate(-_c.dx, -_c.dy)
      ..drawPath(_coronaPath, _coronaPaint)
      ..restore();

    // 3) BRASAS orbitando — batched por faixa de cor (1 drawRawPoints/faixa).
    _paintEmbers(canvas, t);

    // 4) CORPO do disco (shader radial).
    canvas.drawCircle(_c, _r, _bodyPaint);

    // 5) ANEL neon na borda do disco (tube: halo borrado + nucleo fino).
    _rimGlowPaint
      ..color = const Color(0xFFFF2E88)
      ..strokeWidth = _r * 0.045;
    _rimCorePaint
      ..color = const Color(0xFFFFE6C2)
      ..strokeWidth = _r * 0.012;
    canvas
      ..drawCircle(_c, _r * 0.985, _rimGlowPaint)
      ..drawCircle(_c, _r * 0.985, _rimCorePaint);

    // 6) ROSTO esculpido em NEGATIVO: vazios escuros sobre o disco, com a borda
    // dos vazios brilhando (sela o "carvado na luz").
    for (final path in _voidPaths) {
      canvas.drawPath(path, _voidPaint);
    }
    _rimGlowPaint
      ..color = const Color(0xFFFF3C96)
      ..strokeWidth = _r * 0.02;
    _rimCorePaint
      ..color = const Color(0xFFFFB37A)
      ..strokeWidth = _r * 0.006;
    for (final path in _rimPaths) {
      canvas
        ..drawPath(path, _rimGlowPaint)
        ..drawPath(path, _rimCorePaint);
    }

    // 7) PRESAS dentro da bocarra (osso com leve brilho).
    _fangPaint.color = const Color(0xFFF4DEBE);
    for (final fang in _fangPaths) {
      canvas.drawPath(fang, _fangPaint);
    }

    // 8) PUPILAS ciano pulsando (bloom borrado + nucleo quente).
    final glowA = 0.45 + 0.55 * pulse;
    for (final eye in _eyeCenters) {
      _eyeGlowPaint.color = _eyeCyan.withValues(alpha: glowA);
      canvas.drawCircle(eye, _pupilR * (1.7 + 0.5 * pulse), _eyeGlowPaint);
      _eyeCorePaint.color = Color.lerp(_eyeCyan, Colors.white, 0.6 * pulse)!;
      canvas.drawCircle(eye, _pupilR, _eyeCorePaint);
    }
  }

  void _paintEmbers(Canvas canvas, double t) {
    // Escreve as posicoes in-place nos buffers por faixa (sem alocacao).
    for (var b = 0; b < _emberCursor.length; b++) {
      _emberCursor[b] = 0;
    }
    for (final e in _embers) {
      final a = e.angle + t * 2 * math.pi * e.speed;
      final rad = _r * e.radius;
      final buf = _emberBuf[e.band];
      final i = _emberCursor[e.band]++ * 2;
      buf[i] = _c.dx + math.cos(a) * rad;
      buf[i + 1] = _c.dy + math.sin(a) * rad;
    }
    for (var band = 0; band < _emberColors.length; band++) {
      if (_emberBandCount[band] == 0) continue;
      _emberPaint
        ..color = _emberColors[band].withValues(alpha: 0.8)
        ..strokeWidth = _r * (0.016 - band * 0.002).clamp(0.006, 0.02);
      canvas.drawRawPoints(PointMode.points, _emberBuf[band], _emberPaint);
    }
  }

  // -------------------------------------------------------------------------
  // Construcao da geometria (uma vez por tamanho).
  // -------------------------------------------------------------------------

  void _ensureBuilt(Size size) {
    if (size == _builtFor) return;
    _builtFor = size;
    final s = size.shortestSide;
    _c = Offset(size.width / 2, size.height / 2);
    _r = s * 0.40;
    _tilt = -0.10; // leve inclinacao anti-horaria = olhar de esguelha

    _buildShaders();
    _buildCorona();
    _buildFace();
    _buildEmbers();
  }

  void _buildShaders() {
    _bodyPaint.shader = const RadialGradient(
      colors: _bodyColors,
      stops: _bodyStops,
    ).createShader(Rect.fromCircle(center: _c, radius: _r));

    _coronaPaint.shader = const RadialGradient(
      colors: _coronaColors,
      stops: _coronaStops,
    ).createShader(Rect.fromCircle(center: _c, radius: _r * 1.5));

    _haloPaint.shader = const RadialGradient(
      colors: [
        Color(0x66FF2E88),
        Color(0x331E66FF),
        Color(0x0006070D),
      ],
      stops: [0, 0.45, 1],
    ).createShader(Rect.fromCircle(center: _c, radius: _r * 1.5));
  }

  /// Posicao em pixels a partir de coords de face [-1,1], com a inclinacao.
  Offset _p(double fx, double fy) {
    final ca = math.cos(_tilt);
    final sa = math.sin(_tilt);
    final x = fx * _r;
    final y = fy * _r;
    return Offset(_c.dx + x * ca - y * sa, _c.dy + x * sa + y * ca);
  }

  void _buildCorona() {
    // Espinhos assimetricos: raio oscila entre R e a ponta, varrido por uma
    // soma de senos + jitter por hash. Path fechado preenchido pela RadialGradient.
    final path = Path();
    const samples = 240;
    const tip = 1.5; // ponta maxima em fracoes de R
    for (var i = 0; i <= samples; i++) {
      final ang = i / samples * 2 * math.pi;
      final spike =
          0.6 * math.sin(11 * ang) + 0.4 * math.sin(5 * ang + 1.3);
      final jitter = _hash(i * 0.37, 2) * 0.18;
      final amt = math.max<double>(0, spike) + jitter * 0.4;
      final rad = 1.0 + (tip - 1.0) * math.pow(amt, 0.7).toDouble();
      final pt = Offset(
        _c.dx + math.cos(ang) * _r * rad,
        _c.dy + math.sin(ang) * _r * rad,
      );
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    _coronaPath = path;
  }

  void _buildFace() {
    // TESTA franzida (chevron descendo no centro = raiva). Banda fechada com
    // bordas superior/inferior em bezier que afundam no meio.
    _browPath = Path()
      ..moveTo(_p(-0.78, -0.50).dx, _p(-0.78, -0.50).dy)
      ..cubicTo(
        _p(-0.30, -0.46).dx, _p(-0.30, -0.46).dy, //
        _p(-0.10, -0.20).dx, _p(-0.10, -0.20).dy,
        _p(0, -0.16).dx, _p(0, -0.16).dy,
      )
      ..cubicTo(
        _p(0.10, -0.20).dx, _p(0.10, -0.20).dy, //
        _p(0.30, -0.46).dx, _p(0.30, -0.46).dy,
        _p(0.78, -0.50).dx, _p(0.78, -0.50).dy,
      )
      ..lineTo(_p(0.74, -0.34).dx, _p(0.74, -0.34).dy)
      ..cubicTo(
        _p(0.28, -0.30).dx, _p(0.28, -0.30).dy, //
        _p(0.12, -0.04).dx, _p(0.12, -0.04).dy,
        _p(0, 0).dx, _p(0, 0).dy,
      )
      ..cubicTo(
        _p(-0.12, -0.04).dx, _p(-0.12, -0.04).dy, //
        _p(-0.28, -0.30).dx, _p(-0.28, -0.30).dy,
        _p(-0.74, -0.34).dx, _p(-0.74, -0.34).dy,
      )
      ..close();

    // OLHOS: orbitas em amendoa inclinadas (canto externo p/ cima = bravo).
    _socketPaths.clear();
    _eyeCenters.clear();
    for (final sx in const [-1.0, 1.0]) {
      final cx = sx * 0.40;
      const cy = 0.06;
      const hw = 0.30;
      const hh = 0.15;
      final lean = -sx * 0.10; // externo sobe
      Offset eye(double dx, double dy) => _p(cx + dx, cy + dy + dx * lean);
      _socketPaths.add(
        Path()
          ..moveTo(eye(-hw, 0).dx, eye(-hw, 0).dy)
          ..quadraticBezierTo(
            eye(-hw * 0.3, -hh).dx, eye(-hw * 0.3, -hh).dy, //
            eye(hw, -hh * 0.2).dx, eye(hw, -hh * 0.2).dy,
          )
          ..quadraticBezierTo(
            eye(hw * 0.2, hh).dx, eye(hw * 0.2, hh).dy, //
            eye(-hw, 0).dx, eye(-hw, 0).dy,
          )
          ..close(),
      );
      _eyeCenters.add(_p(cx + 0.02, cy));
    }
    _pupilR = _r * 0.05;

    // NARIZ: fenda em V curta no centro.
    _nosePath = Path()
      ..moveTo(_p(-0.05, 0.14).dx, _p(-0.05, 0.14).dy)
      ..lineTo(_p(0, 0.34).dx, _p(0, 0.34).dy)
      ..lineTo(_p(0.05, 0.14).dx, _p(0.05, 0.14).dy)
      ..close();

    // BOCARRA: vazio largo com labio superior/inferior em arco.
    const mawTop = 0.44;
    const mawBot = 0.86;
    const mawHalf = 0.62;
    _mawPath = Path()
      ..moveTo(_p(-mawHalf, mawTop + 0.04).dx, _p(-mawHalf, mawTop + 0.04).dy)
      ..quadraticBezierTo(
        _p(0, mawTop - 0.06).dx, _p(0, mawTop - 0.06).dy, //
        _p(mawHalf, mawTop + 0.04).dx, _p(mawHalf, mawTop + 0.04).dy,
      )
      ..quadraticBezierTo(
        _p(0, mawBot + 0.12).dx, _p(0, mawBot + 0.12).dy, //
        _p(-mawHalf, mawTop + 0.04).dx, _p(-mawHalf, mawTop + 0.04).dy,
      )
      ..close();

    // PRESAS: triangulos irregulares (hash) descendo do labio de cima e
    // subindo do de baixo. So dentro da largura da boca.
    _fangPaths.clear();
    const fangCols = 9;
    for (var i = 0; i < fangCols; i++) {
      final f = (i + 0.5) / fangCols; // 0..1 ao longo da boca
      final fx = -mawHalf + f * mawHalf * 2;
      // Labio segue o arco superior (parabola rasa).
      final lipTop = mawTop + 0.02 + 0.10 * (1 - (2 * f - 1) * (2 * f - 1));
      final lipBot = mawBot - 0.02 - 0.14 * (1 - (2 * f - 1) * (2 * f - 1));
      const w = mawHalf / fangCols * 0.7;
      if (i.isEven) {
        // presa de cima
        final h = 0.16 + 0.12 * _hash(i * 1.7, 3);
        _fangPaths.add(
          Path()
            ..moveTo(_p(fx - w, lipTop).dx, _p(fx - w, lipTop).dy)
            ..lineTo(_p(fx + w, lipTop).dx, _p(fx + w, lipTop).dy)
            ..lineTo(_p(fx, lipTop + h).dx, _p(fx, lipTop + h).dy)
            ..close(),
        );
      } else {
        // presa de baixo
        final h = 0.12 + 0.12 * _hash(i * 1.7, 9);
        _fangPaths.add(
          Path()
            ..moveTo(_p(fx - w, lipBot).dx, _p(fx - w, lipBot).dy)
            ..lineTo(_p(fx + w, lipBot).dx, _p(fx + w, lipBot).dy)
            ..lineTo(_p(fx, lipBot - h).dx, _p(fx, lipBot - h).dy)
            ..close(),
        );
      }
    }

    // Grupos pre-montados pro hot loop (sem list-literal por frame).
    _voidPaths
      ..clear()
      ..addAll([_browPath, _nosePath, ..._socketPaths, _mawPath]);
    _rimPaths
      ..clear()
      ..addAll([_browPath, _mawPath, ..._socketPaths]);
  }

  void _buildEmbers() {
    _embers.clear();
    for (var b = 0; b < _emberColors.length; b++) {
      _emberBandCount[b] = 0;
    }
    final rnd = math.Random(42);
    for (var i = 0; i < _emberCount; i++) {
      // Concentra brasas perto da borda do disco (0.92) ate a ponta da corona.
      final radius = 0.92 + math.pow(rnd.nextDouble(), 1.6).toDouble() * 0.58;
      // Faixa de cor por raio: dentro quente, fora frio.
      final norm = ((radius - 0.92) / 0.58).clamp(0.0, 0.999);
      final band = (norm * _emberColors.length).floor();
      _emberBandCount[band]++;
      final speed = (0.05 + rnd.nextDouble() * 0.12) * (1 / radius);
      _embers.add(
        _Ember(band, rnd.nextDouble() * 2 * math.pi, radius, speed),
      );
    }
    _emberBuf
      ..clear()
      ..addAll([
        for (var b = 0; b < _emberColors.length; b++)
          Float32List(_emberBandCount[b] * 2),
      ]);
  }

  double _hash(double x, double y) {
    final s = math.sin(x * 127.1 + y * 311.7) * 43758.5453;
    return s - s.floorToDouble();
  }

  @override
  bool shouldRepaint(_SunBossPainter oldDelegate) =>
      oldDelegate._anim != _anim;
}
