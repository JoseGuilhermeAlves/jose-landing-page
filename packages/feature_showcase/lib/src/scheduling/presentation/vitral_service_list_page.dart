import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_services_catalog.dart';
import 'package:feature_showcase/src/scheduling/data/vitral_specialists_catalog.dart';
import 'package:feature_showcase/src/scheduling/domain/service.dart';
import 'package:feature_showcase/src/scheduling/domain/service_category.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_app_bar.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_brand.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_calendar_page.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_category_illustration.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_navigation.dart';
import 'package:flutter/material.dart';

part 'vitral_service_list_widgets.dart';

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
      body: MockBodyConstraint(
        child: SafeArea(
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
      ),
    );
  }
}
