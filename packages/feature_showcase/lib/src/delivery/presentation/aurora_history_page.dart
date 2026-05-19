import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/data/aurora_vendors_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_app_bar.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_navigation.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_order_detail_page.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_product_illustration.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_state.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Historico de pedidos — lista os pedidos com status `delivered`,
/// preservando vendor + total + data. Tap reabre o detalhe (read-only
/// na pratica porque o status nao avanca depois de `delivered`).
class AuroraHistoryPage extends StatelessWidget {
  const AuroraHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AuroraAppBar(),
      body: BlocBuilder<DeliveryBloc, DeliveryState>(
        builder: (context, state) {
          final history = state.historyOrders;
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'historico'.toUpperCase(),
                    style: textTheme.labelSmall?.copyWith(
                      color: colors.accent,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Pedidos anteriores',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colors.onSurface,
                      fontFamily: AuroraBrand.displayFontFamily,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (history.isEmpty)
                    _EmptyState(colors: colors, textTheme: textTheme)
                  else
                    for (var i = 0; i < history.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      _HistoryCard(
                        order: history[i],
                        colors: colors,
                        textTheme: textTheme,
                      ),
                    ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
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
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: Key('aurora-history-card-${order.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => auroraWithDemoBloc(
              context,
              AuroraOrderDetailPage(orderId: order.id),
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
              if (vendor != null)
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
              if (vendor != null) const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor?.name ?? order.customerName,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      order.placedAtLabel.isEmpty
                          ? '${order.lineItems.length} itens'
                          : '${order.placedAtLabel} · ${order.lineItems.length} itens',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceMuted,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatBrl(_safeTotal(order)),
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      order.status.label.toLowerCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.primary,
                        letterSpacing: 0.4,
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

  static double _safeTotal(DeliveryOrder o) {
    if (o.totalCents > 0) return o.totalCents;
    return o.lineItems.fold<double>(0, (acc, l) => acc + l.subtotalCents);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, color: colors.onSurfaceMuted, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sem pedidos anteriores ainda.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}
