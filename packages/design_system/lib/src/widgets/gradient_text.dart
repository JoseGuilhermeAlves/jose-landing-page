import 'package:flutter/material.dart';

/// Texto com fill em gradiente via `ShaderMask`. Use em palavras-chave
/// dentro de headlines — em paragrafos longos perde contraste e
/// legibilidade.
///
/// O `BlendMode.srcIn` garante que o gradiente substitua o `color` do
/// `TextStyle`; o style ainda controla tamanho, peso e letterspacing.
class GradientText extends StatelessWidget {
  const GradientText({
    required this.text,
    required this.gradient,
    this.style,
    this.textAlign,
    this.textWidthBasis = TextWidthBasis.parent,
    super.key,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextWidthBasis textWidthBasis;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: gradient.createShader,
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        textWidthBasis: textWidthBasis,
      ),
    );
  }
}
