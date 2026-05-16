import 'package:feature_showcase/src/domain/service_category.dart';
import 'package:feature_showcase/src/domain/specialist.dart';

/// Catalogo estatico de profissionais do estudio Vitral. Cada um
/// atende 1 ou 2 categorias. Nomes ficticios (primeiro nome +
/// inicial) — narrativa de estudio sem nomear pessoa real.
abstract final class VitralSpecialistsCatalog {
  static const List<Specialist> all = [
    Specialist(
      id: 's-sofia',
      name: 'Sofia A.',
      role: 'Estrategista de produto',
      bio: 'Ajuda founders a sair do "ideia de boteco" pra MVP testavel.',
      categories: [ServiceCategory.consulting, ServiceCategory.marketing],
      rating: 4.9,
      reviewCount: 142,
    ),
    Specialist(
      id: 's-lucas',
      name: 'Lucas M.',
      role: 'Fotografo de produto',
      bio: 'Sessoes em estudio com luz natural — catalogo, lookbook e e-com.',
      categories: [ServiceCategory.photography],
      rating: 4.8,
      reviewCount: 87,
    ),
    Specialist(
      id: 's-renata',
      name: 'Renata B.',
      role: 'Designer UI',
      bio: 'Sistemas de design e telas em alta fidelidade pra mobile/web.',
      categories: [ServiceCategory.design],
      rating: 5,
      reviewCount: 64,
    ),
    Specialist(
      id: 's-pedro',
      name: 'Pedro V.',
      role: 'Designer de marca',
      bio: 'Identidade visual ponta a ponta — logo, paleta, tipografia.',
      categories: [ServiceCategory.design, ServiceCategory.marketing],
      rating: 4.7,
      reviewCount: 39,
    ),
    Specialist(
      id: 's-marina',
      name: 'Marina G.',
      role: 'Especialista em ads',
      bio: 'Campanhas pagas em Meta e Google com foco em performance.',
      categories: [ServiceCategory.marketing],
      rating: 4.6,
      reviewCount: 53,
    ),
    Specialist(
      id: 's-rafael',
      name: 'Rafael T.',
      role: 'Fotografo editorial',
      bio: 'Retratos, eventos e ensaios documentais.',
      categories: [ServiceCategory.photography],
      rating: 4.9,
      reviewCount: 121,
    ),
  ];

  /// Lookup por id — null se nao existir.
  static Specialist? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}
