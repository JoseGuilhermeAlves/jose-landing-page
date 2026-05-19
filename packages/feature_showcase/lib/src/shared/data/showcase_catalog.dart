import 'package:feature_showcase/src/shared/domain/showcase_template.dart';
import 'package:flutter/material.dart';

/// Catalogo dos 5 nichos do PROJECT.md §4.3. Pass A entrega
/// e-commerce funcional; demais ficam `hasDemo: false` ate cada
/// turno seguinte.
abstract final class ShowcaseCatalog {
  static const List<ShowcaseTemplate> all = [
    ShowcaseTemplate(
      id: 'ecommerce',
      label: 'E-commerce',
      description:
          'Loja Garoa — home da marca, catalogo com filtros, detalhe '
          'do produto e checkout com resumo de pedido.',
      icon: Icons.shopping_bag_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'delivery',
      label: 'Delivery',
      description:
          'Aurora — marketplace de hortifruti com mapa animado, '
          'timeline do pedido e historico.',
      icon: Icons.delivery_dining_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'scheduling',
      label: 'Agendamento',
      description:
          'Vitral — estudio de servicos com calendario interativo, '
          'relogio animado e confirmacao com badge.',
      icon: Icons.calendar_month_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'fitness',
      label: 'Fitness',
      description:
          'Tracker de treino com graficos — series, evolucao, plano '
          'da semana.',
      icon: Icons.fitness_center_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'realestate',
      label: 'Imobiliaria',
      description:
          'Listagem de imoveis com filtros por bairro, faixa de preco '
          'e numero de quartos.',
      icon: Icons.home_work_outlined,
      hasDemo: true,
    ),
  ];
}
