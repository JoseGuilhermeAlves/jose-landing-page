import 'package:design_system/design_system.dart';
import 'package:feature_labs/src/router/labs_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Layout compartilhado entre os 7 playgrounds. Mantem comportamento
/// de back consistente (volta pra `/labs`) e divide a area entre
/// preview e controles.
///
/// Em viewport >= 720 a preview ocupa metade esquerda e os controles
/// ficam na direita scrollavel; abaixo disso vira coluna.
class PlaygroundScaffold extends StatelessWidget {
  const PlaygroundScaffold({
    required this.title,
    required this.description,
    required this.painterName,
    required this.preview,
    required this.controls,
    super.key,
  });

  final String title;
  final String description;
  final String painterName;
  final Widget preview;
  final List<Widget> controls;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        leading: IconButton(
          key: const Key('playground-back-button'),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar para Labs',
          onPressed: () => context.go(LabsRoutePaths.index),
        ),
        title: Text(title, style: textTheme.titleLarge),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final header = _Header(
              description: description,
              painterName: painterName,
              colors: colors,
              textTheme: textTheme,
            );
            final controlsBlock = _Controls(controls: controls);
            final previewBlock = _PreviewFrame(preview: preview);

            if (!wide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(height: 320, child: previewBlock),
                    const SizedBox(height: AppSpacing.lg),
                    controlsBlock,
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: previewBlock),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: SingleChildScrollView(child: controlsBlock),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.description,
    required this.painterName,
    required this.colors,
    required this.textTheme,
  });

  final String description;
  final String painterName;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            painterName,
            style: textTheme.labelSmall?.copyWith(
              color: colors.primary,
              letterSpacing: 0.6,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          description,
          style: textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.preview});
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('playground-preview-frame'),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: preview,
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.controls});
  final List<Widget> controls;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Controles',
            style: textTheme.titleSmall?.copyWith(
              color: colors.onSurface,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < controls.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.md),
            controls[i],
          ],
        ],
      ),
    );
  }
}

/// Bloco padrao "label + slider + valor formatado" — usado pela
/// maioria dos playgrounds.
class PlaygroundSlider extends StatelessWidget {
  const PlaygroundSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.formatter,
    this.divisions,
    super.key,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;
  final String Function(double value) formatter;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceMuted,
                ),
              ),
            ),
            Text(
              formatter(value),
              style: textTheme.bodySmall?.copyWith(
                color: colors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          divisions: divisions,
          activeColor: colors.primary,
          inactiveColor: colors.surfaceMuted,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Toggle switch padrao — para opcoes booleanas (ex.: auto-cycle).
class PlaygroundSwitch extends StatelessWidget {
  const PlaygroundSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceMuted,
            ),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: colors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
