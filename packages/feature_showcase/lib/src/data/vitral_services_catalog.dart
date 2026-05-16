import 'package:feature_showcase/src/domain/service.dart';
import 'package:feature_showcase/src/domain/service_category.dart';

/// Catalogo estatico de servicos do estudio Vitral. Cada servico esta
/// vinculado a um Specialist (`specialistId`).
abstract final class VitralServicesCatalog {
  static const List<Service> all = [
    // Consultoria
    Service(
      id: 'sv-discovery',
      name: 'Discovery 1h',
      specialistId: 's-sofia',
      category: ServiceCategory.consulting,
      durationMinutes: 60,
      priceCents: 28000,
      description:
          'Sessao 1:1 pra destrinchar problema e definir hipotese de '
          'produto. Voce sai com um roadmap de 4 sprints.',
    ),
    Service(
      id: 'sv-workshop-mvp',
      name: 'Workshop MVP em meio dia',
      specialistId: 's-sofia',
      category: ServiceCategory.consulting,
      durationMinutes: 240,
      priceCents: 120000,
      description:
          'Workshop de 4h pra time pequeno: escopo, prototipo e plano '
          'de entrega. Para founders cedo ou squads novos.',
    ),

    // Fotografia
    Service(
      id: 'sv-foto-produto',
      name: 'Sessao de produto em estudio',
      specialistId: 's-lucas',
      category: ServiceCategory.photography,
      durationMinutes: 120,
      priceCents: 89000,
      description:
          'Sessao de 2h pra ate 12 produtos. Fundo branco, lookbook ou '
          'crop ja prontos pra e-commerce.',
    ),
    Service(
      id: 'sv-foto-retrato',
      name: 'Retrato corporativo',
      specialistId: 's-rafael',
      category: ServiceCategory.photography,
      durationMinutes: 60,
      priceCents: 45000,
      description:
          'Retrato em estudio com luz natural ou continua. Pra '
          'LinkedIn, imprensa ou pagina "Sobre".',
    ),
    Service(
      id: 'sv-foto-evento',
      name: 'Cobertura de evento curto',
      specialistId: 's-rafael',
      category: ServiceCategory.photography,
      durationMinutes: 180,
      priceCents: 150000,
      description:
          'Cobertura documental de evento pontual (lancamento, painel, '
          'workshop). Inclui 80 fotos finalizadas.',
    ),

    // Design
    Service(
      id: 'sv-design-ui',
      name: 'Design de tela',
      specialistId: 's-renata',
      category: ServiceCategory.design,
      durationMinutes: 90,
      priceCents: 38000,
      description:
          'Sessao pra desenhar uma tela em alta fidelidade. Inclui dois '
          'rounds de feedback.',
    ),
    Service(
      id: 'sv-design-system',
      name: 'Auditoria de design system',
      specialistId: 's-renata',
      category: ServiceCategory.design,
      durationMinutes: 120,
      priceCents: 56000,
      description:
          'Revisao do design system do produto — tokens, componentes '
          'e gaps. Saida em PDF com plano de evolucao.',
    ),
    Service(
      id: 'sv-design-marca',
      name: 'Identidade de marca',
      specialistId: 's-pedro',
      category: ServiceCategory.design,
      durationMinutes: 180,
      priceCents: 96000,
      description:
          'Pacote de marca: logo, paleta, tipografia e uso. Para nova '
          'marca ou reposicionamento.',
    ),

    // Marketing
    Service(
      id: 'sv-plano-trafego',
      name: 'Plano de trafego pago',
      specialistId: 's-marina',
      category: ServiceCategory.marketing,
      durationMinutes: 90,
      priceCents: 42000,
      description:
          'Estruturacao de campanhas em Meta e Google. Inclui briefing '
          'e plano de criativos.',
    ),
    Service(
      id: 'sv-go-to-market',
      name: 'Go-to-market 1:1',
      specialistId: 's-sofia',
      category: ServiceCategory.marketing,
      durationMinutes: 60,
      priceCents: 32000,
      description:
          'Sessao 1:1 pra alinhar canais, ICP e mensagem. Voce sai com '
          'a primeira semana de execucao mapeada.',
    ),
  ];

  /// Lookup por id — null se nao existir.
  static Service? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Filtra por categoria.
  static List<Service> byCategory(ServiceCategory cat) =>
      all.where((s) => s.category == cat).toList(growable: false);

  /// Filtra por specialist.
  static List<Service> byspecialist(String specialistId) =>
      all.where((s) => s.specialistId == specialistId).toList(growable: false);
}
