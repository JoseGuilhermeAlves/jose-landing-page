import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/delivery_orders_catalog.dart';
import 'package:feature_showcase/src/domain/delivery_order.dart';
import 'package:feature_showcase/src/domain/delivery_status.dart';
import 'package:feature_showcase/src/presentation/delivery/delivery_bloc.dart';
import 'package:feature_showcase/src/presentation/delivery/delivery_event.dart';
import 'package:feature_showcase/src/presentation/delivery/delivery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tela do mock de delivery — lista de pedidos com status que avanca
/// progressivamente via ticker. Em produto real, substituiriamos o
/// ticker por um stream do backend.
class DeliveryDemo extends StatelessWidget {
  const DeliveryDemo({this.ticker, super.key});

  /// Stream de ticks. Em producao, o widget host normalmente passa
  /// um `Stream.periodic(Duration(seconds: 2))`. Em testes, um
  /// `StreamController` controla cada tick.
  final Stream<void>? ticker;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => DeliveryBloc(
        initialOrders: DeliveryOrdersCatalog.all,
        ticker: ticker,
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              title: Text('Pedidos ao vivo', style: textTheme.titleLarge),
              actions: [
                IconButton(
                  key: const Key('delivery-reset-button'),
                  tooltip: 'Reiniciar',
                  icon: const Icon(Icons.refresh),
                  onPressed: () =>
                      context.read<DeliveryBloc>().add(const DeliveryReset()),
                ),
              ],
            ),
            body: const _OrdersList(),
          );
        },
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList();

  @override
  Widget build(BuildContext context) {
    // Lista pequena e fixa — usar SingleChildScrollView+Column garante
    // que o tester veja todos os cards mesmo offscreen, sem precisar
    // scrollar. Em produto real, lista longa pediria ListView.builder.
    return BlocBuilder<DeliveryBloc, DeliveryState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              for (var i = 0; i < state.orders.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                _OrderCard(order: state.orders[i]),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      key: const Key('delivery-order-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.id,
                style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '· ${order.customerName}',
                style: textTheme.titleSmall
                    ?.copyWith(color: colors.onSurfaceMuted),
              ),
              const Spacer(),
              _EtaChip(etaMinutes: order.etaMinutes, status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${order.items} ${order.items == 1 ? 'item' : 'itens'}',
            style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceMuted),
          ),
          const SizedBox(height: AppSpacing.md),
          _StatusStepper(status: order.status),
          const SizedBox(height: AppSpacing.sm),
          AnimatedSwitcher(
            duration: AppDuration.base,
            child: Text(
              order.status.label,
              key: ValueKey(order.status),
              style: textTheme.titleSmall?.copyWith(
                color: order.status.isFinal
                    ? colors.success
                    : colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EtaChip extends StatelessWidget {
  const _EtaChip({required this.etaMinutes, required this.status});

  final int etaMinutes;
  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    if (status.isFinal) {
      return _Chip(
        label: 'Entregue',
        icon: Icons.check_circle_outline,
        color: colors.success,
      );
    }

    return _Chip(
      label: '~ $etaMinutes min',
      icon: Icons.schedule,
      color: colors.onSurfaceMuted,
      textStyle: textTheme.labelSmall,
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.icon,
    required this.color,
    this.textStyle,
  });

  final String label;
  final IconData icon;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final defaultStyle = Theme.of(context).textTheme.labelSmall;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: (textStyle ?? defaultStyle)?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.status});

  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const all = DeliveryStatus.values;
    final activeIndex = all.indexOf(status);

    return Row(
      children: [
        for (var i = 0; i < all.length; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: AppDuration.base,
              curve: AppCurves.standard,
              height: 4,
              decoration: BoxDecoration(
                color: i <= activeIndex ? colors.primary : colors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          if (i < all.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
