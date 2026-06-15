import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Bloco "Como eu entrego" — 3 rows estilo changelog revestidas na
/// identidade Arcade (herdado da estrutura texto-primeiro da designmd,
/// superior aos cards genericos). Cada row: numero de "stage" em fonte
/// pixel magenta, eyebrow pixel ciano, titulo legivel com acento magenta
/// e paragrafo muted, separados por hairline neon. No mobile empilha.
/// Sem card, sem glifo decorativo — texto-primeiro.
class DeliveryBlock extends StatelessWidget {
  const DeliveryBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final rows = [
      (
        l10n.delivery_entrega_eyebrow,
        l10n.delivery_entrega_title,
        l10n.delivery_entrega_titleAccent,
        l10n.delivery_entrega_body,
      ),
      (
        l10n.delivery_craft_eyebrow,
        l10n.delivery_craft_title,
        l10n.delivery_craft_titleAccent,
        l10n.delivery_craft_body,
      ),
      (
        l10n.delivery_collab_eyebrow,
        l10n.delivery_collab_title,
        l10n.delivery_collab_titleAccent,
        l10n.delivery_collab_body,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++)
          _DeliveryRow(
            stage: (i + 1).toString().padLeft(2, '0'),
            eyebrow: rows[i].$1,
            title: rows[i].$2,
            titleAccent: rows[i].$3,
            body: rows[i].$4,
          ),
      ],
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({
    required this.stage,
    required this.eyebrow,
    required this.title,
    required this.titleAccent,
    required this.body,
  });

  final String stage;
  final String eyebrow;
  final String title;
  final String titleAccent;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final isMobile = context.isMobile;

    // Coluna do titulo: numero de stage em pixel + eyebrow pixel ciano +
    // titulo legivel com acento magenta.
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PixelText(stage, color: colors.primary, pixelSize: 3),
            const SizedBox(width: AppSpacing.sm),
            PixelText(eyebrow, color: colors.accent, pixelSize: 2),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text.rich(
          TextSpan(
            style: tt.titleMedium?.copyWith(
              color: colors.onSurface,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: '$title '),
              TextSpan(
                text: titleAccent,
                style: TextStyle(color: colors.primary),
              ),
            ],
          ),
        ),
      ],
    );

    final paragraph = Text(
      body,
      style: tt.bodyMedium?.copyWith(color: colors.onSurfaceMuted, height: 1.5),
    );

    // Changelog-row: padding vertical, hairline inferior neon, sem surface.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                heading,
                const SizedBox(height: AppSpacing.sm),
                paragraph,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 260, child: heading),
                const SizedBox(width: AppSpacing.xl),
                Expanded(child: paragraph),
              ],
            ),
    );
  }
}
