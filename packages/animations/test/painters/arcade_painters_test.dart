import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Animacao fixa: os painters ouvem o controller via super(repaint:), mas
  // shouldRepaint so confronta cores. AlwaysStoppedAnimation basta pra ler
  // _animation.value em paint().
  const anim = AlwaysStoppedAnimation<double>(0.4);

  group('ArcadeBackdropPainter', () {
    ArcadeBackdropPainter make({
      Color background = const Color(0xFF0B0118),
      Color gridNear = const Color(0xFFFF3CAC),
      Color gridFar = const Color(0xFF2DE2E6),
      Color starColor = const Color(0xFFE6E0FF),
    }) {
      return ArcadeBackdropPainter(
        animation: anim,
        background: background,
        gridNear: gridNear,
        gridFar: gridFar,
        starColor: starColor,
      );
    }

    test('shouldRepaint reage a cada cor', () {
      expect(make(background: const Color(0xFF000000)).shouldRepaint(make()),
          isTrue);
      expect(make(gridNear: const Color(0xFF000000)).shouldRepaint(make()),
          isTrue);
      expect(make(gridFar: const Color(0xFF000000)).shouldRepaint(make()),
          isTrue);
      expect(make(starColor: const Color(0xFF000000)).shouldRepaint(make()),
          isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      expect(make().shouldRepaint(make()), isFalse);
    });

    test('paint nao lanca em Size zero nem em tamanho normal', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make()
        ..paint(canvas, Size.zero)
        ..paint(canvas, const Size(1280, 800));
      recorder.endRecording().dispose();
    });
  });

  group('CrtPainter', () {
    CrtPainter make({Color tint = const Color(0xFFE6E0FF)}) =>
        CrtPainter(animation: anim, tint: tint);

    test('shouldRepaint reage ao tint', () {
      expect(make(tint: const Color(0xFF00FF00)).shouldRepaint(make()), isTrue);
    });

    test('shouldRepaint volta false quando o tint nao muda', () {
      expect(make().shouldRepaint(make()), isFalse);
    });

    test('paint cacheia por tamanho e nao lanca', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make()
        // Dois paints no mesmo tamanho exercitam o cache (_syncCache no-op).
        ..paint(canvas, const Size(800, 600))
        ..paint(canvas, const Size(800, 600))
        ..paint(canvas, const Size(400, 300));
      recorder.endRecording().dispose();
    });
  });
}
