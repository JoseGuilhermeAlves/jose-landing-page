import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/ecommerce/data/products_catalog.dart';
import 'package:feature_showcase/src/ecommerce/domain/product.dart';
import 'package:feature_showcase/src/ecommerce/domain/product_category.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_bloc.dart';
import 'package:feature_showcase/src/ecommerce/presentation/cart_event.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_app_bar.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_brand.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_catalog_page.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_category_icon.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_hero_backdrop.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_navigation.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_product_detail_page.dart';
import 'package:feature_showcase/src/ecommerce/presentation/garoa_product_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Home da marca Garoa — primeira tela do demo de e-commerce. Composta
/// por hero da marca (backdrop animado de graos + vapor), strip de
/// categorias com glifos desenhados e grid de produtos em destaque.
/// CTA "Explorar catalogo" empurra a [GaroaCatalogPage].
class GaroaHomePage extends StatelessWidget {
  const GaroaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: GaroaAppBar(
        leading: IconButton(
          key: const Key('garoa-close-demo'),
          tooltip: 'Fechar demo',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroCard(colors: colors, textTheme: textTheme),
              const SizedBox(height: AppSpacing.xl),
              _CategoriesStrip(colors: colors, textTheme: textTheme),
              const SizedBox(height: AppSpacing.xl),
              _SectionLabel(
                eyebrow: 'Em destaque',
                title: 'Pelos torrefadores',
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.md),
              const _FeaturedGrid(),
              const SizedBox(height: AppSpacing.xxl),
              _AboutBlock(colors: colors, textTheme: textTheme),
            ],
          ),
        ),
      ),
    );
  }
}

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
              child: GaroaHeroBackdrop(
                beanColor: colors.primary.withValues(alpha: 0.12),
                steamColor: colors.accent.withValues(alpha: 0.35),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
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
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'cafe-livraria · sao paulo',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    GaroaBrand.tagline,
                    style: textTheme.displaySmall?.copyWith(
                      color: colors.onSurface,
                      fontFamily: GaroaBrand.displayFontFamily,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cafe de torra propria, livros que cabem na pausa e '
                    'objetos pra uma mesa que respeita o ritual.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      AppButton(
                        key: const Key('garoa-cta-catalog'),
                        label: 'Explorar catalogo',
                        icon: Icons.arrow_forward_rounded,
                        size: AppButtonSize.large,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => garoaWithDemoBloc(
                              context,
                              const GaroaCatalogPage(),
                            ),
                          ),
                        ),
                      ),
                    ],
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
// CATEGORIAS
// =============================================================================

class _CategoriesStrip extends StatelessWidget {
  const _CategoriesStrip({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          eyebrow: 'Categorias',
          title: 'Por onde comecar',
          colors: colors,
          textTheme: textTheme,
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          // Pequeno padding lateral pra sombra do primeiro/ultimo card
          // nao colar nas bordas do scroll.
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              for (var i = 0; i < ProductCategory.values.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.sm),
                _CategoryCard(
                  category: ProductCategory.values[i],
                  colors: colors,
                  textTheme: textTheme,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.colors,
    required this.textTheme,
  });

  final ProductCategory category;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        key: Key('garoa-category-${category.name}'),
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => garoaWithDemoBloc(
              context,
              GaroaCatalogPage(initialCategory: category),
            ),
          ),
        ),
        child: Container(
          width: 160,
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
                child: GaroaCategoryIcon(
                  category: category,
                  color: colors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                category.label,
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
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
// FEATURED GRID
// =============================================================================

class _FeaturedGrid extends StatelessWidget {
  const _FeaturedGrid();

  int _columnsFor(Breakpoint bp) => switch (bp) {
        Breakpoint.mobile => 2,
        Breakpoint.tablet => 3,
        Breakpoint.desktop || Breakpoint.wide => 4,
      };

  @override
  Widget build(BuildContext context) {
    final columns = _columnsFor(context.breakpoint);
    final featured = ProductsCatalog.featured;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        final cardWidth =
            (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final p in featured)
              SizedBox(
                width: cardWidth,
                child: GaroaProductCard(product: p),
              ),
          ],
        );
      },
    );
  }
}

/// Card de produto reutilizado pela home e pelo catalogo. Ilustracao
/// via painter, nome em serif, subtitle e preco. Tap abre o detalhe.
class GaroaProductCard extends StatelessWidget {
  const GaroaProductCard({required this.product, super.key});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: const Key('ecommerce-product-card'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => garoaWithDemoBloc(
              context,
              GaroaProductDetailPage(product: product),
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.1,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GaroaProductIllustration(
                    category: product.category,
                    foregroundColor: colors.primary,
                    accentColor: colors.accent,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                product.category.label,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.name,
                style: textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                product.subtitle,
                style: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.formattedPrice,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('ecommerce-add-button'),
                    tooltip: 'Adicionar ao carrinho',
                    onPressed: () => context
                        .read<CartBloc>()
                        .add(CartAddProduct(product)),
                    icon: Icon(Icons.add_rounded, color: colors.primary),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// SOBRE A MARCA
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
            'Sobre a Garoa',
            style: textTheme.titleMedium?.copyWith(
              color: colors.onSurface,
              fontFamily: GaroaBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Abrimos em 2019 num sobrado de esquina, com um lance de '
            'cafes especiais e prateleira de livros pequenos. Hoje '
            'distribuimos pra todo o Brasil — moemos por encomenda e '
            'fechamos os pacotes na semana do envio.',
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.eyebrow,
    required this.title,
    required this.colors,
    required this.textTheme,
  });

  final String eyebrow;
  final String title;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: textTheme.labelSmall?.copyWith(
            color: colors.accent,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colors.onSurface,
            fontFamily: GaroaBrand.displayFontFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
