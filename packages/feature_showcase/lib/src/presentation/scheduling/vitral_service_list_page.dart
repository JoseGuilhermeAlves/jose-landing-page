import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/vitral_services_catalog.dart';
import 'package:feature_showcase/src/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/domain/service.dart';
import 'package:feature_showcase/src/domain/service_category.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_app_bar.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_brand.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_calendar_page.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_category_illustration.dart';
import 'package:feature_showcase/src/presentation/scheduling/vitral_navigation.dart';
import 'package:flutter/material.dart';

/// Catalogo de servicos Vitral — filtravel por categoria via chips,
/// cada item exibe nome + profissional + duracao + preco. Tap empurra
/// `VitralCalendarPage` com o servico pre-selecionado.
class VitralServiceListPage extends StatefulWidget {
  const VitralServiceListPage({this.initialCategory, super.key});

  /// Categoria pre-selecionada quando a navegacao parte de um chip da
  /// home ou de um card de profissional. Null = "Todos".
  final ServiceCategory? initialCategory;

  @override
  State<VitralServiceListPage> createState() => _VitralServiceListPageState();
}

class _VitralServiceListPageState extends State<VitralServiceListPage> {
  ServiceCategory? _category;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  List<Service> _visibleServices() {
    if (_category == null) return VitralServicesCatalog.all;
    return VitralServicesCatalog.byCategory(_category!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final services = _visibleServices();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const VitralAppBar(),
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
              Text(
                'servicos'.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(
                  color: colors.accent,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                _category == null
                    ? 'Todos os servicos'
                    : 'Em ${_category!.label.toLowerCase()}',
                style: textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _FilterChips(
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                services.length == 1
                    ? '1 servico'
                    : '${services.length} servicos',
                style: textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < services.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                _ServiceCard(service: services[i]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final specialist = VitralSpecialistsCatalog.byId(service.specialistId);

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        key: Key('vitral-service-card-${service.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => vitralWithDemoBloc(
              context,
              VitralCalendarPage(service: service),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: VitralCategoryIllustration(
                    category: service.category,
                    foregroundColor: colors.primary,
                    accentColor: colors.accent,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.category.label.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.accent,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      service.name,
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (specialist != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'com ${specialist.name} · ${specialist.role}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 12,
                          color: colors.onSurfaceMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          service.formattedDuration,
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceMuted,
                            fontFamily: VitralBrand.monoFontFamily,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    service.formattedPrice,
                    style: textTheme.titleSmall?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceMuted,
                    size: 20,
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onChanged,
    required this.colors,
    required this.textTheme,
  });

  final ServiceCategory? selected;
  final ValueChanged<ServiceCategory?> onChanged;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _Chip(
            label: 'Todos',
            selected: selected == null,
            onTap: () => onChanged(null),
            colors: colors,
            textTheme: textTheme,
          ),
          for (final c in ServiceCategory.values) ...[
            const SizedBox(width: AppSpacing.xs),
            _Chip(
              label: c.label,
              cat: c,
              selected: selected == c,
              onTap: () => onChanged(c),
              colors: colors,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.textTheme,
    this.cat,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final ServiceCategory? cat;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: InkWell(
        key: Key('vitral-filter-${cat?.name ?? 'all'}'),
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
