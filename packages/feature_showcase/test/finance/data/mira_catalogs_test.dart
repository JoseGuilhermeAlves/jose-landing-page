import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MiraAssetsCatalog', () {
    test('expoe 12 ativos com ids unicos', () {
      final ids = MiraAssetsCatalog.all.map((a) => a.id).toSet();
      expect(MiraAssetsCatalog.all, hasLength(12));
      expect(ids, hasLength(12));
    });

    test('byId retorna o ativo certo', () {
      expect(MiraAssetsCatalog.byId('PETR4').symbol, 'PETR4');
      expect(MiraAssetsCatalog.byId('VALE3').sector, AssetSector.mining);
    });

    test('findById retorna null pra id inexistente', () {
      expect(MiraAssetsCatalog.findById('XYZ0'), isNull);
    });
  });

  group('MiraCandlesCatalog', () {
    test('gera 60 velas por ativo', () {
      final petr = MiraCandlesCatalog.forAsset('PETR4');
      expect(petr, hasLength(MiraCandlesCatalog.barCount));
    });

    test('ultima vela bate exato com o preco corrente do catalogo', () {
      for (final asset in MiraAssetsCatalog.all) {
        final candles = MiraCandlesCatalog.forAsset(asset.id);
        expect(
          candles.last.closeCents,
          asset.currentPriceCents,
          reason: '${asset.symbol} close da ultima vela != current price',
        );
      }
    });

    test('series sao deterministicas — duas chamadas retornam identico', () {
      final a = MiraCandlesCatalog.forAsset('PETR4');
      final b = MiraCandlesCatalog.forAsset('PETR4');
      expect(identical(a, b), isTrue, reason: 'memoized');
    });

    test('high >= max(open, close) e low <= min(open, close) em toda vela', () {
      for (final candle in MiraCandlesCatalog.forAsset('VALE3')) {
        final maxOC =
            candle.openCents > candle.closeCents
                ? candle.openCents
                : candle.closeCents;
        final minOC =
            candle.openCents < candle.closeCents
                ? candle.openCents
                : candle.closeCents;
        expect(candle.highCents >= maxOC, isTrue);
        expect(candle.lowCents <= minOC, isTrue);
      }
    });
  });
}
