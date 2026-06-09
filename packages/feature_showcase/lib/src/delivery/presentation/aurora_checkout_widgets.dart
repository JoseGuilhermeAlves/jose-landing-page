part of 'aurora_checkout_page.dart';

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  final String label;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.titleMedium?.copyWith(
        color: colors.onSurface,
        fontFamily: AuroraBrand.displayFontFamily,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Tile selecionavel base — borda/realce em primary quando marcado, com
/// um radio a esquerda. Usado por endereco e pagamento.
class _SelectableTile extends StatelessWidget {
  const _SelectableTile({
    required this.selected,
    required this.onTap,
    required this.leading,
    required this.child,
    required this.colors,
    this.tileKey,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget leading;
  final Widget child;
  final AppColorScheme colors;
  final Key? tileKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: auroraCardFill(colors),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: tileKey,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: auroraCardShadow(colors),
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: selected ? colors.primary : colors.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: AppSpacing.md),
                Expanded(child: child),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected ? colors.primary : colors.onSurfaceMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryAddress address;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return _SelectableTile(
      tileKey: Key('aurora-checkout-address-${address.id}'),
      selected: selected,
      onTap: onTap,
      colors: colors,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.place_outlined, size: 18, color: colors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.label,
            style: textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address.oneLine,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.method,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;

  IconData get _icon => switch (method.kind) {
    PaymentKind.creditCard => Icons.credit_card,
    PaymentKind.pix => Icons.qr_code_2,
    PaymentKind.cashOnDelivery => Icons.payments_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return _SelectableTile(
      tileKey: Key('aurora-checkout-payment-${method.id}'),
      selected: selected,
      onTap: onTap,
      colors: colors,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        alignment: Alignment.center,
        child: Icon(_icon, size: 18, color: colors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            method.label,
            style: textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            method.detail,
            style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

/// Picker de observacao — chips selecionaveis (1 ativo por vez,
/// togglavel). Evita campo de texto livre num mock, mantendo o gesto
/// tátil. "Sem observação" reseta pra null.
class _NotesPicker extends StatelessWidget {
  const _NotesPicker({
    required this.selectedIndex,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  final int? selectedIndex;
  final ValueChanged<int?> onChanged;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    const suggestions = AuroraCheckoutCatalog.noteSuggestions;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _NoteChip(
          label: 'Sem observação',
          selected: selectedIndex == null,
          onTap: () => onChanged(null),
          colors: colors,
          textTheme: textTheme,
          chipKey: const Key('aurora-checkout-note-none'),
        ),
        for (var i = 0; i < suggestions.length; i++)
          _NoteChip(
            label: suggestions[i],
            selected: selectedIndex == i,
            onTap: () => onChanged(selectedIndex == i ? null : i),
            colors: colors,
            textTheme: textTheme,
            chipKey: Key('aurora-checkout-note-$i'),
          ),
      ],
    );
  }
}

class _NoteChip extends StatelessWidget {
  const _NoteChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
    required this.chipKey,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final Key chipKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : auroraCardFill(colors),
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        key: chipKey,
        borderRadius: BorderRadius.circular(AppRadius.full),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: selected ? colors.primary : colors.border,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.lines,
    required this.subtotalCents,
    required this.deliveryFeeCents,
    required this.totalCents,
    required this.colors,
    required this.textTheme,
  });

  final List<_CheckoutLine> lines;
  final double subtotalCents;
  final double deliveryFeeCents;
  final double totalCents;
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
      child: Column(
        children: [
          for (final line in lines) ...[
            Row(
              children: [
                Text(
                  '${line.quantity}×',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    line.item.name,
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
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          Divider(color: colors.border, height: AppSpacing.md),
          _SummaryRow(
            label: 'Subtotal',
            value: formatBrl(subtotalCents),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.xs),
          _SummaryRow(
            label: 'Frete',
            value: deliveryFeeCents == 0 ? 'Grátis' : formatBrl(deliveryFeeCents),
            valueColor: deliveryFeeCents == 0 ? colors.primary : null,
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(color: colors.border, height: 1),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Total',
            value: formatBrl(totalCents),
            bold: true,
            colors: colors,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
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

/// Barra fixa de confirmacao — total + CTA "Confirmar pedido".
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({
    required this.totalCents,
    required this.onConfirm,
    required this.colors,
    required this.textTheme,
  });

  final double totalCents;
  final VoidCallback onConfirm;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.primary,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 8,
      shadowColor: colors.primary.withValues(alpha: 0.4),
      child: InkWell(
        key: const Key('aurora-checkout-confirm'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onConfirm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.8),
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      formatBrl(totalCents),
                      style: textTheme.titleMedium?.copyWith(
                        color: colors.onPrimary,
                        fontFamily: AuroraBrand.displayFontFamily,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Confirmar pedido',
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: colors.onPrimary,
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
