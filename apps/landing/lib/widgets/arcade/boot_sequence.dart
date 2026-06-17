import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Abertura "title-card de fliperama": a marca aparece digitando como num
/// attract screen (letras verdes de terminal), depois um cursor pisca e a home
/// entra SOZINHA — sem PRESS START. Continua skipavel: qualquer toque, scroll
/// ou tecla adianta o fade-out. Deliberadamente NAO usa linguagem de boot de
/// sistema (OS/assets/WASM) pra nao soar como instalacao.
///
/// O componente se auto-gerencia: chama [onStart] uma unica vez quando
/// dispensado (por input ou pelo auto-enter que dispara apos a digitacao).
class BootSequence extends StatefulWidget {
  const BootSequence({required this.onStart, super.key});

  /// Disparado quando o boot e dispensado — o shell remove o overlay.
  final VoidCallback onStart;

  @override
  State<BootSequence> createState() => _BootSequenceState();
}

class _BootSequenceState extends State<BootSequence>
    with TickerProviderStateMixin {
  // Controla a digitacao das linhas (0..1 -> fracao de chars revelados).
  late final AnimationController _typing;
  // Pisca do "PRESS START".
  late final AnimationController _blink;
  // Fade-out na saida.
  late final AnimationController _exit;

  final _focusNode = FocusNode();
  bool _dismissing = false;

  // Title-card de fliperama (attract screen), NAO um boot de sistema —
  // nada de "BOOTING OS / LOADING ASSETS / WASM" pra nao dar impressao de
  // que o site instala algo na maquina do visitante. So marca + convite.
  static const _lines = <String>[
    'ZEGUIDEV  ARCADE',
    'FLUTTER · 2026',
    '',
    'LOADING...',
  ];

  // Beat curto entre o fim da digitacao e o auto-enter na home.
  static const _autoEnterDelay = Duration(milliseconds: 650);
  Timer? _autoTimer;

  late final int _totalChars =
      _lines.fold(0, (sum, l) => sum + l.length) + _lines.length;

  @override
  void initState() {
    super.initState();
    _typing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    // Ao terminar a digitacao, agenda o auto-enter (skipavel antes disso).
    _typing.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _autoTimer = Timer(_autoEnterDelay, _dismiss);
      }
    });
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    // Foca pra capturar teclado no web/desktop.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _typing.dispose();
    _blink.dispose();
    _exit.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _autoTimer?.cancel();
    await _exit.forward();
    if (mounted) widget.onStart();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0).animate(_exit),
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: (_, __) {
          _dismiss();
          return KeyEventResult.handled;
        },
        child: Listener(
          // Scroll dispensa (gesto natural de "quero ver o conteudo").
          onPointerSignal: (_) => _dismiss(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dismiss,
            child: ColoredBox(
              color: colors.background,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Terminal de boot digitando.
                        AnimatedBuilder(
                          animation: _typing,
                          builder: (context, _) {
                            return Text(
                              _revealedText(_typing.value),
                              style: textTheme.bodyMedium?.copyWith(
                                color: colors.success,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                letterSpacing: 1.5,
                                height: 1.7,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Cursor de terminal piscando enquanto carrega — a home
                        // entra sozinha logo apos a digitacao.
                        AnimatedBuilder(
                          animation: Listenable.merge([_typing, _blink]),
                          builder: (context, _) {
                            final ready = _typing.isCompleted;
                            return Opacity(
                              opacity: ready ? _blink.value : 0,
                              child: Container(
                                width: 14,
                                height: 22,
                                color: colors.success,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'toque para pular',
                          style: textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceMuted,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Texto revelado proporcional a [progress] (0..1), char a char,
  /// linha a linha — efeito de digitacao de terminal.
  String _revealedText(double progress) {
    final reveal = (progress * _totalChars).round();
    final buffer = StringBuffer();
    var count = 0;
    for (final line in _lines) {
      if (count >= reveal) break;
      final remaining = reveal - count;
      if (remaining >= line.length) {
        buffer.writeln(line);
        count += line.length + 1;
      } else {
        buffer.write(line.substring(0, remaining));
        count = reveal;
        break;
      }
    }
    return buffer.toString();
  }
}
