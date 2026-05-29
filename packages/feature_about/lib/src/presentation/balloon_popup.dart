import 'package:design_system/design_system.dart';
import 'package:feature_about/src/domain/domain_highlight.dart';
import 'package:flutter/material.dart';

/// Balao tipo speech bubble ancorado a um planeta da constelacao.
/// **Nao usa Dialog ou rota nova** — vive como Positioned dentro do
/// Stack da cena. Posiciona-se acima ou abaixo do planeta segundo o
/// y normalizado; a cauda (pequeno quadrado rotacionado 45 graus)
/// aponta pro planeta.
///
/// Entry animada: fade + scale tween 220ms easeOutBack.
class BalloonPopup extends StatefulWidget {
  const BalloonPopup({
    required this.domain,
    required this.planetCenter,
    required this.sceneSize,
    super.key,
  });

  /// Dominio cujo planeta foi tapado.
  final DomainHighlight domain;

  /// Centro do planeta em px dentro da cena.
  final Offset planetCenter;

  /// Tamanho total da cena (px) — usado pra clamp horizontal do balao.
  final Size sceneSize;

  @override
  State<BalloonPopup> createState() => _BalloonPopupState();
}

class _BalloonPopupState extends State<BalloonPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant BalloonPopup old) {
    super.didUpdateWidget(old);
    if (old.domain.id != widget.domain.id) {
      _entry
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final sceneW = widget.sceneSize.width;
    final sceneH = widget.sceneSize.height;
    final centerX = widget.planetCenter.dx;
    final centerY = widget.planetCenter.dy;

    // Layout dimensions.
    final balloonWidth = (sceneW * 0.34).clamp(220.0, 320.0);
    const gap = 18.0;
    const tailSize = 14.0;

    // Decide se o balao aparece acima ou abaixo do planeta com base
    // na posicao y do planeta na cena.
    final placeAbove = centerY > sceneH * 0.45;

    // Horizontal clamp pra nao vazar pra fora da cena.
    final balloonLeft = (centerX - balloonWidth / 2).clamp(
      8.0,
      sceneW - balloonWidth - 8.0,
    );

    // Cauda aponta pro planeta sempre, mesmo apos o clamp horizontal.
    final tailCenterX = (centerX - balloonLeft).clamp(
      tailSize + 6,
      balloonWidth - tailSize - 6,
    );

    return AnimatedBuilder(
      animation: _entry,
      builder: (context, _) {
        final t = Curves.easeOutBack.transform(_entry.value);
        return Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned(
              left: balloonLeft,
              top: placeAbove ? null : centerY + gap,
              bottom: placeAbove ? sceneH - centerY + gap : null,
              child: IgnorePointer(
                child: Opacity(
                  opacity: t.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.85 + 0.15 * t.clamp(0.0, 1.0),
                    alignment: placeAbove
                        ? Alignment.bottomCenter
                        : Alignment.topCenter,
                    child: SizedBox(
                      width: balloonWidth,
                      child: _BalloonBody(
                        domain: widget.domain,
                        textTheme: tt,
                        colors: colors,
                        tailCenterX: tailCenterX,
                        tailOnTop: !placeAbove,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BalloonBody extends StatelessWidget {
  const _BalloonBody({
    required this.domain,
    required this.textTheme,
    required this.colors,
    required this.tailCenterX,
    required this.tailOnTop,
  });

  final DomainHighlight domain;
  final TextTheme textTheme;
  final AppColorScheme colors;
  final double tailCenterX;
  final bool tailOnTop;

  static const double _tailSize = 14;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surface, colors.primary.withValues(alpha: 0.10)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(domain.icon, color: colors.primary, size: 14),
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  domain.label,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (domain.isEndToEnd) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.45),
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text(
                'front end inteiro',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            domain.blurb,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );

    final tail = Transform.translate(
      offset: Offset(tailCenterX - _tailSize / 2, 0),
      child: Transform.rotate(
        angle: 0.785398, // 45 deg
        child: Container(
          width: _tailSize,
          height: _tailSize,
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
        ),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tailOnTop)
          ClipRect(
            child: SizedBox(
              height: _tailSize / 2 + 1,
              child: OverflowBox(
                maxHeight: _tailSize + 4,
                alignment: Alignment.bottomLeft,
                child: tail,
              ),
            ),
          ),
        body,
        if (!tailOnTop)
          ClipRect(
            child: SizedBox(
              height: _tailSize / 2 + 1,
              child: OverflowBox(
                maxHeight: _tailSize + 4,
                alignment: Alignment.topLeft,
                child: tail,
              ),
            ),
          ),
      ],
    );
  }
}
