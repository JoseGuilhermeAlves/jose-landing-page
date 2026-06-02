import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
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

part 'aurora_history_widgets.dart';

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
      body: MockBodyConstraint(
        child: BlocBuilder<DeliveryBloc, DeliveryState>(
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
      ),
    );
  }
}
