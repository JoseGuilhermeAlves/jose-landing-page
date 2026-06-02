import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/delivery/data/aurora_vendors_catalog.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_status.dart';
import 'package:feature_showcase/src/delivery/domain/vendor.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_app_bar.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_brand.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_delivery_map.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_product_illustration.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_status_timeline.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_bloc.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_event.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_state.dart';
import 'package:feature_showcase/src/shared/util/money_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'aurora_order_detail_widgets.dart';

/// Detalhe do pedido — destaque tecnico do mock Aurora. Composta por:
/// - mapa abstrato com rota animada (`AuroraDeliveryMap`, painter
///   dedicado);
/// - header do vendor (banca) + endereco de entrega;
/// - timeline vertical de 4 passos com check progressivo
///   (`AuroraStatusTimeline`);
/// - lista de itens com ilustracao por categoria, qty e subtotal;
/// - sumario de totais (subtotal + frete + total).
///
/// Recebe `orderId` por construtor e busca o pedido no `DeliveryBloc`
/// em tempo real — assim o status acompanha o ticker quando aberto via
/// pedido ativo.
class AuroraOrderDetailPage extends StatelessWidget {
  const AuroraOrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AuroraAppBar(),
      body: MockBodyConstraint(
        child: BlocBuilder<DeliveryBloc, DeliveryState>(
          builder: (context, state) {
            final order = state.findById(orderId);
            if (order == null) {
              return _NotFound(colors: colors, textTheme: textTheme);
            }
            final vendor = AuroraVendorsCatalog.byId(order.vendorId);
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: Stack(
                        children: [
                          AuroraDeliveryMap(
                            height: context.isMobile ? 150 : 220,
                          ),
                          Positioned(
                            left: AppSpacing.sm,
                            bottom: AppSpacing.sm,
                            child: _MapDisclaimer(colors: colors),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _VendorHeader(
                      order: order,
                      vendor: vendor,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _DeliveryEtaCard(
                      order: order,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      context.l10n.aurora_orderTimelineTitle,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (order.status == DeliveryStatus.cancelled)
                      _CancelledBanner(colors: colors, textTheme: textTheme)
                    else ...[
                      AuroraStatusTimeline(activeStatus: order.status),
                      const SizedBox(height: AppSpacing.lg),
                      _CancelOrderButton(order: order),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      context.l10n.aurora_orderItemsTitle,
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ItemsList(
                      order: order,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _TotalsCard(
                      order: order,
                      vendor: vendor,
                      colors: colors,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
