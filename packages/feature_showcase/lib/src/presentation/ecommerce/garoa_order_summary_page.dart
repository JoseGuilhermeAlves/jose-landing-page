import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/domain/order_summary.dart';
import 'package:feature_showcase/src/domain/product.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_app_bar.dart';
import 'package:feature_showcase/src/presentation/ecommerce/garoa_brand.dart';
import 'package:flutter/material.dart';

/// Tela final do fluxo de compra Garoa — confirma o pedido com badge
/// animado de check, breakdown subtotal+frete+total, endereco mock e
/// ETA de entrega. CTA "Voltar a loja" desempilha ate a home (pop ate
/// `route.isFirst`).
class GaroaOrderSummaryPage extends StatelessWidget {
  const GaroaOrderSummaryPage({required this.order, super.key});

  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const GaroaAppBar(),
      body: SafeArea(
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
              const _ConfirmationBadge(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'pedido confirmado'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Obrigado pela visita.',
                key: const Key('garoa-order-confirmation-title'),
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
                'Recebemos seu pedido ${order.orderNumber}. '
                'Avisamos por e-mail quando o pacote sair da torra.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _SummaryCard(
                order: order,
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.lg),
              _AddressCard(
                order: order,
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.lg),
              _EtaCard(order: order, colors: colors, textTheme: textTheme),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                key: const Key('garoa-back-to-store'),
                label: 'Voltar a loja',
                icon: Icons.arrow_back_rounded,
                size: AppButtonSize.large,
                expand: true,
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selo circular animado com check — escala de 0 a 1 e gira o anel
/// externo num pulso curto. Confirmacao visual sem precisar do tom de
/// "sucesso" generico do Material.
class _ConfirmationBadge extends StatefulWidget {
  const _ConfirmationBadge();

  @override
  State<_ConfirmationBadge> createState() => _ConfirmationBadgeState();
}

class _ConfirmationBadgeState extends State<_ConfirmationBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RepaintBoundary(
      child: SizedBox(
        width: 96,
        height: 96,
        child: CustomPaint(
          painter: _ConfirmationBadgePainter(
            ringColor: colors.accent,
            checkColor: colors.onAccent,
            fillColor: colors.accent,
            // Passar o controller diretamente como `repaint` faz o
            // engine pular build e layout a cada tick e ir direto pro
            // paint — pratica recomendada para painters animados (ver
            // CLAUDE.md, secao "Custom Painters · Animacao").
            controller: _controller,
          ),
        ),
      ),
    );
  }
}

class _ConfirmationBadgePainter extends CustomPainter {
  _ConfirmationBadgePainter({
    required this.ringColor,
    required this.checkColor,
    required this.fillColor,
    required this.controller,
  }) : super(repaint: controller);

  final Color ringColor;
  final Color checkColor;
  final Color fillColor;
  final Animation<double> controller;

  late final Paint _ringPaint = Paint()
    ..color = ringColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  late final Paint _fillPaint = Paint()
    ..color = fillColor
    ..style = PaintingStyle.fill;

  late final Paint _checkPaint = Paint()
    ..color = checkColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final t = controller.value.clamp(0.0, 1.0);
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 6;

    // Pulso de escala 0 -> 1.05 -> 1.0 nos primeiros 60% da animacao.
    final scale = t < 0.6
        ? 1.05 * Curves.easeOutBack.transform(t / 0.6)
        : (1.05 - 0.05 * ((t - 0.6) / 0.4));

    canvas
      ..save()
      ..translate(cx, cy)
      ..scale(scale)
      ..translate(-cx, -cy)
      // Circulo interno preenchido.
      ..drawCircle(Offset(cx, cy), radius * 0.78, _fillPaint)
      ..drawCircle(Offset(cx, cy), radius, _ringPaint);

    // Check em duas linhas — desenha proporcional a t (entra do meio
    // pro fim da animacao). Path-clipping cresce de 0.4 -> 1.0.
    final checkProgress = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    if (checkProgress > 0) {
      final start = Offset(cx - radius * 0.35, cy + radius * 0.02);
      final mid = Offset(cx - radius * 0.05, cy + radius * 0.30);
      final end = Offset(cx + radius * 0.40, cy - radius * 0.25);
      if (checkProgress <= 0.5) {
        final p1 = Offset.lerp(start, mid, checkProgress / 0.5)!;
        canvas.drawLine(start, p1, _checkPaint);
      } else {
        canvas.drawLine(start, mid, _checkPaint);
        final p2 = Offset.lerp(mid, end, (checkProgress - 0.5) / 0.5)!;
        canvas.drawLine(mid, p2, _checkPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ConfirmationBadgePainter old) {
    // Re-render quando cores mudam; controller dispara repaint sozinho
    // via super(repaint: controller).
    return old.ringColor != ringColor ||
        old.checkColor != checkColor ||
        old.fillColor != fillColor;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final OrderSummary order;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pedido ${order.orderNumber}',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'pago',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.accent,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${order.itemsCount} ${order.itemsCount == 1 ? 'item' : 'itens'}',
            style: textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          _BreakdownRow(
            label: 'Subtotal',
            value: Product.formatBrl(order.subtotalCents),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _BreakdownRow(
            label: 'Frete',
            value: order.shippingCents == 0
                ? 'Gratis'
                : Product.formatBrl(order.shippingCents),
            colors: colors,
            textTheme: textTheme,
            valueColor: order.shippingCents == 0
                ? colors.accent
                : colors.onSurface,
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Text(
                'Total',
                style: textTheme.titleMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                Product.formatBrl(order.totalCents),
                key: const Key('garoa-order-total'),
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontFamily: GaroaBrand.displayFontFamily,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.valueColor,
  });

  final String label;
  final String value;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            color: valueColor ?? colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final OrderSummary order;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final addr = order.address;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Entrega para',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  addr.recipient,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${addr.street} · ${addr.neighborhood}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.4,
                  ),
                ),
                Text(
                  '${addr.city} · CEP ${addr.zip}',
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

class _EtaCard extends StatelessWidget {
  const _EtaCard({
    required this.order,
    required this.colors,
    required this.textTheme,
  });

  final OrderSummary order;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.local_shipping_outlined,
              color: colors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Previsao de entrega',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.etaLabel,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontFamily: GaroaBrand.displayFontFamily,
                    fontWeight: FontWeight.w600,
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
