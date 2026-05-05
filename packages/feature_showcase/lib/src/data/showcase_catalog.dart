import 'package:feature_showcase/src/domain/showcase_template.dart';
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
          'Catalogo navegavel com carrinho — adicionar, remover e ver '
          'total em tempo real.',
      icon: Icons.shopping_bag_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'delivery',
      label: 'Delivery',
      description:
          'Lista de pedidos com status animado — em preparo, saiu pra '
          'entrega, entregue.',
      icon: Icons.delivery_dining_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'scheduling',
      label: 'Agendamento',
      description:
          'Calendario interativo de horarios para servicos (salao, '
          'consultorio, oficina).',
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
