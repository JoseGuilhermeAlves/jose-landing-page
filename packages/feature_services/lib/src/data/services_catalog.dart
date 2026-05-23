import 'package:feature_services/src/domain/service.dart';
import 'package:flutter/material.dart';

/// Catalogo estatico do "o que eu faco". Lista canonica do PROJECT.md
/// §4.2 — qualquer ajuste de copy passa por aqui.
abstract final class ServicesCatalog {
  static const List<Service> all = [
    Service(
      id: 'mobile',
      title: 'Front end mobile',
      description:
          'Android nativo via Flutter — performance e '
          'consistencia de UX em devices reais.',
      icon: Icons.phone_android,
    ),
    Service(
      id: 'web',
      title: 'Web Apps & PWA',
      description:
          'O mesmo codigo Flutter como app web — '
          'instalavel como PWA, rapido e responsivo.',
      icon: Icons.public,
    ),
    Service(
      id: 'integrations',
      title: 'Integracao com APIs',
      description:
          'REST, OAuth, Bluetooth e NFC — integro o app '
          'mobile a APIs e perifericos ja existentes.',
      icon: Icons.hub_outlined,
    ),
    Service(
      id: 'maintenance',
      title: 'Manutencao e evolucao',
      description:
          'Refator, estabilizacao e novas features no front '
          'end de apps ja em producao.',
      icon: Icons.build_outlined,
    ),
    Service(
      id: 'consulting',
      title: 'Consultoria mobile',
      description:
          'Arquitetura, code review e definicao de stack — '
          'apoio tecnico antes da feature virar debito.',
      icon: Icons.lightbulb_outline,
    ),
  ];
}
