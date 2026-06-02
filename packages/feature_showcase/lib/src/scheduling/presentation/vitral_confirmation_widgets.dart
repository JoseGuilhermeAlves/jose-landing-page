part of 'vitral_confirmation_page.dart';

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.service,
    required this.specialistName,
    required this.specialistRole,
    required this.slot,
    required this.endsAt,
    required this.colors,
    required this.textTheme,
  });

  final Service service;
  final String? specialistName;
  final String? specialistRole;
  final DateTime slot;
  final DateTime endsAt;
  final AppColorScheme colors;
  final TextTheme textTheme;

  static const _weekdayNames = [
    '',
    'segunda',
    'terca',
    'quarta',
    'quinta',
    'sexta',
    'sabado',
    'domingo',
  ];

  static const _months = [
    '',
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];

  String _formatDate(DateTime d) {
    return '${_weekdayNames[d.weekday]}, '
        '${d.day.toString().padLeft(2, '0')} ${_months[d.month]}';
  }

  String _formatTime(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

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
          _Row(
            label: 'Servico',
            value: service.name,
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (specialistName != null) ...[
            _Row(
              label: 'Com',
              value: specialistName!,
              caption: specialistRole,
              colors: colors,
              textTheme: textTheme,
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          _Row(
            label: 'Data',
            value: _formatDate(slot),
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Horário',
            value: '${_formatTime(slot)} - ${_formatTime(endsAt)}',
            mono: true,
            colors: colors,
            textTheme: textTheme,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: 'Duração',
            value: service.formattedDuration,
            mono: true,
            colors: colors,
            textTheme: textTheme,
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
                service.formattedPrice,
                key: const Key('vitral-confirmation-total'),
                style: textTheme.headlineSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
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

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    required this.colors,
    required this.textTheme,
    this.caption,
    this.mono = false,
  });

  final String label;
  final String value;
  final String? caption;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 86,
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontFamily: mono ? VitralBrand.monoFontFamily : null,
                  fontWeight: FontWeight.w600,
                  letterSpacing: mono ? 0.4 : null,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.line,
    required this.colors,
    required this.textTheme,
  });

  final String line;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, color: colors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Onde',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
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
