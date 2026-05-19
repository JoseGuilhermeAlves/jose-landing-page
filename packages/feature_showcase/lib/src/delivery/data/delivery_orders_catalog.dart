import 'package:feature_showcase/src/delivery/domain/delivery_order.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_status.dart';

/// Mock estatico de pedidos pro demo Aurora. O primeiro pedido fica
/// em status `preparing` pra que a home ja abra com um "pedido ativo"
/// visivel (em vez de comecar tudo em `received` como o demo legado).
/// Os ticks do bloc avancam os pedidos progressivamente.
///
/// Cada pedido carrega vendor, items, total e endereco — campos
/// opcionais do [DeliveryOrder]. Em forma legada (sem Aurora), o
/// pedido continua funcional ignorando esses campos.
abstract final class DeliveryOrdersCatalog {
  static const List<DeliveryOrder> all = [
    DeliveryOrder(
      id: '#A-1042',
      customerName: 'Ana S.',
      items: 5,
      status: DeliveryStatus.preparing,
      etaMinutes: 25,
      vendorId: 'v-mario',
      lineItems: [
        OrderLineItem(
          itemId: 'i-banana',
          name: 'Banana prata',
          quantity: 1.5,
          unitShort: 'kg',
          unitPriceCents: 890,
        ),
        OrderLineItem(
          itemId: 'i-alface',
          name: 'Alface crespa',
          quantity: 2,
          unitShort: 'un',
          unitPriceCents: 490,
        ),
        OrderLineItem(
          itemId: 'i-tomate',
          name: 'Tomate italiano',
          quantity: 1,
          unitShort: 'kg',
          unitPriceCents: 1190,
        ),
      ],
      totalCents: 3815,
      addressLine: 'Rua das Palmeiras, 240 · Pinheiros · SP',
      placedAtLabel: 'Hoje as 09:42',
    ),
    DeliveryOrder(
      id: '#A-1043',
      customerName: 'Bruno T.',
      items: 2,
      status: DeliveryStatus.received,
      etaMinutes: 30,
      vendorId: 'v-padaria-centro',
      lineItems: [
        OrderLineItem(
          itemId: 'i-pao-frances',
          name: 'Pao frances',
          quantity: 0.5,
          unitShort: 'kg',
          unitPriceCents: 1890,
        ),
        OrderLineItem(
          itemId: 'i-baguete',
          name: 'Baguete rustica',
          quantity: 1,
          unitShort: 'un',
          unitPriceCents: 1490,
        ),
      ],
      totalCents: 3025,
      addressLine: 'Av. Brasil, 1500 · Higienopolis · SP',
      placedAtLabel: 'Hoje as 09:55',
    ),
    DeliveryOrder(
      id: '#A-1044',
      customerName: 'Carla M.',
      items: 4,
      status: DeliveryStatus.received,
      etaMinutes: 40,
      vendorId: 'v-queijaria',
      lineItems: [
        OrderLineItem(
          itemId: 'i-queijo-minas',
          name: 'Queijo minas frescal',
          quantity: 0.5,
          unitShort: 'kg',
          unitPriceCents: 4890,
        ),
        OrderLineItem(
          itemId: 'i-manteiga',
          name: 'Manteiga artesanal',
          quantity: 1,
          unitShort: 'pct',
          unitPriceCents: 2790,
        ),
      ],
      totalCents: 6225,
      addressLine: 'Rua Aurora, 88 · Centro · SP',
      placedAtLabel: 'Hoje as 10:02',
    ),
    DeliveryOrder(
      id: '#A-1045',
      customerName: 'Diego L.',
      items: 2,
      status: DeliveryStatus.outForDelivery,
      etaMinutes: 12,
      vendorId: 'v-empório-aurora',
      lineItems: [
        OrderLineItem(
          itemId: 'i-feijao',
          name: 'Feijao carioca',
          quantity: 1,
          unitShort: 'kg',
          unitPriceCents: 1890,
        ),
        OrderLineItem(
          itemId: 'i-azeite',
          name: 'Azeite extra virgem',
          quantity: 1,
          unitShort: 'pct',
          unitPriceCents: 4990,
        ),
      ],
      totalCents: 6880,
      addressLine: 'Travessa Sao Vicente, 14 · Bela Vista · SP',
      placedAtLabel: 'Hoje as 08:30',
    ),
    DeliveryOrder(
      id: '#A-1046',
      customerName: 'Elisa R.',
      items: 1,
      status: DeliveryStatus.delivered,
      etaMinutes: 0,
      vendorId: 'v-feira-itinerante',
      lineItems: [
        OrderLineItem(
          itemId: 'i-caixote',
          name: 'Caixote da semana',
          quantity: 1,
          unitShort: 'pct',
          unitPriceCents: 7990,
        ),
      ],
      totalCents: 7990,
      addressLine: 'Alameda dos Anjos, 320 · Vila Mariana · SP',
      placedAtLabel: 'Ontem as 17:20',
    ),
    DeliveryOrder(
      id: '#A-1047',
      customerName: 'Felipe O.',
      items: 3,
      status: DeliveryStatus.delivered,
      etaMinutes: 0,
      vendorId: 'v-padoca-bairro',
      lineItems: [
        OrderLineItem(
          itemId: 'i-pao-doce',
          name: 'Pao doce',
          quantity: 3,
          unitShort: 'un',
          unitPriceCents: 590,
        ),
      ],
      totalCents: 2260,
      addressLine: 'Rua Doutor Veiga, 77 · Perdizes · SP',
      placedAtLabel: 'Ontem as 15:08',
    ),
  ];
}
