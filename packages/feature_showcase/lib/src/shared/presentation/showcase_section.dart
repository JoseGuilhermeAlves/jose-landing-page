import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/presentation/delivery_demo.dart';
import 'package:feature_showcase/src/finance/presentation/finance_demo.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_demo.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_demo.dart';
import 'package:feature_showcase/src/scheduling/presentation/scheduling_demo.dart';
import 'package:feature_showcase/src/shared/data/showcase_catalog.dart';
import 'package:feature_showcase/src/shared/domain/showcase_template.dart';
import 'package:feature_showcase/src/shared/presentation/arcade_cabinet.dart';
import 'package:flutter/material.dart';

/// Secao "O que eu posso construir" — galeria de gabinetes de fliperama.
/// Cada gabinete mostra a **home real** do mock na tela (escalada, nao
/// interativa); tap "insere a ficha" e abre o demo completo fullscreen.
class ShowcaseSection extends StatelessWidget {
  const ShowcaseSection({super.key});

  /// Nome de marca exibido no marquee de cada gabinete.
  static const _brand = {
    'delivery': 'AURORA',
    'finance': 'MIRA',
    'fitness': 'PULSO',
    'scheduling': 'VITRAL',
    'realestate': 'SOLAR',
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final templates = ShowcaseCatalog.all(l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PixelText(l10n.showcase_eyebrow, color: colors.accent, pixelSize: 3),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text.rich(
            TextSpan(
              style: tt.headlineLarge?.copyWith(color: colors.onSurface),
              children: [
                TextSpan(text: '${l10n.showcase_title} '),
                TextSpan(
                  text: l10n.showcase_titleAccent,
                  style: TextStyle(color: colors.primary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            l10n.showcase_subtitle,
            style: tt.bodyLarge?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.55,
            ),
          ),
        ),
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.lg,
            desktop: AppSpacing.xxl,
          ),
        ),
        // Galeria de gabinetes — Wrap responsivo (1 col mobile, varios no
        // desktop). Cada gabinete tem largura fixa pra manter a proporcao.
        Wrap(
          spacing: AppSpacing.xl,
          runSpacing: AppSpacing.xl,
          children: [
            for (final t in templates)
              SizedBox(
                width: context.responsive(mobile: 280, desktop: 300),
                child: ArcadeCabinet(
                  key: Key('showcase-cabinet-${t.id}'),
                  label: _brand[t.id] ?? t.label.toUpperCase(),
                  enabled: t.hasDemo,
                  preview: _previewFor(t.id),
                  onTap: () => _openDemo(context, t),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _openDemo(BuildContext context, ShowcaseTemplate template) {
    final demo = _demoFor(template.id, preview: false);
    if (demo == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => demo, fullscreenDialog: true),
    );
  }

  /// Preview = home real do mock, sem interatividade. Delivery roda sem
  /// ticker (corredor estatico) pra nao gastar frame budget na miniatura.
  Widget _previewFor(String id) =>
      _demoFor(id, preview: true) ?? const SizedBox.shrink();

  /// Constroi o widget de demo por id. [preview] desliga o ticker do
  /// delivery na miniatura; no fullscreen ele roda normalmente.
  Widget? _demoFor(String id, {required bool preview}) {
    return switch (id) {
      'delivery' => DeliveryDemo(
        ticker: preview
            ? null
            : Stream<void>.periodic(const Duration(seconds: 2)),
      ),
      'scheduling' => SchedulingDemo(today: DateTime.now()),
      'fitness' => FitnessDemo(today: DateTime.now().weekday),
      'realestate' => const RealEstateDemo(),
      'finance' => const FinanceDemo(),
      _ => null,
    };
  }
}
