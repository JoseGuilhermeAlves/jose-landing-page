import 'package:feature_tech/src/domain/painter_highlight.dart';

/// Painters destacados do projeto. NAO e a lista exaustiva (mocks tem
/// painters proprios em feature_showcase/<mock>/presentation); aqui
/// ficam os de maior densidade tecnica, com role explicita.
abstract final class PaintersCatalog {
  static const List<PainterHighlight> all = [
    PainterHighlight(
      name: 'ParticleFieldPainter',
      role:
          'Particulas reativas a mouse, throttle por Ticker pra nao '
          'saturar com onHover.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'AnimatedBorderPainter',
      role:
          'Borda que se revela via PathMetrics.extractPath em hover, '
          'sem redesenhar segmento a segmento.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'WaveDividerPainter',
      role:
          'Wave horizontal animada em loop continuo separando as '
          'secoes da home.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'MorphingShapePainter',
      role: 'Interpolacao bezier entre formas. Centro do teaser do /labs.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'RippleHoverPainter',
      role:
          'Ondas em expansao no centro do cursor — feedback de toque '
          'em cards.',
      location: 'packages/animations',
    ),
    PainterHighlight(
      name: 'AuroraDeliveryMap',
      role:
          'Mapa cartografico animado com rota Bezier + courier rotacionado '
          'via PathMetrics.getTangentForOffset.',
      location: 'feature_showcase / delivery',
    ),
    PainterHighlight(
      name: 'VitralClockPainter',
      role:
          'Relogio analogico com ponteiro de segundos animado em loop '
          'de 60s — trig pra ticks.',
      location: 'feature_showcase / scheduling',
    ),
    PainterHighlight(
      name: 'PulsoActivityRings',
      role:
          'Aneis estilo Apple Watch com progresso animado por treino e '
          'cache de paths.',
      location: 'feature_showcase / fitness',
    ),
    PainterHighlight(
      name: 'MiraCandlestickChart',
      role: 'Velas OHLC com crosshair interativo, tooltip e seed-determinismo.',
      location: 'feature_showcase / finance',
    ),
  ];
}
