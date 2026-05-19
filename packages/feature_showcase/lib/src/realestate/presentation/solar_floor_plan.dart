import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/domain/property_feature.dart';
import 'package:feature_showcase/src/realestate/domain/property_type.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:flutter/material.dart';

/// Planta baixa esquematica derivada dos dados de [Property] — destaque
/// tecnico do mock Solar. Gera um layout determinista de comodos a
/// partir de `bedrooms`, `suites`, `parkingSpots` e `features`,
/// rotulando cada comodo via `TextPainter`.
///
/// Performance:
/// - Paints, paths e text painters cacheados por instancia.
/// - `_rooms` calculado uma vez no construtor e cacheado.
/// - `shouldRepaint` confronta os campos relevantes (property +
///   cores).
///
/// O painter nao anima — esta inteiramente no `painter` slot do
/// `CustomPaint` sem controller.
class SolarFloorPlan extends StatelessWidget {
  const SolarFloorPlan({
    required this.property,
    this.foregroundColor,
    this.accentColor,
    this.backgroundColor,
    this.wallColor,
    super.key,
  });

  final Property property;
  final Color? foregroundColor;
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? wallColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? scheme.onSurface;
    final accent = accentColor ?? scheme.secondary;
    final bg = backgroundColor ?? SolarBrand.palette.surface;
    final walls = wallColor ?? scheme.primary;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SolarFloorPlanPainter(
          property: property,
          foregroundColor: fg,
          accentColor: accent,
          backgroundColor: bg,
          wallColor: walls,
        ),
      ),
    );
  }
}

/// Tipo de comodo desenhado na planta. Cada um tem rotulo e estilo
/// proprio (cor de fundo levemente diferente, glifo central).
enum _RoomKind {
  living('Sala'),
  kitchen('Cozinha'),
  bath('Banheiro'),
  suite('Suite'),
  bedroom('Quarto'),
  balcony('Varanda'),
  garage('Garagem'),
  pool('Piscina'),
  garden('Jardim');

  const _RoomKind(this.label);
  final String label;
}

/// Retangulo de um comodo na planta (coordenadas relativas 0..1).
class _Room {
  const _Room({
    required this.rect,
    required this.kind,
  });
  final Rect rect;
  final _RoomKind kind;
}

class _SolarFloorPlanPainter extends CustomPainter {
  _SolarFloorPlanPainter({
    required this.property,
    required this.foregroundColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.wallColor,
  }) : _rooms = _layout(property);

  final Property property;
  final Color foregroundColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color wallColor;

  /// Lista de comodos com coordenadas relativas (0..1). Computada uma
  /// vez no construtor a partir dos campos da [Property].
  final List<_Room> _rooms;

  late final Paint _bgPaint = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  late final Paint _wallPaint = Paint()
    ..color = wallColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeJoin = StrokeJoin.miter;

  late final Paint _innerWallPaint = Paint()
    ..color = wallColor.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..strokeJoin = StrokeJoin.miter;

  late final Paint _floorPaint = Paint()
    ..color = accentColor.withValues(alpha: 0.10)
    ..style = PaintingStyle.fill;

  late final Paint _doorPaint = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  late final Paint _waterPaint = Paint()
    ..color = accentColor.withValues(alpha: 0.55)
    ..style = PaintingStyle.fill;

  late final Paint _grassPaint = Paint()
    ..color = accentColor.withValues(alpha: 0.30)
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Pano de fundo neutro do papel da planta.
    canvas.drawRect(Offset.zero & size, _bgPaint);

    // Bounding outer wall (envolvendo todos os comodos).
    final outer = _outerRect(size);
    canvas
      ..drawRect(outer, _floorPaint)
      ..drawRect(outer, _wallPaint);

    // Comodos.
    for (final room in _rooms) {
      final rect = Rect.fromLTRB(
        room.rect.left * size.width,
        room.rect.top * size.height,
        room.rect.right * size.width,
        room.rect.bottom * size.height,
      );
      _paintRoom(canvas, rect, room.kind);
    }

    // Marcador "N" para norte no canto.
    _paintCompass(canvas, size);
  }

  Rect _outerRect(Size size) {
    if (_rooms.isEmpty) {
      return Rect.fromLTWH(
        size.width * 0.10,
        size.height * 0.10,
        size.width * 0.80,
        size.height * 0.80,
      );
    }
    var left = 1.0;
    var top = 1.0;
    var right = 0.0;
    var bottom = 0.0;
    for (final r in _rooms) {
      if (r.rect.left < left) left = r.rect.left;
      if (r.rect.top < top) top = r.rect.top;
      if (r.rect.right > right) right = r.rect.right;
      if (r.rect.bottom > bottom) bottom = r.rect.bottom;
    }
    return Rect.fromLTRB(
      left * size.width,
      top * size.height,
      right * size.width,
      bottom * size.height,
    );
  }

  void _paintRoom(Canvas canvas, Rect rect, _RoomKind kind) {
    if (rect.width <= 0 || rect.height <= 0) return;
    // Fundo leve do comodo conforme tipo.
    switch (kind) {
      case _RoomKind.pool:
        canvas.drawRect(rect.deflate(2), _waterPaint);
      case _RoomKind.garden:
        canvas.drawRect(rect.deflate(2), _grassPaint);
      case _RoomKind.suite || _RoomKind.bedroom:
        canvas.drawRect(rect.deflate(2), _floorPaint);
      case _RoomKind.living || _RoomKind.kitchen:
        canvas.drawRect(rect.deflate(2), _floorPaint);
      // ignore: no_default_cases
      default:
        break;
    }
    // Paredes do comodo + marcador de porta na base.
    canvas
      ..drawRect(rect, _innerWallPaint)
      ..drawLine(
        Offset(rect.left + rect.width * 0.40, rect.bottom),
        Offset(rect.left + rect.width * 0.60, rect.bottom),
        _doorPaint,
      );
    // Rotulo centralizado (pula em comodos muito pequenos).
    if (rect.width >= 36 && rect.height >= 22) {
      _paintLabel(canvas, rect, kind.label);
    }
  }

  void _paintLabel(Canvas canvas, Rect rect, String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: foregroundColor,
          fontFamily: SolarBrand.displayFontFamily,
          fontSize: rect.shortestSide * 0.20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: rect.width - 6);
    final offset = Offset(
      rect.center.dx - tp.width / 2,
      rect.center.dy - tp.height / 2,
    );
    tp.paint(canvas, offset);
  }

  void _paintCompass(Canvas canvas, Size size) {
    final origin = Offset(size.width - 18, 18);
    final tp = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: accentColor,
          fontFamily: SolarBrand.displayFontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.drawLine(
      Offset(origin.dx, origin.dy + 4),
      Offset(origin.dx, origin.dy + 14),
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    tp.paint(canvas, Offset(origin.dx - tp.width / 2, origin.dy - tp.height));
  }

  /// Algoritmo de layout — recebe a [property] e devolve a lista de
  /// comodos em coordenadas relativas (0..1). Determinista pra que a
  /// mesma propriedade sempre renda a mesma planta.
  ///
  /// Layout-base de duas faixas: superior (sociais + servico) e
  /// inferior (intimo: quartos/suites/banheiros). Vagas e areas
  /// externas (piscina, jardim, varanda) sao adicionadas se a
  /// propriedade tiver a feature ou parkingSpots > 0.
  static List<_Room> _layout(Property property) {
    // Terreno puro nao tem planta — devolve lista vazia, painter
    // desenha so o lote externo.
    if (property.type == PropertyType.land) return const [];

    final bedrooms = property.bedrooms.clamp(0, 5);
    final suites = property.suites.clamp(0, bedrooms);
    final hasGarage = property.parkingSpots > 0 ||
        property.features.contains(PropertyFeature.garage);
    final hasPool = property.features.contains(PropertyFeature.pool);
    final hasGarden = property.features.contains(PropertyFeature.garden);
    final hasBalcony = property.features.contains(PropertyFeature.balcony);

    // Caixa principal — deixa margens pra varanda/garagem externas.
    const topMargin = 0.08;
    const bottomMargin = 0.08;
    final leftMargin = hasGarage ? 0.22 : 0.08;
    final rightMargin = hasPool || hasGarden ? 0.22 : 0.08;
    final houseLeft = leftMargin;
    final houseRight = 1.0 - rightMargin;
    const houseTop = topMargin;
    const houseBottom = 1.0 - bottomMargin;
    final houseW = houseRight - houseLeft;
    const houseH = houseBottom - houseTop;

    // Faixa superior (sociais): sala + cozinha + banho social.
    const topRowH = houseH * 0.45;
    const bottomRowH = houseH * 0.55;

    final rooms = <_Room>[
      // Sala — 50% da faixa superior.
      _Room(
        kind: _RoomKind.living,
        rect: Rect.fromLTWH(
          houseLeft,
          houseTop,
          houseW * 0.50,
          topRowH,
        ),
      ),
      // Cozinha — 32%.
      _Room(
        kind: _RoomKind.kitchen,
        rect: Rect.fromLTWH(
          houseLeft + houseW * 0.50,
          houseTop,
          houseW * 0.32,
          topRowH,
        ),
      ),
      // Banheiro social — 18%.
      _Room(
        kind: _RoomKind.bath,
        rect: Rect.fromLTWH(
          houseLeft + houseW * 0.82,
          houseTop,
          houseW * 0.18,
          topRowH,
        ),
      ),
    ];

    // Faixa inferior — divide em colunas iguais entre os quartos.
    // Primeiro N suites (com indicador), depois (bedrooms - suites)
    // quartos comuns. Caso especial: 0 quartos (chacara simbolica),
    // ocupa toda faixa com uma area de servico (mantemos como sala
    // grande sem rotulo).
    final roomCount = bedrooms == 0 ? 0 : bedrooms;
    if (roomCount > 0) {
      final colW = houseW / roomCount;
      for (var i = 0; i < roomCount; i++) {
        final kind = i < suites ? _RoomKind.suite : _RoomKind.bedroom;
        rooms.add(
          _Room(
            kind: kind,
            rect: Rect.fromLTWH(
              houseLeft + colW * i,
              houseTop + topRowH,
              colW,
              bottomRowH,
            ),
          ),
        );
      }
    }

    // Varanda — faixa horizontal no topo, sobreposta acima da sala
    // (so quando ha balcony).
    if (hasBalcony) {
      rooms.add(
        _Room(
          kind: _RoomKind.balcony,
          rect: Rect.fromLTRB(
            houseLeft,
            houseTop - 0.06,
            houseLeft + houseW * 0.50,
            houseTop,
          ),
        ),
      );
    }

    // Garagem — coluna a esquerda.
    if (hasGarage) {
      rooms.add(
        _Room(
          kind: _RoomKind.garage,
          rect: Rect.fromLTRB(
            houseLeft - 0.18,
            houseTop + houseH * 0.10,
            houseLeft,
            houseTop + houseH * 0.70,
          ),
        ),
      );
    }

    // Piscina + jardim — coluna a direita.
    if (hasPool && hasGarden) {
      rooms
        ..add(
          _Room(
            kind: _RoomKind.pool,
            rect: Rect.fromLTRB(
              houseRight,
              houseTop + houseH * 0.08,
              houseRight + 0.18,
              houseTop + houseH * 0.50,
            ),
          ),
        )
        ..add(
          _Room(
            kind: _RoomKind.garden,
            rect: Rect.fromLTRB(
              houseRight,
              houseTop + houseH * 0.55,
              houseRight + 0.18,
              houseTop + houseH * 0.90,
            ),
          ),
        );
    } else if (hasPool) {
      rooms.add(
        _Room(
          kind: _RoomKind.pool,
          rect: Rect.fromLTRB(
            houseRight,
            houseTop + houseH * 0.20,
            houseRight + 0.18,
            houseTop + houseH * 0.80,
          ),
        ),
      );
    } else if (hasGarden) {
      rooms.add(
        _Room(
          kind: _RoomKind.garden,
          rect: Rect.fromLTRB(
            houseRight,
            houseTop + houseH * 0.20,
            houseRight + 0.18,
            houseTop + houseH * 0.80,
          ),
        ),
      );
    }

    return rooms;
  }

  @override
  bool shouldRepaint(_SolarFloorPlanPainter old) {
    return old.property != property ||
        old.foregroundColor != foregroundColor ||
        old.accentColor != accentColor ||
        old.backgroundColor != backgroundColor ||
        old.wallColor != wallColor;
  }
}
