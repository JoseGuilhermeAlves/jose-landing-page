import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Lista de badges de stack (Flutter, Dart, Bloc, etc.). Visualmente
/// igual a chips estaticos com cor primaria sutil — pegar a atencao
/// sem virar carnaval.
class StackBadges extends StatelessWidget {
  const StackBadges({required this.stack, super.key});

  final List<String> stack;

  @override
  Widget build(BuildContext context) {
    if (stack.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final item in stack)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              border: Border.all(color: colors.primary.withValues(alpha: 0.35)),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              item,
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                letterSpacing: 0.4,
              ),
            ),
          ),
      ],
    );
  }
}
