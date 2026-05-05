import 'package:feature_services/src/domain/service.dart';
import 'package:flutter/material.dart';

/// Catalogo estatico do "o que eu faco". Lista canonica do PROJECT.md
/// §4.2 — qualquer ajuste de copy passa por aqui.
abstract final class ServicesCatalog {
  static const List<Service> all = [
    Service(
      id: 'mobile',
      title: 'Apps mobile',
      description: 'Android nativo via Flutter — performance e UX '
          'consistentes em devices reais.',
      icon: Icons.phone_android,
    ),
    Service(
      id: 'web',
      title: 'Web Apps & PWA',
      description: 'Apps web com Flutter — instalaveis como PWA, '
          'rapidos e responsivos.',
      icon: Icons.public,
    ),
    Service(
      id: 'integrations',
      title: 'Integracoes',
      description: 'APIs REST, Bluetooth, NFC, OAuth — conecto seu app '
          'ao que ele precisa falar.',
      icon: Icons.hub_outlined,
    ),
    Service(
      id: 'maintenance',
      title: 'Manutencao e evolucao',
      description: 'Estabilizacao, refator e novas features em apps '
          'que ja estao em producao.',
      icon: Icons.build_outlined,
    ),
    Service(
      id: 'consulting',
      title: 'Consultoria tecnica',
      description: 'Arquitetura, code review e direcionamento — antes '
          'do bug virar dor cronica.',
      icon: Icons.lightbulb_outline,
    ),
  ];
}
