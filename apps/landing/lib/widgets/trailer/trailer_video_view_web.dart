import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

/// `<video>` nativo do navegador via platform view — controles, fullscreen
/// e streaming progressivo de graca, sem plugin. So e montado depois que
/// o visitante aperta play (ver `GameSection`), entao o elemento HTML nao
/// captura o scroll da pagina antes disso.
class TrailerVideoView extends StatelessWidget {
  const TrailerVideoView({
    required this.src,
    required this.poster,
    super.key,
  });

  final String src;
  final String poster;

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      tagName: 'video',
      onElementCreated: (element) {
        (element as web.HTMLVideoElement)
          ..src = src
          ..poster = poster
          ..controls = true
          ..autoplay = true
          ..playsInline = true
          ..preload = 'auto'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.backgroundColor = '#000'
          ..style.objectFit = 'contain';
      },
    );
  }
}
