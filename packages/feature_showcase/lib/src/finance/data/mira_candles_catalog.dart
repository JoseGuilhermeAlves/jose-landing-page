import 'dart:math' as math;

import 'package:feature_showcase/src/finance/data/mira_assets_catalog.dart';
import 'package:feature_showcase/src/finance/domain/candle.dart';

/// Catalogo de velas (OHLC) por ativo. Gerado deterministicamente por
/// random walk com seed derivada do ticker — mesmo `assetId` sempre
/// retorna a mesma serie. Sem dependencia de tempo real; ancora a
/// ultima vela em [_anchor] e desce no tempo.
///
/// O ultimo candle de cada serie e ajustado pra que `closeCents`
/// bata exatamente com o `currentPriceCents` do catalogo — assim a
/// "tela do ativo" mostra o mesmo preco que a watchlist.
abstract final class MiraCandlesCatalog {
  /// Quantidade de velas geradas por ativo (60 dias uteis = 3 meses).
  static const int barCount = 60;

  /// Data ancora da ultima vela. Demo nao reage a "hoje" pra manter
  /// snapshots reprodutiveis em todos os testes.
  static final DateTime _anchor = DateTime(2026, 5, 19);

  static final Map<String, List<Candle>> _cache = {};

  /// Retorna a serie de velas do ativo. Memoizado por id — primeira
  /// chamada gera e cacheia, demais retornam direto.
  static List<Candle> forAsset(String assetId) {
    final cached = _cache[assetId];
    if (cached != null) return cached;

    final asset = MiraAssetsCatalog.findById(assetId);
    if (asset == null) return const [];

    final series = _generate(
      seed: _seedFor(assetId),
      anchorPriceCents: asset.currentPriceCents,
      barCount: barCount,
    );
    _cache[assetId] = series;
    return series;
  }

  /// Seed estavel por ticker — soma dos code units.
  static int _seedFor(String assetId) {
    var seed = 0;
    for (final c in assetId.codeUnits) {
      seed = (seed * 31 + c) & 0x7fffffff;
    }
    return seed == 0 ? 1 : seed;
  }

  static List<Candle> _generate({
    required int seed,
    required int anchorPriceCents,
    required int barCount,
  }) {
    final rng = math.Random(seed);
    // Volatilidade relativa por preco — papeis caros oscilam menos em
    // %, mas mais em centavos absolutos. ~1,8% de movimento maximo
    // intra-vela; bias suave pra cima nas primeiras velas (~+0,1% por
    // vela) pra a ultima vela bater na ancora sem precisar corrigir
    // demais.
    final candles = <Candle>[];

    // Geramos do mais antigo pro mais recente. Comecamos num preco
    // ~10% abaixo da ancora pra deixar a serie ter o que subir.
    var price = (anchorPriceCents * (0.85 + rng.nextDouble() * 0.15)).round();

    for (var i = 0; i < barCount; i++) {
      final daysAgo = barCount - 1 - i;
      final timestamp = _anchor.subtract(Duration(days: daysAgo));

      // Movimento do dia: drift positivo pequeno + ruido.
      const drift = 0.001;
      final shock = (rng.nextDouble() - 0.5) * 0.036;
      final pct = drift + shock;

      final open = price;
      var close = (price * (1 + pct)).round();
      if (close < 1) close = 1;

      // High/low envolvem open e close com mais oscilacao.
      final wickAmp = (rng.nextDouble() * 0.012 + 0.003) * open;
      final high = (math.max(open, close) + wickAmp).round();
      final low = math.max(1, (math.min(open, close) - wickAmp).round());

      // Volume — entre 200k e 5M, mais alto em velas com movimento.
      final movePct = ((close - open).abs() / open).clamp(0.0, 0.04);
      final volume = (
        200000 + rng.nextDouble() * 1500000 + movePct * 60000000
      ).round();

      candles.add(
        Candle(
          timestamp: timestamp,
          openCents: open,
          highCents: high,
          lowCents: low,
          closeCents: close,
          volume: volume,
        ),
      );
      price = close;
    }

    // Ajusta a ultima vela pro close bater exato na ancora — sem
    // distorcer high/low.
    final last = candles.last;
    final adjustedHigh = math.max(last.highCents, anchorPriceCents);
    final adjustedLow = math.min(last.lowCents, anchorPriceCents);
    candles[candles.length - 1] = Candle(
      timestamp: last.timestamp,
      openCents: last.openCents,
      highCents: adjustedHigh,
      lowCents: adjustedLow,
      closeCents: anchorPriceCents,
      volume: last.volume,
    );

    return List.unmodifiable(candles);
  }
}
