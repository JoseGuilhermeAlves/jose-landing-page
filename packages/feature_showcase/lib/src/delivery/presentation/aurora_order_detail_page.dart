import 'package:design_system/design_system.dart';
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
      body: BlocBuilder<DeliveryBloc, DeliveryState>(
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
                  // Mapa — destaque tecnico no topo.
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: const AuroraDeliveryMap(height: 220),
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
                    'Onde esta seu pedido',
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
                    'Itens',
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
    );
  }
}

class _VendorHeader extends StatelessWidget {
  const _VendorHeader({
    required this.order,
    required this.vendor,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryOrder order;
  final Vendor? vendor;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              category: vendor!.primaryCategory,
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
                'PEDIDO ${order.id}',
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                vendor?.name ?? order.customerName,
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.onSurface,
                  fontFamily: AuroraBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
              if (vendor != null) ...[
                const SizedBox(height: 2),
                Text(
                  vendor!.tagline,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
              ],
              if (order.placedAtLabel.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  order.placedAtLabel,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryEtaCard extends StatelessWidget {
  const _DeliveryEtaCard({
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryOrder order;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final isDelivered = order.status == DeliveryStatus.delivered;
    final isCancelled = order.status == DeliveryStatus.cancelled;
    final accent = isCancelled
        ? colors.onSurfaceMuted
        : colors.primary;
    final iconData = isCancelled
        ? Icons.cancel_outlined
        : isDelivered
            ? Icons.check_circle_outline
            : Icons.location_on_outlined;
    final headline = isCancelled
        ? 'Pedido cancelado'
        : isDelivered
            ? 'Entregue em'
            : order.etaMinutes > 0
                ? 'Chega em ~${order.etaMinutes} min'
                : 'A caminho';

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(iconData, color: accent, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  headline,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontFamily: AuroraBrand.displayFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.addressLine.isEmpty
                      ? 'Endereco nao informado'
                      : order.addressLine,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.4,
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

/// Botao "Cancelar pedido" exibido quando o pedido ainda nao foi
/// entregue. Abre dialog de confirmacao — evita cancel acidental por
/// tap. Confirmacao dispara `DeliveryOrderCancelled` no bloc.
class _CancelOrderButton extends StatelessWidget {
  const _CancelOrderButton({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        key: const Key('aurora-cancel-order-cta'),
        label: 'Cancelar pedido',
        variant: AppButtonVariant.ghost,
        icon: Icons.cancel_outlined,
        expand: true,
        onPressed: () => _confirm(context),
      ),
    );
  }

  Future<void> _confirm(BuildContext context) async {
    final bloc = context.read<DeliveryBloc>();
    final colors = context.colors;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancelar este pedido?'),
        content: Text(
          'O pedido ${order.id} sera marcado como cancelado e movido '
          'pro historico.',
          style: TextStyle(color: colors.onSurfaceMuted),
        ),
        actions: [
          TextButton(
            key: const Key('aurora-cancel-dialog-back'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Voltar'),
          ),
          TextButton(
            key: const Key('aurora-cancel-dialog-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      bloc.add(DeliveryOrderCancelled(order.id));
    }
  }
}

/// Banner exibido quando o pedido foi cancelado — substitui a timeline
/// vertical (que assume fluxo linear) por um aviso terminal.
class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.colors, required this.textTheme});

  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('aurora-cancelled-banner'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colors.onSurfaceMuted.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.block_rounded,
            color: colors.onSurfaceMuted,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido cancelado',
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A banca foi avisada e o cartao nao sera cobrado.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.4,
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

class _ItemsList extends StatelessWidget {
  const _ItemsList({
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryOrder order;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    if (order.lineItems.isEmpty) {
      return Text(
        'Sem detalhamento de itens neste pedido.',
        style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < order.lineItems.length; i++) ...[
          if (i > 0)
            Divider(
              color: colors.border,
              height: AppSpacing.lg,
            ),
          _ItemRow(
            line: order.lineItems[i],
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ],
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.line,
    required this.colors,
    required this.textTheme,
  });

  final OrderLineItem line;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final qtyLabel = line.quantity == line.quantity.roundToDouble()
        ? '${line.quantity.toInt()}'
        : line.quantity.toStringAsFixed(2);

    return Row(
      key: const Key('aurora-order-item-row'),
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: colors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          alignment: Alignment.center,
          child: Text(
            '$qtyLabel ${line.unitShort}',
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            line.name,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
            ),
          ),
        ),
        Text(
          formatBrl(line.subtotalCents),
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({
    required this.order,
    required this.vendor,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryOrder order;
  final Vendor? vendor;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final itemsTotal = order.lineItems.fold<double>(
      0,
      (acc, l) => acc + l.subtotalCents,
    );
    final fee = vendor?.deliveryFeeCents ?? 0;
    final total = order.totalCents > 0
        ? order.totalCents
        : itemsTotal + fee;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _Row(
            label: 'Subtotal',
            value: formatBrl(itemsTotal),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label: 'Frete',
            value: fee == 0 ? 'Gratis' : formatBrl(fee),
            colors: colors,
            textTheme: textTheme,
            valueColor: fee == 0 ? colors.primary : colors.onSurface,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Total',
            value: formatBrl(total),
            colors: colors,
            textTheme: textTheme,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: (bold ? textTheme.titleMedium : textTheme.bodyMedium)?.copyWith(
            color: bold ? colors.onSurface : colors.onSurfaceMuted,
            fontWeight: bold ? FontWeight.w700 : null,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: (bold ? textTheme.titleLarge : textTheme.bodyMedium)?.copyWith(
            color: valueColor ?? (bold ? colors.primary : colors.onSurface),
            fontFamily: bold ? AuroraBrand.displayFontFamily : null,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.colors, required this.textTheme});
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: colors.onSurfaceMuted),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Pedido nao encontrado.',
              style: textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
