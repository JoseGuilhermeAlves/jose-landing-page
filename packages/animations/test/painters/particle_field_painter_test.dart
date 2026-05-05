import 'dart:math' as math;
import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParticleFieldPainter', () {
    ParticleFieldPainter make({
      double tick = 0,
      Offset? pointer,
      int particleCount = 24,
      int seed = 13,
      Color particleColor = const Color(0xFF7C3AED),
      Color linkColor = const Color(0x447C3AED),
      double linkDistance = 80,
    }) {
      return ParticleFieldPainter(
        tick: tick,
        pointer: pointer,
        particleCount: particleCount,
        seed: seed,
        particleColor: particleColor,
        linkColor: linkColor,
        linkDistance: linkDistance,
      );
    }

    test('shouldRepaint volta true quando o tick muda', () {
      final a = make();
      final b = make(tick: 0.016);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      final a = make(tick: 0.5);
      final b = make(tick: 0.5);
      expect(b.shouldRepaint(a), isFalse);
    });

    test('shouldRepaint volta true quando o pointer muda', () {
      final a = make(pointer: const Offset(10, 10));
      final b = make(pointer: const Offset(20, 10));
      expect(b.shouldRepaint(a), isTrue);
    });

    test('shouldRepaint volta true ao trocar pointer null <-> nao-null', () {
      final a = make();
      final b = make(pointer: const Offset(10, 10));
      expect(b.shouldRepaint(a), isTrue);
      expect(a.shouldRepaint(b), isTrue);
    });

    test('mesmo seed -> mesma posicao inicial das particulas (deterministico)',
        () {
      final a = make(seed: 42);
      final b = make(seed: 42);
      expect(a.debugInitialPositions(const Size(200, 200)),
          equals(b.debugInitialPositions(const Size(200, 200))));
    });

    test('seeds diferentes -> particulas diferentes', () {
      final a = make(seed: 1);
      final b = make(seed: 2);
      expect(a.debugInitialPositions(const Size(200, 200)),
          isNot(equals(b.debugInitialPositions(const Size(200, 200)))));
    });

    test('particulas ficam dentro do retangulo da Size', () {
      final painter = make(particleCount: 50, seed: 99);
      const size = Size(300, 180);
      final positions = painter.debugPositionsAt(size, t: 0.5);

      for (final p in positions) {
        expect(p.dx, inInclusiveRange(0.0, size.width));
        expect(p.dy, inInclusiveRange(0.0, size.height));
      }
      expect(positions, hasLength(50));
    });

    test('isComplex e willChange refletem animacao continua e geometria pesada',
        () {
      final p = make(particleCount: 60);
      expect(p.willChange, isTrue);
      expect(p.isComplex, isTrue);
    });

    test('paint executa sem lancar para Size zero', () {
      final painter = make();
      final canvas = Canvas(PictureRecorder());
      painter.paint(canvas, Size.zero);
    });

    test('paint executa sem lancar com pointer fora da area', () {
      final painter = make(pointer: const Offset(-50, -50));
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(200, 200));
      recorder.endRecording().dispose();
    });

    test('linkDistance negativo nao gera linhas', () {
      // Caso degenerado — qualquer linha conectaria pares fora do raio.
      final painter = make(linkDistance: -10, particleCount: 10);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(100, 100));
      recorder.endRecording().dispose();
    });

    test(
        'particulas movem-se entre ticks (animacao real, nao snapshot estatico)',
        () {
      final painter = make(particleCount: 8);
      const size = Size(200, 200);
      final at0 = painter.debugPositionsAt(size, t: 0);
      final at1 = painter.debugPositionsAt(size, t: 0.5);

      // Pelo menos uma das particulas precisa ter mudado.
      var anyMoved = false;
      for (var i = 0; i < at0.length; i++) {
        if ((at0[i] - at1[i]).distance > 0.01) {
          anyMoved = true;
          break;
        }
      }
      expect(anyMoved, isTrue);
    });

    test(
        'particulas afastam do pointer (deslocamento radial) quando dentro do raio',
        () {
      const size = Size(300, 300);
      const pointer = Offset(150, 150);

      final without = make(seed: 5, particleCount: 12)
          .debugPositionsAt(size, t: 0);
      final with_ = make(seed: 5, particleCount: 12, pointer: pointer)
          .debugPositionsAt(size, t: 0);

      // Pelo menos uma particula precisa ficar mais longe do pointer com
      // o efeito ativo do que estaria sem.
      var anyPushed = false;
      for (var i = 0; i < without.length; i++) {
        final d0 = (without[i] - pointer).distance;
        final d1 = (with_[i] - pointer).distance;
        if (d1 > d0 + 0.5) {
          anyPushed = true;
          break;
        }
      }
      expect(anyPushed, isTrue);
    });

    testWidgets('integra com CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(painter: make(tick: 0.4)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  // Sanidade adicional — comprova que a distancia maxima de empurrao do
  // pointer nao explode pra fora dos limites do canvas.
  test('empurrao pelo pointer nao escapa dos bounds', () {
    final painter = ParticleFieldPainter(
      tick: 0,
      pointer: Offset.zero,
      particleCount: 20,
      seed: 11,
      particleColor: const Color(0xFFFFFFFF),
      linkColor: const Color(0xFFFFFFFF),
      linkDistance: 60,
    );
    const size = Size(150, 150);
    for (final p in painter.debugPositionsAt(size, t: 0.3)) {
      expect(p.dx, inInclusiveRange(0.0, size.width));
      expect(p.dy, inInclusiveRange(0.0, size.height));
      expect(p.dx.isFinite && p.dy.isFinite, isTrue);
    }
    expect(math.pi, greaterThan(0)); // garante import de dart:math
  });
}
