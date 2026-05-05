/// Feature "Showcase" — templates demonstraveis por nicho
/// (PROJECT.md §4.3). Pass A entregou estrutura + e-commerce; Pass B
/// adicionou delivery; Pass C adiciona scheduling. Demais (fitness,
/// imobiliaria) seguem em turnos proximos como cards "em breve".
library;

export 'src/data/delivery_orders_catalog.dart';
export 'src/data/products_catalog.dart';
export 'src/data/showcase_catalog.dart';
export 'src/domain/delivery_order.dart';
export 'src/domain/delivery_status.dart';
export 'src/domain/product.dart';
export 'src/domain/showcase_template.dart';
export 'src/presentation/delivery/delivery_bloc.dart';
export 'src/presentation/delivery/delivery_demo.dart';
export 'src/presentation/delivery/delivery_event.dart';
export 'src/presentation/delivery/delivery_state.dart';
export 'src/presentation/ecommerce/cart_bloc.dart';
export 'src/presentation/ecommerce/cart_event.dart';
export 'src/presentation/ecommerce/cart_state.dart';
export 'src/presentation/ecommerce/ecommerce_demo.dart';
export 'src/presentation/scheduling/scheduling_bloc.dart';
export 'src/presentation/scheduling/scheduling_demo.dart';
export 'src/presentation/scheduling/scheduling_event.dart';
export 'src/presentation/scheduling/scheduling_state.dart';
export 'src/presentation/showcase_grid.dart';
export 'src/presentation/showcase_section.dart';
