/// Feature "Showcase" — templates demonstraveis por nicho
/// (PROJECT.md §4.3). Os 3 nichos sao sub-features (delivery,
/// imobiliaria, finance), cada um com seu proprio triangulo
/// `data/domain/presentation` dentro de `lib/src/<mock>/`. O `shared/`
/// carrega o indice cross-cutting (catalogo dos cards, grid, secao) e
/// utilitarios comuns.
library;

export 'src/delivery/data/aurora_items_catalog.dart';
export 'src/delivery/data/aurora_vendors_catalog.dart';
export 'src/delivery/data/delivery_orders_catalog.dart';
export 'src/delivery/domain/delivery_order.dart';
export 'src/delivery/domain/delivery_status.dart';
export 'src/delivery/domain/market_category.dart';
export 'src/delivery/domain/market_item.dart';
export 'src/delivery/domain/order_timeline_step.dart';
export 'src/delivery/domain/vendor.dart';
export 'src/delivery/presentation/delivery_bloc.dart';
export 'src/delivery/presentation/delivery_demo.dart';
export 'src/delivery/presentation/delivery_event.dart';
export 'src/delivery/presentation/delivery_state.dart';
export 'src/finance/data/mira_assets_catalog.dart';
export 'src/finance/data/mira_candles_catalog.dart';
export 'src/finance/data/mira_portfolio_catalog.dart';
export 'src/finance/data/mira_trades_catalog.dart';
export 'src/finance/domain/asset.dart';
export 'src/finance/domain/asset_sector.dart';
export 'src/finance/domain/candle.dart';
export 'src/finance/domain/order_side.dart';
export 'src/finance/domain/portfolio_holding.dart';
export 'src/finance/domain/trade.dart';
export 'src/finance/presentation/finance_bloc.dart';
export 'src/finance/presentation/finance_demo.dart';
export 'src/finance/presentation/finance_event.dart';
export 'src/finance/presentation/finance_state.dart';
export 'src/realestate/data/properties_catalog.dart';
export 'src/realestate/data/solar_brokers_catalog.dart';
export 'src/realestate/domain/broker.dart';
export 'src/realestate/domain/property.dart';
export 'src/realestate/domain/property_feature.dart';
export 'src/realestate/domain/property_type.dart';
export 'src/realestate/presentation/realestate_bloc.dart';
export 'src/realestate/presentation/realestate_demo.dart';
export 'src/realestate/presentation/realestate_event.dart';
export 'src/realestate/presentation/realestate_state.dart';
export 'src/shared/data/showcase_catalog.dart';
export 'src/shared/domain/showcase_template.dart';
export 'src/shared/presentation/arcade_cabinet.dart';
export 'src/shared/presentation/showcase_photo.dart';
export 'src/shared/presentation/showcase_section.dart';
export 'src/shared/util/money_format.dart';
