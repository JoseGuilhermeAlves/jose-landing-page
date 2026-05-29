import 'package:feature_showcase/src/shared/domain/showcase_template.dart';
import 'package:flutter/material.dart';

/// Catalogo dos nichos da vitrine. Cada entry com `hasDemo: true`
/// resolve um widget de demo em `showcase_section.dart`.
abstract final class ShowcaseCatalog {
  static const List<ShowcaseTemplate> all = [
    ShowcaseTemplate(
      id: 'finance',
      label: 'Investimentos',
      description:
          'Mira — watchlist, candlestick interativo com crosshair, '
          'envio de ordem e portfolio com donut de alocacao.',
      icon: Icons.show_chart_rounded,
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
          'Pulso — recovery dashboard, logger set-a-set com RPE e '
          'periodizacao de 8 semanas.',
      icon: Icons.monitor_heart_outlined,
      hasDemo: true,
    ),
    ShowcaseTemplate(
      id: 'realestate',
      label: 'Imobiliária',
      description:
          'Listagem de imoveis com filtros por bairro, faixa de preco '
          'e numero de quartos.',
      icon: Icons.home_work_outlined,
      hasDemo: true,
    ),
  ];
}
