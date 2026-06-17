part of 'aurora_home_page.dart';

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
            AuroraDeliveryMap(
              height: context.isMobile ? 104 : 140,
              status: order.status,
              etaMinutes: order.etaMinutes,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Container(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelSmall?.copyWith(
                              color: colors.primary,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
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
        color: auroraCardFill(colors),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
        boxShadow: auroraCardShadow(colors),
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

/// Pill de categoria do strip da home. Mesma gramatica visual do
/// `_Chip` da lista de bancas (pill arredondada + icone + label) pra
/// unificar a taxonomia entre as duas telas. O glifo da categoria sai
/// em ocre accent — promove a terceira cor da paleta, que antes so
/// aparecia no mapa.
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
      color: auroraCardFill(colors),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        key: Key('aurora-category-${category.name}'),
        borderRadius: BorderRadius.circular(AppRadius.full),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => auroraWithDemoBloc(
              context,
              AuroraStoreListPage(initialCategory: category),
            ),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: auroraCardShadow(colors),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AuroraCategoryIcon(
                  category: category,
                  color: colors.accent,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  category.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

/// Card de banca reutilizado pela home e pela lista de lojas. Lidera
/// com um banner de foto da banca (`ShowcasePhoto`, cai na
/// `AuroraProductIllustration` enquanto o `.webp` nao existe), nome +
/// tagline sobre o banner e uma faixa inferior com ETA + frete +
/// rating. Tap (default) abre o detalhe da banca com produtos e
/// carrinho — o mesmo destino da lista de lojas. Quem precisar de outro
/// destino passa `onTap` explicito.
class AuroraVendorCard extends StatelessWidget {
  const AuroraVendorCard({required this.vendor, this.onTap, super.key});

  final Vendor vendor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: auroraCardFill(colors),
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
                  AuroraVendorDetailPage(vendor: vendor),
                ),
              ),
            ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: auroraCardShadow(colors),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AuroraVendorBanner(vendor: vendor, colors: colors),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 13,
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
                          size: 13,
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
                        const Spacer(),
                        Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          vendor.rating.toStringAsFixed(1),
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Banner superior do card de banca — foto real (`ShowcasePhoto`) com
/// nome + tagline em overlay sobre um scrim escuro. Cai na
/// `AuroraProductIllustration` da categoria principal enquanto o
/// `.webp` nao existe, entao o painter continua como rede de seguranca.
class AuroraVendorBanner extends StatelessWidget {
  const AuroraVendorBanner({
    required this.vendor,
    required this.colors,
    super.key,
  });

  final Vendor vendor;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AspectRatio(
      aspectRatio: context.responsive(mobile: 2.6, desktop: 3),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: colors.surfaceMuted,
            child: ShowcasePhoto(
              key: Key('aurora-vendor-photo-${vendor.id}'),
              assetPath: vendor.photoAsset,
              semanticLabel: 'Banca ${vendor.name}',
              fallback: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AuroraProductIllustration(
                  category: vendor.primaryCategory,
                  foregroundColor: colors.primary,
                  accentColor: colors.accent,
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black54,
                ],
                stops: [0, 0.45, 1],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.sm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vendor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontFamily: AuroraBrand.displayFontFamily,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(blurRadius: 8, color: Colors.black54),
                    ],
                  ),
                ),
                Text(
                  vendor.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    letterSpacing: 0,
                    height: 1.3,
                    shadows: const [
                      Shadow(blurRadius: 6, color: Colors.black54),
                    ],
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
            style: context
                .responsive(
                  mobile: textTheme.bodySmall,
                  desktop: textTheme.bodyMedium,
                )
                ?.copyWith(color: colors.onSurfaceMuted, height: 1.55),
          ),
        ],
      ),
    );
  }
}
