import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// "Como eu entrego" — tres principios lado a lado (empilhados no mobile).
/// Cada coluna: filete superior neon, rotulo curto em caixa alta, titulo com
/// acento magenta e texto de apoio. Sem numeracao: sao principios, nao
/// etapas.
class DeliveryBlock extends StatelessWidget {
  const DeliveryBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final items = [
      (
        Icons.track_changes_rounded,
        l10n.delivery_entrega_eyebrow,
        l10n.delivery_entrega_title,
        l10n.delivery_entrega_titleAccent,
        l10n.delivery_entrega_body,
        colors.primary,
      ),
      (
        Icons.architecture_rounded,
        l10n.delivery_craft_eyebrow,
        l10n.delivery_craft_title,
        l10n.delivery_craft_titleAccent,
        l10n.delivery_craft_body,
        colors.accent,
      ),
      (
        Icons.diversity_3_rounded,
        l10n.delivery_collab_eyebrow,
        l10n.delivery_collab_title,
        l10n.delivery_collab_titleAccent,
        l10n.delivery_collab_body,
        colors.primary,
      ),
    ];

    final cards = [
      for (final it in items)
        _Principle(
          icon: it.$1,
          eyebrow: it.$2,
          title: it.$3,
          titleAccent: it.$4,
          body: it.$5,
          tint: it.$6,
        ),
    ];

    if (context.isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.xl),
            cards[i],
          ],
        ],
      );
    }
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.xl),
            Expanded(child: cards[i]),
          ],
        ],
      ),
    );
  }
}

class _Principle extends StatelessWidget {
  const _Principle({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.titleAccent,
    required this.body,
    required this.tint,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String titleAccent;
  final String body;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tint, width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: AppSpacing.sm),
              Text(
                eyebrow,
                style: tt.labelSmall?.copyWith(
                  color: tint,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text.rich(
            TextSpan(
              style: tt.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
                height: 1.3,
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
          const SizedBox(height: AppSpacing.md),
          Text(
            body,
            style: tt.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
