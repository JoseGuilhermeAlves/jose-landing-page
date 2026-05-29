// Modal popup exibido quando o usuario clica num corpo celeste da cena
// cosmica. Recebe uma `TechDescription` ja resolvida do catalogo e renderiza
// titulo, tagline, chips de metadado, corpo longo e CTA opcional pra docs.

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/engineering/tech_descriptions.dart';

/// Abre o popup de detalhe de uma tech sobre a cena cosmica. O barrier
/// escuro isola visualmente o modal e o tap fora dele descarta.
Future<void> showTechBodyPopup(
  BuildContext context, {
  required TechDescription description,
  void Function(String url)? onOpenDocs,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: description.title,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) {
      return _TechBodyPopup(description: description, onOpenDocs: onOpenDocs);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _TechBodyPopup extends StatelessWidget {
  const _TechBodyPopup({required this.description, required this.onOpenDocs});

  final TechDescription description;
  final void Function(String url)? onOpenDocs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final docsUrl = description.docsUrl;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.primary.withValues(alpha: 0.45)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.32),
                  blurRadius: 48,
                  spreadRadius: -8,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(role: description.role),
                const SizedBox(height: AppSpacing.base),
                GradientText(
                  text: description.title,
                  gradient: AppGradients.brand(colors),
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description.tagline,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.base),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    _MetaChip(
                      label: description.version,
                      icon: Icons.code_rounded,
                    ),
                    _MetaChip(
                      label: description.role,
                      icon: Icons.category_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  description.body,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceMuted,
                    height: 1.6,
                  ),
                ),
                if (docsUrl != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppButton(
                      label: 'Abrir documentacao',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.open_in_new,
                      onPressed: () {
                        Navigator.pop(context);
                        onOpenDocs?.call(docsUrl);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        // Dot pulsante visual em cor primary com glow estatico.
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: colors.primary,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.6),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            role.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close_rounded, color: colors.onSurfaceMuted),
          tooltip: 'Fechar',
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurfaceMuted),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(color: colors.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}
