/// Feature "Showcase" — templates demonstraveis por nicho
/// (PROJECT.md §4.3). Os 5 nichos canonicos sao sub-features
/// (e-commerce, delivery, agendamento, fitness, imobiliaria), cada
/// um com seu proprio triangulo `data/domain/presentation` dentro de
/// `lib/src/<mock>/`. O `shared/` carrega o indice cross-cutting
/// (catalogo dos cards, grid, secao) e utilitarios comuns.
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
export 'src/ecommerce/data/products_catalog.dart';
export 'src/ecommerce/domain/order_summary.dart';
export 'src/ecommerce/domain/product.dart';
export 'src/ecommerce/domain/product_category.dart';
export 'src/ecommerce/domain/product_variant.dart';
export 'src/ecommerce/presentation/cart_bloc.dart';
export 'src/ecommerce/presentation/cart_event.dart';
export 'src/ecommerce/presentation/cart_state.dart';
export 'src/ecommerce/presentation/ecommerce_demo.dart';
export 'src/fitness/data/workout_plan_catalog.dart';
export 'src/fitness/domain/workout_day.dart';
export 'src/fitness/domain/workout_exercise.dart';
export 'src/fitness/presentation/fitness_bloc.dart';
export 'src/fitness/presentation/fitness_demo.dart';
export 'src/fitness/presentation/fitness_event.dart';
export 'src/fitness/presentation/fitness_state.dart';
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
export 'src/scheduling/data/vitral_services_catalog.dart';
export 'src/scheduling/data/vitral_specialists_catalog.dart';
export 'src/scheduling/domain/appointment.dart';
export 'src/scheduling/domain/service.dart';
export 'src/scheduling/domain/service_category.dart';
export 'src/scheduling/domain/specialist.dart';
export 'src/scheduling/presentation/scheduling_bloc.dart';
export 'src/scheduling/presentation/scheduling_demo.dart';
export 'src/scheduling/presentation/scheduling_event.dart';
export 'src/scheduling/presentation/scheduling_state.dart';
export 'src/shared/data/showcase_catalog.dart';
export 'src/shared/domain/showcase_template.dart';
export 'src/shared/presentation/showcase_grid.dart';
export 'src/shared/presentation/showcase_section.dart';
export 'src/shared/util/money_format.dart';
