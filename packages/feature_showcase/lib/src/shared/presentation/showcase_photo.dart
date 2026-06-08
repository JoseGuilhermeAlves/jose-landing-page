import 'package:flutter/material.dart';

/// Foto de mock com carregamento lazy + fade-in e fallback gracioso.
///
/// Quando [assetPath] e null, ou a imagem ainda nao carregou, ou falha
/// ao decodificar, renderiza [fallback] — tipicamente a ilustracao
/// vetorial (CustomPaint) do proprio mock. Assim os painters continuam
/// vivos como rede de seguranca e o mock nunca exibe caixa quebrada nem
/// flash branco.
///
/// As imagens vivem em `packages/feature_showcase/assets/<mock>/` e sao
/// declaradas no `pubspec.yaml` do pacote. Como os widgets do showcase
/// rodam dentro de `apps/landing` (outro pacote), o carregamento usa
/// sempre `package: 'feature_showcase'`. Formato esperado: WebP.
class ShowcasePhoto extends StatelessWidget {
  const ShowcasePhoto({
    required this.fallback,
    this.assetPath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.semanticLabel,
    this.fadeDuration = const Duration(milliseconds: 300),
    super.key,
  });

  /// Caminho do asset relativo ao pacote (ex.: `assets/realestate/casa1.webp`).
  /// Null cai direto no [fallback] — util enquanto a imagem real nao foi
  /// adicionada ao catalogo.
  final String? assetPath;

  /// Ilustracao vetorial exibida quando nao ha foto ou ela falha.
  final Widget fallback;

  final BoxFit fit;
  final double? width;
  final double? height;
  final String? semanticLabel;
  final Duration fadeDuration;

  static const String _package = 'feature_showcase';

  @override
  Widget build(BuildContext context) {
    final path = assetPath;
    if (path == null || path.isEmpty) return fallback;

    return Image.asset(
      path,
      package: _package,
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      // Decodifica no tamanho de layout pra nao segurar bitmap gigante em
      // memoria (fotos web podem vir grandes). Fade-in suave quando o
      // frame chega de forma assincrona.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: fadeDuration,
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
