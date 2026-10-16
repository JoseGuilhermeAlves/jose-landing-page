import 'package:flutter/widgets.dart';

/// Fallback fora do web (testes VM): sem `<video>` nativo, so um box vazio
/// no tamanho do poster. O build real usa `trailer_video_view_web.dart`.
class TrailerVideoView extends StatelessWidget {
  const TrailerVideoView({
    required this.src,
    required this.poster,
    super.key,
  });

  final String src;
  final String poster;

  @override
  Widget build(BuildContext context) => const SizedBox.expand();
}
