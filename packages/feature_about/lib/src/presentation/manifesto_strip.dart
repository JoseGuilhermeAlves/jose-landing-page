import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Strip de manifesto — 4 linhas curtas em mono font que sintetizam
/// o escopo. Substitui o card de "Sobre escopo, sem inflar". Animacao
/// de fade-in stagger linha-por-linha dispara assim que o widget e
/// montado (uma vez so — nao loopa).
///
/// **Por que mono:** quebra o ritmo da bio em prosa e marca a
/// declaracao como diferente de paragrafo comum. Lembra terminal,
/// nao copy comercial.
class ManifestoStrip extends StatefulWidget {
  const ManifestoStrip({super.key});

  static const List<String> _lines = [
    'Front end mobile.',
    'Flutter.',
    'Integro APIs, nao construo.',
    'Devices reais.',
  ];

  @override
  State<ManifestoStrip> createState() => _ManifestoStripState();
}

class _ManifestoStripState extends State<ManifestoStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMobile = context.isMobile;
    final children = <Widget>[];
    final lines = ManifestoStrip._lines;
    final count = lines.length;
    for (var i = 0; i < count; i++) {
      final start = i / count;
      final end = (i + 1) / count;
      children.add(
        AnimatedBuilder(
          animation: _controller,
          builder: (_, _) {
            final t = ((_controller.value - start) / (end - start)).clamp(
              0.0,
              1.0,
            );
            return Opacity(
              opacity: Curves.easeOut.transform(t),
              child: Transform.translate(
                offset: Offset(0, (1 - t) * 8),
                child: _LineRow(index: i, text: lines[i], isMobile: isMobile),
              ),
            );
          },
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            colors.primary.withValues(alpha: 0.08),
            colors.primary.withValues(alpha: 0.0),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border(
          left: BorderSide(
            color: colors.primary.withValues(alpha: 0.7),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.index,
    required this.text,
    required this.isMobile,
  });

  final int index;
  final String text;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tt = Theme.of(context).textTheme;
    final indexLabel = (index + 1).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$indexLabel  ',
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              letterSpacing: 0.8,
            ),
          ),
          Flexible(
            child: Text(
              text,
              style: (isMobile ? tt.titleMedium : tt.titleLarge)?.copyWith(
                color: colors.onSurface,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
