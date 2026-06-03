import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_program_page.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_recovery_page.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_today_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo Pulso dark Whoop. Bottom nav com 3 destinos (Hoje, Programa,
/// Recovery). Session logger e exercise detail sao pushados como
/// rotas full-screen sobre o shell. Mantem assinatura `today: int`
/// pra preservar compat com o entry point do showcase_section.
class FitnessDemo extends StatefulWidget {
  const FitnessDemo({required this.today, super.key});

  /// Mantido por compat com o entry point do showcase. O bloc deriva
  /// o dia atual de DateTime.now() — esse valor influencia tests
  /// futuros que injetarem hora fixa.
  final int today;

  @override
  State<FitnessDemo> createState() => _FitnessDemoState();
}

class _FitnessDemoState extends State<FitnessDemo> {
  int _tab = 0;

  static const _tabs = <Widget>[
    PulsoTodayPage(),
    PulsoProgramPage(),
    PulsoRecoveryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FitnessBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => FitnessBloc(initialDay: widget.today),
        child: Builder(
          builder: (context) {
            final colors = context.colors;
            return Scaffold(
              backgroundColor: colors.background,
              body: Stack(
                children: [
                  Positioned.fill(
                    child: IndexedStack(index: _tab, children: _tabs),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: _CloseDemoButton(
                          onClose: () => Navigator.of(context).maybePop(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: _PulsoBottomNav(
                index: _tab,
                onTap: (i) => setState(() => _tab = i),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CloseDemoButton extends StatelessWidget {
  const _CloseDemoButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClose,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: colors.border),
          ),
          child: Icon(Icons.close_rounded, color: colors.onSurface, size: 20),
        ),
      ),
    );
  }
}

class _PulsoBottomNav extends StatelessWidget {
  const _PulsoBottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                label: 'Hoje',
                icon: Icons.bolt_outlined,
                selected: index == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                label: 'Programa',
                icon: Icons.grid_view_outlined,
                selected: index == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                label: 'Recovery',
                icon: Icons.favorite_border_rounded,
                selected: index == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.full),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          // Pill aceso na aba ativa — substitui o swap-de-cor seco.
          color: selected
              ? colors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: selected
                ? colors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? colors.primary : colors.onSurfaceMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: selected ? colors.primary : colors.onSurfaceMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
