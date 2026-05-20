import 'package:feature_showcase/src/finance/data/mira_portfolio_catalog.dart';
import 'package:feature_showcase/src/finance/data/mira_trades_catalog.dart';
import 'package:feature_showcase/src/finance/presentation/finance_bloc.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/presentation/mira_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo de investimentos — mock multi-tela da marca ficticia "Mira"
/// (plataforma de renda variavel B2C, paleta deep-navy / verde-up /
/// vermelho-down). Substitui o mock de e-commerce (Garoa) na vitrine.
/// Experiencia: watchlist → detalhe do ativo (candlestick + book) →
/// envio de ordem → portfolio com donut → historico de trades.
///
/// Theme override aplica `MiraBrand.palette` localmente — todos os
/// widgets internos que leem `context.colors` recebem a paleta da
/// marca sem propagacao manual. **Brightness dark** (oposto aos
/// demais mocks light) — modais Material herdam o tratamento dark
/// correto.
class FinanceDemo extends StatelessWidget {
  const FinanceDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MiraBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => FinanceBloc(
          initialHoldings: MiraPortfolioCatalog.initial,
          initialTrades: MiraTradesCatalog.initial,
        ),
        child: const MiraHomePage(),
      ),
    );
  }
}
