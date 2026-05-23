import 'package:design_system/design_system.dart';
import 'package:feature_services/src/data/services_catalog.dart';
import 'package:feature_services/src/presentation/service_card.dart';
import 'package:flutter/material.dart';

/// Grid responsivo de [ServiceCard]s. Quantidade de colunas varia por
/// breakpoint:
/// - mobile (<600): 1 coluna;
/// - tablet (600..900): 2 colunas;
/// - desktop+ (>=900): 3 colunas.
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({super.key});

  int _columnsFor(Breakpoint bp) {
    switch (bp) {
      case Breakpoint.mobile:
        return 1;
      case Breakpoint.tablet:
        return 2;
      case Breakpoint.desktop:
      case Breakpoint.wide:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    const services = ServicesCatalog.all;
    final columns = _columnsFor(context.breakpoint);

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = AppSpacing.md;
        // (columns - 1) gaps entre os cards na linha cheia.
        final totalGapWidth = gap * (columns - 1);
        final cardWidth = (constraints.maxWidth - totalGapWidth) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final service in services)
              SizedBox(
                width: cardWidth,
                child: ServiceCard(service: service),
              ),
          ],
        );
      },
    );
  }
}
