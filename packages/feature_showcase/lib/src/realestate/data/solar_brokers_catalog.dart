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
      role: 'Especialista em casas e apartamentos',
      bio: 'Acompanha famílias na compra do primeiro imóvel no interior há '
          'mais de uma década. Conhece cada rua dos bairros históricos e '
          'prioriza visitas sem pressa.',
      yearsActive: 12,
      photoAsset: 'assets/realestate/corretor_maria.webp',
    ),
    Broker(
      id: 'b-carlos',
      name: 'Carlos B.',
      creci: 'CRECI/SP 23.456-F',
      phone: '(11) 99000-0002',
      email: 'carlos@solar.imob',
      role: 'Especialista em chácaras e terrenos',
      bio: 'Atua com propriedades rurais e lotes em condomínio. Avalia '
          'topografia, documentação e potencial construtivo antes de '
          'cada indicação.',
      yearsActive: 9,
      photoAsset: 'assets/realestate/corretor_carlos.webp',
    ),
    Broker(
      id: 'b-renata',
      name: 'Renata D.',
      creci: 'CRECI/SP 34.567-F',
      phone: '(11) 99000-0003',
      email: 'renata@solar.imob',
      role: 'Especialista em imóveis de alto padrão',
      bio: 'Curadoria de residências assinadas e imóveis com projeto de '
          'arquitetura. Atende com discrição e foco em acabamento.',
      yearsActive: 15,
      photoAsset: 'assets/realestate/corretor_renata.webp',
    ),
  ];

  static Broker? byId(String id) {
    for (final b in all) {
      if (b.id == id) return b;
    }
    return null;
  }
}
