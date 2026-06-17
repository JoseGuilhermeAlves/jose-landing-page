import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

/// Retrato do Jose dentro de um buraco negro estilo Gargantua (Interstellar),
/// neon liso (sem blocos pixel) seguindo a referencia: disco de acrescimo
/// tilted que ENVOLVE a esfera — asas grossas e saturadas nos lados, faixa
/// frontal cruzando por baixo, e o ARCO LENSADO da face oposta curvando POR
/// CIMA do horizonte (assinatura Gargantua). Composto em duas camadas em
/// volta da foto pra preservar o rosto:
///
/// - **atras** (`painter`): bloom magenta/roxo + disco inteiro (a foto cobre o
///   miolo, so sobram as asas/topo/base alem da esfera).
/// - **frente** (`foregroundPainter`): metade frontal do disco cruzando por
///   baixo + arco frontal nitido na base + arco lente por cima + photon ring.
///
/// O disco e desenhado no "plano" do disco (canvas achatado em `_tiltY` ->
/// elipse), com gradiente radial de TEMPERATURA (branco quente no interior ->
/// dourado -> laranja -> vermelho -> magenta -> roxo na borda), Doppler beaming
/// (lado que se aproxima mais claro, sweep aditivo) e um hotspot orbitando.
class BlackHolePortrait extends StatefulWidget {
  const BlackHolePortrait({
    required this.diskHot,
    required this.diskCool,
    required this.size,
    super.key,
  });

  final Color diskHot;
  final Color diskCool;
  final double size;

  @override
  State<BlackHolePortrait> createState() => _BlackHolePortraitState();
}

class _BlackHolePortraitState extends State<BlackHolePortrait>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    // Foto = horizonte de eventos. photoR e fracao do half; o diametro da
    // foto e photoR * size (deixa espaco em volta pro disco).
    final photo = widget.size * _GargantuaPainter.photoR;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _GargantuaPainter(animation: _controller, front: false),
          foregroundPainter: _GargantuaPainter(
            animation: _controller,
            front: true,
          ),
          child: Center(
            child: SizedBox.square(
              dimension: photo,
              child: ClipOval(
                child: ColoredBox(
                  color: const Color(0xFF080510),
                  // scale 0.85 mostra rosto + ombros (nao so a cabeca).
                  child: Transform.scale(
                    scale: 0.85,
                    alignment: Alignment.topCenter,
                    child: Image.asset(
                      'assets/images/foto_recortada.webp',
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      cacheWidth: 640,
                      excludeFromSemantics: true,
                      // Sem o asset (ex.: teste), cai num vazio escuro em vez
                      // do placeholder vermelho de imagem quebrada.
                      errorBuilder: (_, _, _) =>
                          const ColoredBox(color: Color(0xFF080510)),
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

/// Uma particula de poeira do disco (params normalizados, sem pixel).
typedef _Dust = ({
  double t,
  double ang,
  double perp,
  int band,
  double br,
  double speed,
});

enum _DiskClip { all, front }

/// Pinta uma das camadas do buraco negro (atras/frente da foto).
class _GargantuaPainter extends CustomPainter {
  _GargantuaPainter({required Animation<double> animation, required this.front})
    : _anim = animation,
      _paint = Paint()..isAntiAlias = true,
      _stroke = (Paint()
        ..style = PaintingStyle.stroke
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round),
      super(repaint: animation);

  final Animation<double> _anim;
  final bool front;
  final Paint _paint;
  final Paint _stroke;

  // Shaders estaticos por tamanho — criados UMA vez por `half` e reusados todo
  // frame. Criar gradiente/shader por frame e caro (recompila no skia/web).
  double _shHalf = -1;
  ui.Shader? _bloomShader;
  ui.Shader? _bodyShader;
  ui.Shader? _hotspotShader;
  ui.Shader? _lensShader;

  // Buckets (banda x nivel Doppler) reusados entre frames — `..clear()` em vez
  // de realocar 18 listas por frame. So os Offsets sao recriados (a posicao das
  // particulas muda a cada tick).
  late final List<List<Offset>> _buckets = List.generate(
    _bandColors.length * _dopLevels,
    (_) => <Offset>[],
  );

  /// Raio da foto (esfera/horizonte) como fracao do half-size.
  static const double photoR = 0.44;
  static const double _diskIn = 0.45;
  static const double _diskOut = 0.96;
  // Tilt: o quao aberto o disco esta (1 = de frente, 0 = de perfil). Bem
  // raso = leitura edge-on de Gargantua: asas largas e FLAT nos lados, faixa
  // fina cruzando a frente, sem virar anel/portal em volta do rosto.
  static const double _tiltY = 0.27;
  // Inclinacao diagonal do disco inteiro (rad). Negativo = ponta direita pra
  // cima. Da o "olhar" 3/4 do Gargantua em vez de um disco reto.
  static const double _diskAngle = -0.36;

  // Rampa de temperatura do disco (interno quente -> externo frio).
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _gold = Color(0xFFFFD24A);
  static const Color _orange = Color(0xFFFF8A1E);
  static const Color _redOrange = Color(0xFFFF3B1E);
  static const Color _magenta = Color(0xFFFF2E86);
  static const Color _purple = Color(0xFF9A36FF);

  // CAMADAS do disco: cada banda de raio tem uma cor (temperatura), alpha e
  // tamanho de particula propios. Interno quente/denso -> externo frio/esparso.
  static const List<Color> _bandColors = [
    _white,
    _gold,
    _orange,
    _redOrange,
    _magenta,
    _purple,
  ];
  static const List<double> _bandAlpha = [0.95, 0.82, 0.78, 0.64, 0.5, 0.38];
  static const List<double> _bandSize = [
    0.010,
    0.011,
    0.012,
    0.013,
    0.014,
    0.013,
  ];
  static const int _dopLevels = 3;

  /// Poeira do disco, pre-computada uma vez (params normalizados, sem unidade
  /// de pixel — escalados por frame). Cada particula sabe seu raio `t`, angulo
  /// base, jitter perpendicular, banda de cor, brilho e velocidade orbital
  /// (interno mais rapido, ~Kepler).
  static final List<_Dust> _particles = _buildParticles();

  static _Dust _dust(math.Random rng, double t, int band) => (
    t: t,
    ang: rng.nextDouble() * 2 * math.pi,
    perp: rng.nextDouble() - 0.5,
    band: band,
    br: 0.42 + rng.nextDouble() * 0.58,
    speed: 0.5 + 0.95 * (1 - t),
  );

  static List<_Dust> _buildParticles() {
    final rng = math.Random(20260616);
    final list = <_Dust>[];
    // Base: todas as bandas, bias leve pra fora (asas mais densas). Contagem
    // enxuta — o corpo difuso (shader) preenche os vaos, entao menos particula
    // nao rala a leitura mas corta CPU/GC (o loop roda 2x por frame: tras+frente).
    for (var i = 0; i < 1400; i++) {
      final t = math.pow(rng.nextDouble(), 0.78).toDouble();
      final band = (t * _bandColors.length).floor().clamp(
        0,
        _bandColors.length - 1,
      );
      list.add(_dust(rng, t, band));
    }
    // EXTRA: mais poeira BRANCA (banda 0) e AMARELA (banda 1) no anel interno
    // quente, sem tocar nas outras bandas.
    const span = 1 / 6; // largura de uma banda em t (6 bandas)
    for (var i = 0; i < 750; i++) {
      list.add(_dust(rng, rng.nextDouble() * span, 0)); // branca
    }
    for (var i = 0; i < 550; i++) {
      list.add(_dust(rng, span + rng.nextDouble() * span, 1)); // amarela
    }
    return list;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final half = size.shortestSide / 2;
    final phase = _anim.value * 2 * math.pi;
    _ensureShaders(half, center);

    if (!front) {
      _bloom(canvas, center, half);
      _disk(canvas, center, half, phase, clip: _DiskClip.all);
    } else {
      _disk(canvas, center, half, phase, clip: _DiskClip.front);
      _lensArc(canvas, center, half);
      _photonRing(canvas, center, half);
    }
  }

  /// (Re)cria os shaders estaticos quando o tamanho muda. Tudo que NAO depende
  /// do tempo (bloom, corpo difuso, hotspot na origem, arco lensado) vira shader
  /// cacheado — fora do hot loop de 60 Hz.
  void _ensureShaders(double half, Offset center) {
    if (_shHalf == half) return;
    _shHalf = half;
    final rOut = _diskOut * half;

    _bloomShader = RadialGradient(
      colors: [
        const Color(0xFFFF8A1E).withValues(alpha: 0.10),
        const Color(0xFF9A36FF).withValues(alpha: 0.14),
        const Color(0xFFFF2E86).withValues(alpha: 0.06),
        Colors.transparent,
      ],
      stops: const [0.0, 0.45, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: half * 1.15));

    const fIn = _diskIn / _diskOut;
    _bodyShader = RadialGradient(
      colors: [
        _orange.withValues(alpha: 0),
        _redOrange.withValues(alpha: 0.10),
        _magenta.withValues(alpha: 0.06),
        Colors.transparent,
      ],
      stops: const [fIn * 0.85, fIn + 0.04, 0.82, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: rOut));

    _hotspotShader = RadialGradient(
      colors: [_white.withValues(alpha: 0.4), _white.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: rOut * 0.24));

    const start = math.pi * 1.12;
    const sweep = math.pi * 0.76;
    _lensShader = SweepGradient(
      startAngle: start,
      endAngle: start + sweep,
      colors: [
        _orange.withValues(alpha: 0),
        _gold.withValues(alpha: 0.9),
        _white,
        _gold.withValues(alpha: 0.9),
        _orange.withValues(alpha: 0),
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: photoR * half));
  }

  void _bloom(Canvas canvas, Offset center, double half) {
    _paint
      ..shader = _bloomShader
      ..blendMode = BlendMode.srcOver;
    canvas.drawCircle(center, half * 1.15, _paint);
    _paint.shader = null;
  }

  void _disk(
    Canvas canvas,
    Offset center,
    double half,
    double phase, {
    required _DiskClip clip,
  }) {
    final rOut = _diskOut * half;
    final rIn = _diskIn * half;
    final band = rOut - rIn;

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      // Inclina o disco inteiro na diagonal.
      ..rotate(_diskAngle);

    // Metade frontal: so a faixa da frente (cruza por baixo do rosto).
    if (clip == _DiskClip.front) {
      canvas.clipRect(
        Rect.fromLTWH(-rOut, -band * 0.04, rOut * 2, rOut * _tiltY + half),
      );
    }

    // 1) Corpo difuso: brilho quente suave entre as particulas (tampa buracos
    //    pretos sem virar disco chapado). Elipse achatada, aditivo. Shader
    //    cacheado por tamanho.
    _paint
      ..shader = _bodyShader
      ..blendMode = BlendMode.plus;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset.zero,
        width: rOut * 2,
        height: rOut * 2 * _tiltY,
      ),
      _paint,
    );
    _paint
      ..shader = null
      ..blendMode = BlendMode.srcOver;

    // 2) Poeira em CAMADAS: cada particula cai numa banda de raio (cor por
    //    temperatura) e orbita (interno mais rapido). Brilho = Doppler (lado
    //    esquerdo que se aproxima mais intenso). Bucketizado por
    //    (banda x nivel Doppler) -> poucas chamadas drawPoints batched.
    for (final b in _buckets) {
      b.clear();
    }
    for (final p in _particles) {
      final radius = rIn + band * p.t + p.perp * band * 0.17;
      final th = p.ang + phase * p.speed * 1.35;
      final ca = math.cos(th);
      final sa = math.sin(th);
      final c = (1 - ca) / 2; // 1 = esquerda (aproxima), 0 = direita
      final bright = (p.br * (0.22 + math.pow(c, 1.4).toDouble()))
          .clamp(0.0, 1.0);
      final dl = (bright * _dopLevels).floor().clamp(0, _dopLevels - 1);
      _buckets[p.band * _dopLevels + dl].add(
        Offset(ca * radius, sa * radius * _tiltY),
      );
    }
    for (var bi = 0; bi < _bandColors.length; bi++) {
      for (var dl = 0; dl < _dopLevels; dl++) {
        final pts = _buckets[bi * _dopLevels + dl];
        if (pts.isEmpty) continue;
        final a = (_bandAlpha[bi] * (0.25 + 0.75 * (dl + 1) / _dopLevels))
            .clamp(0.0, 1.0);
        _paint
          ..color = _bandColors[bi].withValues(alpha: a)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = half * _bandSize[bi]
          ..blendMode = BlendMode.plus;
        canvas.drawPoints(PointMode.points, pts, _paint);
      }
    }

    // 3) Hotspot orbitando — sobre-densidade quente. Shader cacheado na origem;
    //    translada o canvas pro spot em vez de recriar o gradiente por frame.
    final rMid = (rIn + rOut) / 2;
    final spot = Offset(math.cos(phase) * rMid, math.sin(phase) * rMid * _tiltY);
    _paint
      ..shader = _hotspotShader
      ..blendMode = BlendMode.plus;
    canvas
      ..save()
      ..translate(spot.dx, spot.dy)
      ..drawCircle(Offset.zero, rOut * 0.24, _paint)
      ..restore();

    _paint
      ..shader = null
      ..blendMode = BlendMode.srcOver
      ..strokeCap = StrokeCap.butt;
    canvas.restore();
  }

  void _lensArc(Canvas canvas, Offset center, double half) {
    // Face oposta do disco curvada sobre o TOPO da esfera — assinatura
    // Gargantua. Arco fino COLADO na borda do horizonte (so na metade de
    // cima), inclinado junto com o disco (mesma diagonal).
    final r = photoR * half;
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    const start = math.pi * 1.12;
    const sweep = math.pi * 0.76;

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(_diskAngle);

    _stroke
      ..shader = _lensShader
      ..strokeWidth = half * 0.045
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
      ..blendMode = BlendMode.plus;
    canvas.drawArc(rect, start, sweep, false, _stroke);

    _stroke
      ..maskFilter = null
      ..shader = null
      ..color = _white
      ..strokeWidth = half * 0.012
      ..blendMode = BlendMode.srcOver;
    canvas
      ..drawArc(rect, start + 0.12, sweep - 0.24, false, _stroke)
      ..restore();
  }

  void _photonRing(Canvas canvas, Offset center, double half) {
    // Fio fino quente na borda do horizonte. Sem glow gordo (vira moldura).
    final r = photoR * half;
    _stroke
      ..maskFilter = null
      ..shader = null
      ..color = _white.withValues(alpha: 0.85)
      ..strokeWidth = half * 0.01
      ..blendMode = BlendMode.srcOver;
    canvas.drawCircle(center, r + half * 0.006, _stroke);
  }

  @override
  bool shouldRepaint(_GargantuaPainter old) => old.front != front;
}
