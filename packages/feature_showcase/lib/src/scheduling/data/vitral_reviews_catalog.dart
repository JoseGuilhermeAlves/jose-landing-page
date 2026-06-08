import 'package:feature_showcase/src/scheduling/domain/specialist_review.dart';

/// Catalogo estatico de avaliacoes mock dos profissionais Vitral. Cada
/// review esta vinculada a um Specialist (`specialistId`). Sem backend —
/// fala ficticia coerente com o nicho de cada profissional.
abstract final class VitralReviewsCatalog {
  static const List<SpecialistReview> all = [
    // Sofia A. — estrategista de produto.
    SpecialistReview(
      id: 'rv-sofia-1',
      specialistId: 's-sofia',
      authorName: 'Camila R.',
      rating: 5,
      comment:
          'Sai da sessao com o roadmap das proximas quatro sprints. '
          'Direta, sem encheção.',
      relativeDate: 'ha 3 dias',
    ),
    SpecialistReview(
      id: 'rv-sofia-2',
      specialistId: 's-sofia',
      authorName: 'Bruno T.',
      rating: 5,
      comment: 'Cortou meio mes de indecisao em uma hora de conversa.',
      relativeDate: 'ha 2 semanas',
    ),
    SpecialistReview(
      id: 'rv-sofia-3',
      specialistId: 's-sofia',
      authorName: 'Helena P.',
      rating: 4,
      comment: 'Otima leitura de produto. Queria mais tempo de Q&A no fim.',
      relativeDate: 'ha 1 mes',
    ),

    // Lucas M. — fotografo de produto.
    SpecialistReview(
      id: 'rv-lucas-1',
      specialistId: 's-lucas',
      authorName: 'Marcos V.',
      rating: 5,
      comment: 'As fotos do catalogo ficaram prontas pro e-commerce no mesmo dia.',
      relativeDate: 'ha 5 dias',
    ),
    SpecialistReview(
      id: 'rv-lucas-2',
      specialistId: 's-lucas',
      authorName: 'Paula S.',
      rating: 5,
      comment: 'Luz natural impecavel. Recomendo pra lookbook.',
      relativeDate: 'ha 3 semanas',
    ),

    // Renata B. — designer UI.
    SpecialistReview(
      id: 'rv-renata-1',
      specialistId: 's-renata',
      authorName: 'Diego A.',
      rating: 5,
      comment: 'Entregou o design system documentado e facil de aplicar.',
      relativeDate: 'ha 1 semana',
    ),
    SpecialistReview(
      id: 'rv-renata-2',
      specialistId: 's-renata',
      authorName: 'Larissa M.',
      rating: 5,
      comment: 'Telas em alta fidelidade prontas pra dev. Dois rounds e fechou.',
      relativeDate: 'ha 1 mes',
    ),

    // Pedro V. — designer de marca.
    SpecialistReview(
      id: 'rv-pedro-1',
      specialistId: 's-pedro',
      authorName: 'Rafael C.',
      rating: 5,
      comment: 'Pacote de marca completo — logo, paleta e guia de uso.',
      relativeDate: 'ha 2 semanas',
    ),
    SpecialistReview(
      id: 'rv-pedro-2',
      specialistId: 's-pedro',
      authorName: 'Joana F.',
      rating: 4,
      comment: 'Identidade ficou consistente. Processo um pouco corrido.',
      relativeDate: 'ha 1 mes',
    ),

    // Marina G. — especialista em ads.
    SpecialistReview(
      id: 'rv-marina-1',
      specialistId: 's-marina',
      authorName: 'Tiago L.',
      rating: 5,
      comment: 'Plano de trafego claro, com criativos e verba bem distribuida.',
      relativeDate: 'ha 6 dias',
    ),
    SpecialistReview(
      id: 'rv-marina-2',
      specialistId: 's-marina',
      authorName: 'Aline B.',
      rating: 4,
      comment: 'Boa estruturacao das campanhas. CPA caiu na primeira semana.',
      relativeDate: 'ha 3 semanas',
    ),

    // Rafael T. — fotografo editorial.
    SpecialistReview(
      id: 'rv-rafael-1',
      specialistId: 's-rafael',
      authorName: 'Sandra M.',
      rating: 5,
      comment: 'Retrato corporativo ficou perfeito pro LinkedIn e imprensa.',
      relativeDate: 'ha 4 dias',
    ),
    SpecialistReview(
      id: 'rv-rafael-2',
      specialistId: 's-rafael',
      authorName: 'Otavio R.',
      rating: 5,
      comment: 'Cobertura de evento documental, sensivel e discreta.',
      relativeDate: 'ha 2 semanas',
    ),
  ];

  /// Reviews de um profissional, na ordem do catalogo.
  static List<SpecialistReview> bySpecialist(String specialistId) =>
      all.where((r) => r.specialistId == specialistId).toList(growable: false);
}
