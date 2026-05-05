import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// `/labs` — vitrine tecnica para devs/recrutadores. Esta pagina e
/// **deferred-loaded** (PROJECT.md §12.11): se o usuario leigo nunca
/// navegar pra ca, o bundle correspondente nem e baixado.
///
/// Conteudo real (Custom Painter playground, demos, decisoes
/// arquiteturais) sera adicionado quando feature_labs for construido.
class LabsPage extends StatelessWidget {
  const LabsPage({super.key = const Key('labs-page')});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text('Labs', style: textTheme.titleLarge),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Playground tecnico em construcao — custom painters, demos '
            'arquiteturais, decisoes do monorepo.',
            style: textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
