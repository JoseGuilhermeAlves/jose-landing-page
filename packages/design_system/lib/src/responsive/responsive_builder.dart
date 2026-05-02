import 'package:design_system/src/responsive/breakpoint.dart';
import 'package:flutter/widgets.dart';

/// Builder que recebe o [Breakpoint] resolvido e retorna o widget apropriado.
///
/// Use quando voce quer logica condicional inline:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, bp) => bp.isMobile ? Column(...) : Row(...),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({required this.builder, super.key});

  final Widget Function(BuildContext context, Breakpoint breakpoint) builder;

  @override
  Widget build(BuildContext context) => builder(context, context.breakpoint);
}

/// Escolhe um widget por breakpoint. Cai pra `mobile` se um valor especifico
/// nao for fornecido (cascata: wide → desktop → tablet → mobile).
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    required this.mobile,
    this.tablet,
    this.desktop,
    this.wide,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? wide;

  @override
  Widget build(BuildContext context) {
    return switch (context.breakpoint) {
      Breakpoint.wide => wide ?? desktop ?? tablet ?? mobile,
      Breakpoint.desktop => desktop ?? tablet ?? mobile,
      Breakpoint.tablet => tablet ?? mobile,
      Breakpoint.mobile => mobile,
    };
  }
}
