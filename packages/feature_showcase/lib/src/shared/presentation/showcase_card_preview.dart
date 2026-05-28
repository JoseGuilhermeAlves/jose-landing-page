import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/presentation/aurora_hero_backdrop.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/presentation/mira_hero_backdrop.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_card_backdrop.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_hero_backdrop.dart';
import 'package:feature_showcase/src/scheduling/presentation/vitral_hero_backdrop.dart';
import 'package:flutter/material.dart';

/// Preview animado no topo do ShowcaseCard. Reutiliza o hero backdrop
/// de cada mock com as cores da marca — leve o suficiente para rodar
/// 5 instancias simultaneas na home sem comprometer frame budget.
class ShowcaseCardPreview extends StatelessWidget {
  const ShowcaseCardPreview({required this.templateId, super.key});

  final String templateId;

  static const double height = 120;

  @override
  Widget build(BuildContext context) {
    final backdrop = _backdropFor(templateId);
    if (backdrop == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppRadius.lg),
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(child: backdrop),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 32,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      context.colors.surface.withValues(alpha: 0),
                      context.colors.surface,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _backdropFor(String id) => switch (id) {
    'finance' => _themed(
      MiraBrand.palette,
      const MiraHeroBackdrop(height: height),
    ),
    'delivery' => const AuroraHeroBackdrop(
      waveColor: Color(0xFF2F6B3F),
      leafColor: Color(0x80C9883A),
    ),
    'scheduling' => const VitralHeroBackdrop(
      gridColor: Color(0x1F2A3B70),
      cursorColor: Color(0x33B07A2C),
    ),
    'fitness' => _themed(FitnessBrand.palette, const PulsoCardBackdrop()),
    'realestate' => const SolarHeroBackdrop(
      skyColor: Color(0xFF1A1510),
      hillColor: Color(0x664B5D3A),
      sunColor: Color(0xFFB25A38),
      particleColor: Color(0x73B25A38),
    ),
    _ => null,
  };

  static Widget _themed(AppColorScheme palette, Widget child) {
    return Builder(
      builder: (context) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            extensions: <ThemeExtension<dynamic>>[AppColorsExtension(palette)],
          ),
          child: child,
        );
      },
    );
  }
}
