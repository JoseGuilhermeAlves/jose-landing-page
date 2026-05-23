import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/domain/asset.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';

/// Ticker tape horizontal estilo trading platform — strip continua que
/// scrolla a esquerda mostrando todos os ativos do catalogo com preco
/// e variacao. Loop seamless via duplicacao da lista + controller
/// linear de 40s.
///
/// Detalhe estetico: cada ticker e um chip monoespacado com simbolo +
/// preco + delta colorido. Borda superior/inferior fina pra firmar
/// como faixa de informacao.
class MiraTickerTape extends StatefulWidget {
  const MiraTickerTape({super.key});

  @override
  State<MiraTickerTape> createState() => _MiraTickerTapeState();
}

class _MiraTickerTapeState extends State<MiraTickerTape>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Duplicamos a lista pra criar loop seamless — quando o primeiro
    // ciclo termina, o segundo ja esta cobrindo o mesmo conteudo.
    final assets = [...MiraAssetsCatalog.all, ...MiraAssetsCatalog.all];

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border),
          bottom: BorderSide(color: colors.border),
        ),
      ),
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Estimativa de largura total — calculada pelo numero de
            // tickers e largura media de 130px cada. Como duplicamos,
            // basta scrollar ate metade pra loop sem pulo visivel.
            final cycleWidth = (assets.length / 2) * 130.0;
            final offset = -_controller.value * cycleWidth;

            return OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: double.infinity,
              child: Transform.translate(
                offset: Offset(offset, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final asset in assets) _TickerChip(asset: asset),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TickerChip extends StatelessWidget {
  const _TickerChip({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isUp = asset.isUp;
    final deltaColor = isUp ? colors.success : colors.error;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            asset.symbol,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              fontFamily: MiraBrand.monoFontFamily,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            formatMiraPrice(asset.currentPriceCents),
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: MiraBrand.monoFontFamily,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
            color: deltaColor,
            size: 14,
          ),
          Text(
            formatMiraChangePct(asset.dailyChangeBps),
            style: TextStyle(
              color: deltaColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: MiraBrand.monoFontFamily,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
