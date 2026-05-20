import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';

/// Pill colorida com a variacao em % (ex.: "+2,15%" verde, "-0,87%"
/// vermelho). Cor de fundo = success/error com alpha baixo; cor do
/// texto = success/error puros. Usado em lista de ativos, detalhe e
/// historico.
class MiraChangePill extends StatelessWidget {
  const MiraChangePill({
    required this.changeBps,
    this.compact = false,
    super.key,
  });

  final int changeBps;

  /// Quando true, padding menor e fonte menor — usado em rows densas
  /// (lista da watchlist).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUp = changeBps >= 0;
    final color = isUp ? colors.success : colors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        formatMiraChangePct(changeBps),
        style: TextStyle(
          color: color,
          fontSize: compact ? 11 : 12,
          fontWeight: FontWeight.w700,
          fontFamily: MiraBrand.monoFontFamily,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
