import 'package:design_system/src/l10n/l10n_extension.dart';
import 'package:design_system/src/spacing/app_spacing.dart';
import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/tokens/app_duration.dart';
import 'package:design_system/src/tokens/app_radius.dart';
import 'package:design_system/src/widgets/flags/flag_icon.dart';
import 'package:flutter/material.dart';

class LocaleSwitcher extends StatelessWidget {
  const LocaleSwitcher({
    required this.currentLocale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  static const _locales = [
    Locale('pt'),
    Locale('en'),
    Locale('es'),
    Locale('de'),
    Locale('zh'),
    Locale('ja'),
    Locale('it'),
  ];

  String _localeName(BuildContext context, Locale locale) {
    final l10n = context.l10n;
    return switch (locale.languageCode) {
      'pt' => l10n.locale_pt,
      'en' => l10n.locale_en,
      'es' => l10n.locale_es,
      'de' => l10n.locale_de,
      'zh' => l10n.locale_zh,
      'ja' => l10n.locale_ja,
      'it' => l10n.locale_it,
      _ => locale.languageCode.toUpperCase(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<Locale>(
      onSelected: onLocaleChanged,
      offset: const Offset(0, kToolbarHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(color: colors.border),
      ),
      color: colors.surface,
      tooltip: _localeName(context, currentLocale),
      itemBuilder: (context) => [
        for (final locale in _locales)
          PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FlagIcon(locale: locale, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  _localeName(context, locale),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: locale.languageCode == currentLocale.languageCode
                        ? colors.primary
                        : colors.onSurface,
                    fontWeight: locale.languageCode == currentLocale.languageCode
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: AppDuration.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FlagIcon(locale: currentLocale, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              currentLocale.languageCode.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceMuted,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
