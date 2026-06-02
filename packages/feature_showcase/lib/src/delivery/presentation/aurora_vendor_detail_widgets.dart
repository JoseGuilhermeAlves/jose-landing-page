part of 'aurora_vendor_detail_page.dart';

class _VendorHeader extends StatelessWidget {
  const _VendorHeader({
    required this.vendor,
    required this.colors,
    required this.textTheme,
  });

  final Vendor vendor;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: AuroraProductIllustration(
              category: vendor.primaryCategory,
              foregroundColor: colors.primary,
              accentColor: colors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vendor.name,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontFamily: AuroraBrand.displayFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  vendor.tagline,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 12,
                      color: colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${vendor.etaMinutes} min',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      Icons.local_shipping_outlined,
                      size: 12,
                      color: colors.onSurfaceMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vendor.formattedDeliveryFee,
                      style: textTheme.labelSmall?.copyWith(
                        color: vendor.deliveryFeeCents == 0
                            ? colors.primary
                            : colors.onSurfaceMuted,
                        fontWeight: vendor.deliveryFeeCents == 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(Icons.star_rounded, size: 12, color: colors.accent),
                    const SizedBox(width: 2),
                    Text(
                      vendor.rating.toStringAsFixed(1),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.item,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.colors,
    required this.textTheme,
  });

  final MarketItem item;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final inCart = quantity > 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: inCart ? colors.primary.withValues(alpha: 0.4) : colors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: context.responsive<double>(mobile: 40, desktop: 48),
            height: context.responsive<double>(mobile: 40, desktop: 48),
            decoration: BoxDecoration(
              color: colors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: AuroraProductIllustration(
              category: item.category,
              foregroundColor: colors.primary,
              accentColor: colors.accent,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 0,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.formattedPrice,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QtyStepper(
            quantity: quantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    required this.colors,
    required this.textTheme,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return SizedBox(
        width: 36,
        height: 36,
        child: Material(
          color: colors.primary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            key: const Key('aurora-add-item'),
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onIncrement,
            child: Icon(Icons.add_rounded, color: colors.onPrimary, size: 20),
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onDecrement,
                child: Icon(
                  Icons.remove_rounded,
                  color: colors.onSurface,
                  size: 18,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onIncrement,
                child: Icon(Icons.add_rounded, color: colors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.totalItems,
    required this.subtotalCents,
    required this.deliveryFeeCents,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final int totalItems;
  final double subtotalCents;
  final double deliveryFeeCents;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final totalCents = subtotalCents + deliveryFeeCents;
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 8,
      shadowColor: colors.primary.withValues(alpha: 0.4),
      child: InkWell(
        key: const Key('aurora-cart-bar'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  '$totalItems',
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Fazer pedido',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                formatBrl(totalCents),
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
