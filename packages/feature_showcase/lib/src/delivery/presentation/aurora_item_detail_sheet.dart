import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/domain/market_item.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_product_illustration.dart';
import 'package:feature_showcase/src/shared/presentation/showcase_photo.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';

/// Sheet de detalhe de item do Aurora — foto grande, descricao longa,
/// preco por unidade e stepper de quantidade. O CTA "Adicionar" devolve
/// a quantidade escolhida via `Navigator.pop`, que o detalhe da banca
/// soma ao carrinho. Quando o cliente fecha sem confirmar, devolve null.
///
/// Quantidade inicial = qty atual no carrinho (ou 1 quando ainda nao
/// esta). Estado local com `setState` e legitimo aqui: e UI efemera de
/// um sheet, sem fluxo de eventos — fica fora da maquina do bloc.
class AuroraItemDetailSheet extends StatefulWidget {
  const AuroraItemDetailSheet({
    required this.item,
    required this.initialQuantity,
    super.key,
  });

  final MarketItem item;
  final int initialQuantity;

  /// Abre o sheet modal e devolve a quantidade escolhida (>= 1) quando o
  /// cliente confirma, ou null quando fecha sem adicionar.
  static Future<int?> show(
    BuildContext context, {
    required MarketItem item,
    required int initialQuantity,
  }) {
    final colors = context.colors;
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      barrierColor: colors.onSurface.withValues(alpha: 0.45),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => AuroraItemDetailSheet(
        item: item,
        initialQuantity: initialQuantity,
      ),
    );
  }

  @override
  State<AuroraItemDetailSheet> createState() => _AuroraItemDetailSheetState();
}

class _AuroraItemDetailSheetState extends State<AuroraItemDetailSheet> {
  late int _quantity = widget.initialQuantity < 1 ? 1 : widget.initialQuantity;

  void _increment() => setState(() => _quantity++);
  void _decrement() => setState(() {
    if (_quantity > 1) _quantity--;
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final description = item.description.isNotEmpty
        ? item.description
        : '${item.name} selecionado a dedo na banca, fresquinho pra '
              'entrega no mesmo dia.';

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: viewInsets),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grip do sheet.
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: ColoredBox(
                      color: colors.surfaceMuted,
                      child: ShowcasePhoto(
                        key: Key('aurora-item-photo-${item.id}'),
                        assetPath: item.photoAsset,
                        semanticLabel: item.name,
                        fallback: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: AuroraProductIllustration(
                            category: item.category,
                            foregroundColor: colors.primary,
                            accentColor: colors.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.formattedPrice,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceMuted,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Text(
                          'Quantidade',
                          style: textTheme.titleSmall?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        _SheetStepper(
                          quantity: _quantity,
                          onIncrement: _increment,
                          onDecrement: _decrement,
                          colors: colors,
                          textTheme: textTheme,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        key: const Key('aurora-item-sheet-add'),
                        label: 'Adicionar · '
                            '${formatBrl(item.priceCents * _quantity)}',
                        icon: Icons.add_shopping_cart_outlined,
                        size: AppButtonSize.large,
                        expand: true,
                        onPressed: () => Navigator.of(context).pop(_quantity),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetStepper extends StatelessWidget {
  const _SheetStepper({
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
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('aurora-item-sheet-decrement'),
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onDecrement,
                child: Icon(
                  Icons.remove_rounded,
                  color: quantity > 1 ? colors.onSurface : colors.onSurfaceMuted,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: const Key('aurora-item-sheet-increment'),
                borderRadius: BorderRadius.circular(AppRadius.md),
                onTap: onIncrement,
                child: Icon(Icons.add_rounded, color: colors.primary, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
