import 'package:feature_showcase/src/finance/domain/asset.dart';
import 'package:feature_showcase/src/finance/domain/asset_sector.dart';

/// Catalogo estatico de ativos do mock Mira — 12 acoes da B3
/// representativas dos setores principais. Precos e variacoes
/// foram congelados num snapshot ficticio (sem conexao com market
/// real) pra deixar o demo determinista.
abstract final class MiraAssetsCatalog {
  static const List<Asset> all = [
    Asset(
      id: 'PETR4',
      symbol: 'PETR4',
      name: 'Petrobras PN',
      sector: AssetSector.oil,
      currentPriceCents: 3842,
      dailyChangeBps: 215,
    ),
    Asset(
      id: 'VALE3',
      symbol: 'VALE3',
      name: 'Vale ON',
      sector: AssetSector.mining,
      currentPriceCents: 6817,
      dailyChangeBps: -134,
    ),
    Asset(
      id: 'ITUB4',
      symbol: 'ITUB4',
      name: 'Itau Unibanco PN',
      sector: AssetSector.banking,
      currentPriceCents: 3596,
      dailyChangeBps: 87,
    ),
    Asset(
      id: 'BBDC4',
      symbol: 'BBDC4',
      name: 'Bradesco PN',
      sector: AssetSector.banking,
      currentPriceCents: 1623,
      dailyChangeBps: -42,
    ),
    Asset(
      id: 'WEGE3',
      symbol: 'WEGE3',
      name: 'WEG ON',
      sector: AssetSector.industrial,
      currentPriceCents: 5184,
      dailyChangeBps: 312,
    ),
    Asset(
      id: 'MGLU3',
      symbol: 'MGLU3',
      name: 'Magazine Luiza ON',
      sector: AssetSector.retail,
      currentPriceCents: 982,
      dailyChangeBps: -278,
    ),
    Asset(
      id: 'TOTS3',
      symbol: 'TOTS3',
      name: 'TOTVS ON',
      sector: AssetSector.tech,
      currentPriceCents: 3215,
      dailyChangeBps: 156,
    ),
    Asset(
      id: 'SUZB3',
      symbol: 'SUZB3',
      name: 'Suzano ON',
      sector: AssetSector.industrial,
      currentPriceCents: 5847,
      dailyChangeBps: -65,
    ),
    Asset(
      id: 'ELET3',
      symbol: 'ELET3',
      name: 'Eletrobras ON',
      sector: AssetSector.utilities,
      currentPriceCents: 4128,
      dailyChangeBps: 198,
    ),
    Asset(
      id: 'BBAS3',
      symbol: 'BBAS3',
      name: 'Banco do Brasil ON',
      sector: AssetSector.banking,
      currentPriceCents: 2864,
      dailyChangeBps: 73,
    ),
    Asset(
      id: 'ABEV3',
      symbol: 'ABEV3',
      name: 'Ambev ON',
      sector: AssetSector.food,
      currentPriceCents: 1142,
      dailyChangeBps: -23,
    ),
    Asset(
      id: 'LREN3',
      symbol: 'LREN3',
      name: 'Lojas Renner ON',
      sector: AssetSector.retail,
      currentPriceCents: 1817,
      dailyChangeBps: 124,
    ),
  ];

  /// Busca um asset por id. Lanca StateError se nao existir — sintoma
  /// de bug, nao de input ruim do usuario.
  static Asset byId(String id) => all.firstWhere((a) => a.id == id);

  /// Lookup seguro — retorna null em vez de lancar.
  static Asset? findById(String id) {
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }
}
