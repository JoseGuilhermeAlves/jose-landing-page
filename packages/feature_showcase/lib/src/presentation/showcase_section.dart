import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/data/showcase_catalog.dart';
import 'package:feature_showcase/src/domain/showcase_template.dart';
import 'package:feature_showcase/src/presentation/delivery/delivery_demo.dart';
import 'package:feature_showcase/src/presentation/ecommerce/ecommerce_demo.dart';
import 'package:feature_showcase/src/presentation/fitness/fitness_demo.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_demo.dart';
import 'package:feature_showcase/src/presentation/scheduling/scheduling_demo.dart';
import 'package:feature_showcase/src/presentation/showcase_grid.dart';
import 'package:flutter/material.dart';

/// Secao "O que eu posso construir pra voce" — grid clicavel dos 5
/// nichos. Tap em card com `hasDemo` abre o template em modal full
/// screen.
class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          eyebrow: 'Showcase',
          title: 'Cinco nichos,',
          titleAccent: 'cinco prototipos.',
          subtitle:
              'Mocks funcionais por nicho — toque num card pra abrir. '
              'Sem backend de verdade; demonstram o tipo de produto que '
              'consigo entregar.',
        ),
        const SizedBox(height: AppSpacing.xxl),
        ShowcaseGrid(
          templates: ShowcaseCatalog.all,
          onTemplateTapped: (t) => _openDemo(context, t),
        ),
      ],
    );
  }

  void _openDemo(BuildContext context, ShowcaseTemplate template) {
    final demo = _demoFor(template.id);
    if (demo == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => demo,
        fullscreenDialog: true,
      ),
    );
  }

  /// Resolve o widget de demo por id. Retorna null pra templates sem
  /// demo (cards ficam desabilitados pelo `hasDemo` do catalogo).
  Widget? _demoFor(String id) {
    return switch (id) {
      'ecommerce' => const EcommerceDemo(),
      'delivery' => DeliveryDemo(
          ticker: Stream<void>.periodic(const Duration(seconds: 2)),
        ),
      'scheduling' => SchedulingDemo(today: DateTime.now()),
      'fitness' => FitnessDemo(today: DateTime.now().weekday),
      'realestate' => const RealEstateDemo(),
      _ => null,
    };
  }
}
