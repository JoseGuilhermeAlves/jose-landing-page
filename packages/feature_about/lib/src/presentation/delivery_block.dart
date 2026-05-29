import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Bloco "Como eu entrego" — 3 cards com narrativa expandida sobre o
/// jeito de trabalhar. Substitui o manifesto curto em mono. Cada
/// card tem painter abstrato no canto, headline em gradient brand
/// e parágrafo. Visualmente apelativo + texto longo o suficiente pra
/// dar substância sem virar página.
class DeliveryBlock extends StatelessWidget {
  const DeliveryBlock({super.key});

  static const List<_DeliveryCard> _cards = [
    _DeliveryCard(
      eyebrow: 'ENTREGA',
      title: 'Escopo claro,',
      titleAccent: 'expectativa alinhada.',
      body:
          'Cada projeto começa pelo recorte: o que entra, o que fica de '
          'fora, e como cada decisão amarra um critério de aceite. Sem '
          'isso, sprint vira corrida de prazo. Trabalho com PO e design '
          'desde o kickoff pra que o backlog reflita o que vai pra '
          'produção — não o que parece bonito no protótipo.',
      glyph: _DeliveryGlyph.checklist,
    ),
    _DeliveryCard(
      eyebrow: 'CRAFT',
      title: 'Arquitetura e',
      titleAccent: 'performance reais.',
      body:
          'Clean Architecture por feature, Bloc/Cubit pra estado, '
          'CustomPainter quando vetor é mais barato que asset. Mede '
          'tempo de frame em device real (não emulador), perfila build '
          'time, audita rebuilds. Stack de produção sustenta '
          'evolução — não emperra dois meses depois do MVP.',
      glyph: _DeliveryGlyph.layers,
    ),
    _DeliveryCard(
      eyebrow: 'COLABORAÇÃO',
      title: 'No time de produto',
      titleAccent: 'ou no Flutter inteiro.',
      body:
          'Em time grande entro como front end mobile com escopo de '
          'feature ou stewardship arquitetural. Em time pequeno (varejo '
          'B2B, 5 anos) cuidei do Flutter inteiro — do design ao '
          'deploy, integrando APIs já existentes e ajudando a moldar '
          'contratos novos quando o caminho era esse. Ajusto-me ao '
          'tamanho do time, não ao contrário.',
      glyph: _DeliveryGlyph.handshake,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _cards.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            _cards[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.md),
            Expanded(child: _cards[i]),
          ],
        ],
      ),
    );
  }
}

enum _DeliveryGlyph { checklist, layers, handshake }

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({
    required this.eyebrow,
    required this.title,
    required this.titleAccent,
    required this.body,
    required this.glyph,
  });

  final String eyebrow;
  final String title;
  final String titleAccent;
  final String body;
  final _DeliveryGlyph glyph;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.primary.withValues(alpha: 0.05)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          Positioned(
            top: -8,
            right: -8,
            child: IgnorePointer(
              child: SizedBox(
                width: 90,
                height: 90,
                child: CustomPaint(
                  painter: _DeliveryGlyphPainter(
                    glyph: glyph,
                    color: colors.primary,
                  ),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                eyebrow,
                style: tt.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              RichText(
                text: TextSpan(
                  style: tt.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    height: 1.2,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(text: '$title '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        shaderCallback: (rect) =>
                            AppGradients.brand(colors).createShader(rect),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          titleAccent,
                          style: tt.headlineSmall?.copyWith(
                            color: colors.onSurface,
                            height: 1.2,
                            letterSpacing: -0.4,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                body,
                style: tt.bodyMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.65,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Glifo decorativo no canto do card — desenhado em Path em vez de
/// asset/ícone pra manter peso visual coerente com o resto do painter
/// vocabulary da landing.
class _DeliveryGlyphPainter extends CustomPainter {
  _DeliveryGlyphPainter({required this.glyph, required this.color});

  final _DeliveryGlyph glyph;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true
      ..strokeWidth = 1.5
      ..color = color.withValues(alpha: 0.35);
    final w = size.width;
    final h = size.height;
    switch (glyph) {
      case _DeliveryGlyph.checklist:
        // Quadrado leve + 3 ticks empilhados.
        final box = Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.64);
        canvas.drawRRect(
          RRect.fromRectAndRadius(box, const Radius.circular(6)),
          paint,
        );
        for (var i = 0; i < 3; i++) {
          final y = h * (0.32 + i * 0.18);
          // Tick mark.
          final start = Offset(w * 0.30, y);
          final mid = Offset(w * 0.40, y + h * 0.04);
          final end = Offset(w * 0.56, y - h * 0.05);
          final tickPath = Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(mid.dx, mid.dy)
            ..lineTo(end.dx, end.dy);
          canvas.drawPath(tickPath, paint);
        }
      case _DeliveryGlyph.layers:
        // Tres trapezoidos sobrepostos sugerindo arquitetura em
        // camadas.
        for (var i = 0; i < 3; i++) {
          final yTop = h * (0.20 + i * 0.18);
          final yBot = h * (0.30 + i * 0.18);
          final inset = i * 8.0;
          final path = Path()
            ..moveTo(w * 0.20 + inset, yTop)
            ..lineTo(w * 0.80 - inset, yTop)
            ..lineTo(w * 0.72 - inset, yBot)
            ..lineTo(w * 0.28 + inset, yBot)
            ..close();
          canvas.drawPath(path, paint);
        }
      case _DeliveryGlyph.handshake:
        // Dois arcos entrelacados (anel infinito) sugerindo
        // colaboracao mutua.
        final r = math.min(w, h) * 0.28;
        final c1 = Offset(w * 0.36, h * 0.5);
        final c2 = Offset(w * 0.64, h * 0.5);
        canvas
          ..drawCircle(c1, r, paint)
          ..drawCircle(c2, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DeliveryGlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
