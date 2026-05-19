import 'package:feature_showcase/src/realestate/domain/broker.dart';

/// Catalogo estatico de corretores da Solar. Nomes ficticios (primeiro
/// nome + inicial) e CRECI mock — narrativa de imobiliaria sem
/// nomear pessoa real.
abstract final class SolarBrokersCatalog {
  static const List<Broker> all = [
    Broker(
      id: 'b-maria',
      name: 'Maria L.',
      creci: 'CRECI/SP 12.345-F',
      phone: '(11) 99000-0001',
      email: 'maria@solar.imob',
    ),
    Broker(
      id: 'b-carlos',
      name: 'Carlos B.',
      creci: 'CRECI/SP 23.456-F',
      phone: '(11) 99000-0002',
      email: 'carlos@solar.imob',
    ),
    Broker(
      id: 'b-renata',
      name: 'Renata D.',
      creci: 'CRECI/SP 34.567-F',
      phone: '(11) 99000-0003',
      email: 'renata@solar.imob',
    ),
  ];

  static Broker? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}
