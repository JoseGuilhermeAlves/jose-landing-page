import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:landing/widgets/arcade/arcade_backdrop.dart';
import 'package:landing/widgets/arcade/boot_sequence.dart';
import 'package:landing/widgets/arcade/crt_overlay.dart';

/// Moldura global da landing Arcade. Empilha, de tras pra frente:
/// 1. [ArcadeBackdrop] — starfield + grid Outrun animado;
/// 2. o conteudo da rota (paginas com Scaffold transparente);
/// 3. [CrtOverlay] — scanlines, vinheta e flicker do tubo;
/// 4. [BootSequence] — abertura "terminal verde" que auto-entra, so na
///    primeira carga.
///
/// Montado no `builder` do MaterialApp.router, entao envolve todas as
/// rotas com a mesma identidade CRT.
class ArcadeShell extends StatefulWidget {
  const ArcadeShell({required this.child, super.key});

  final Widget child;

  @override
  State<ArcadeShell> createState() => _ArcadeShellState();
}

class _ArcadeShellState extends State<ArcadeShell> {
  // Estatico: o boot aparece uma vez por sessao, nao a cada navegacao
  // (o builder do router recria o shell ao trocar de rota).
  static bool _bootSeen = false;
  late bool _booting = !_bootSeen;

  void _onStart() {
    _bootSeen = true;
    setState(() => _booting = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Positioned.fill(
          child: ArcadeBackdrop(
            background: colors.background,
            gridNear: colors.primary,
            gridFar: colors.accent,
            starColor: colors.onSurface,
          ),
        ),
        Positioned.fill(child: widget.child),
        Positioned.fill(child: CrtOverlay(tint: colors.onSurface)),
        if (_booting) Positioned.fill(child: BootSequence(onStart: _onStart)),
      ],
    );
  }
}
