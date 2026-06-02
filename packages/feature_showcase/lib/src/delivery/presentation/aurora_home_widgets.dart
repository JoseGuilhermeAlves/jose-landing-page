part of 'aurora_home_page.dart';

// =============================================================================
// HERO
// =============================================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.surfaceMuted, colors.surface],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            Positioned.fill(
              child: AuroraHeroBackdrop(
                waveColor: colors.primary,
                leafColor: colors.accent.withValues(alpha: 0.50),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(
                context.responsive(
                  mobile: AppSpacing.lg,
                  desktop: AppSpacing.xl,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      context.l10n.aurora_heroTag,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    AuroraBrand.tagline,
                    style: context
                        .responsive(
                          mobile: textTheme.headlineMedium,
                          desktop: textTheme.displaySmall,
                        )
                        ?.copyWith(
                          color: colors.onSurface,
                          fontFamily: AuroraBrand.displayFontFamily,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.aurora_heroSubtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppButton(
                    key: const Key('aurora-cta-stores'),
                    label: 'Ver bancas',
                    icon: Icons.storefront_outlined,
                    size: AppButtonSize.large,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => auroraWithDemoBloc(
                          context,
                          const AuroraStoreListPage(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// PEDIDO ATIVO
// =============================================================================

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryOrder order;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final vendor = AuroraVendorsCatalog.byId(order.vendorId);
    return Container(
      key: const Key('aurora-active-order-card'),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.10),
            blurRadius: 28,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Column(
          children: [
            // Mini-mapa em altura reduzida — destaca o tracking.
            AuroraDeliveryMap(height: context.isMobile ? 104 : 140),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          order.status.label.toLowerCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        order.etaMinutes > 0
                            ? '~ ${order.etaMinutes} min'
                            : 'a caminho',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    vendor?.name ?? order.customerName,
                    style: textTheme.titleLarge?.copyWith(
                      color: colors.onSurface,
                      fontFamily: AuroraBrand.displayFontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${order.lineItems.length} '
                    '${order.lineItems.length == 1 ? 'item' : 'itens'} '
                    '· ${order.addressLine}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      key: const Key('aurora-active-order-cta'),
                      label: 'Acompanhar pedido',
                      icon: Icons.location_on_outlined,
                      expand: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => auroraWithDemoBloc(
                            context,
                            AuroraOrderDetailPage(orderId: order.id),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveOrderCard extends StatelessWidget {
  const _NoActiveOrderCard({required this.colors, required this.textTheme});
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
          Icon(Icons.inbox_outlined, color: colors.onSurfaceMuted, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum pedido em andamento',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Escolha uma banca pra comecar.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CATEGORIAS
// =============================================================================

class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          for (var i = 0; i < MarketCategory.values.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            _CategoryChip(
              category: MarketCategory.values[i],
              colors: colors,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.colors,
    required this.textTheme,
  });

  final MarketCategory category;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        key: Key('aurora-category-${category.name}'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => auroraWithDemoBloc(
              context,
              AuroraStoreListPage(initialCategory: category),
            ),
          ),
        ),
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: AuroraCategoryIcon(
                  category: category,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                category.label,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontFamily: AuroraBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                category.description,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// VENDORS
// =============================================================================

class _VendorsList extends StatelessWidget {
  const _VendorsList({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final vendors = AuroraVendorsCatalog.all.take(4).toList();
    return Column(
      children: [
        for (var i = 0; i < vendors.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          AuroraVendorCard(vendor: vendors[i]),
        ],
      ],
    );
  }
}

/// Card de banca reutilizado pela home e pela lista de lojas. Mostra
/// ilustracao da categoria principal + nome + tagline + ETA + frete.
/// Tap empurra a lista de lojas com a categoria selecionada (proxy pro
/// detalhe sem flow completo de produto).
class AuroraVendorCard extends StatelessWidget {
  const AuroraVendorCard({required this.vendor, this.onTap, super.key});

  final Vendor vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: Key('aurora-vendor-card-${vendor.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap:
            onTap ??
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => auroraWithDemoBloc(
                  context,
                  AuroraStoreListPage(initialCategory: vendor.primaryCategory),
                ),
              ),
            ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
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
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vendor.tagline,
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 0,
                        height: 1.35,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.onSurfaceMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SOBRE
// =============================================================================

class _AboutBlock extends StatelessWidget {
  const _AboutBlock({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sobre a Aurora',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontFamily: AuroraBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Conectamos bancas e padarias de bairro com voce. Pedido pela '
            'manha vira entrega no almoco. Sem CD intermediario, sem '
            'paracetamol pra produto que ja parou na prateleira.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
