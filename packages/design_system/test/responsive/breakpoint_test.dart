import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Breakpoint.forWidth', () {
    test('larguras menores que mobile resolvem para mobile', () {
      expect(Breakpoint.forWidth(0), Breakpoint.mobile);
      expect(Breakpoint.forWidth(375), Breakpoint.mobile);
      expect(Breakpoint.forWidth(599), Breakpoint.mobile);
    });

    test('larguras entre mobile e tablet resolvem para tablet', () {
      expect(Breakpoint.forWidth(600), Breakpoint.tablet);
      expect(Breakpoint.forWidth(768), Breakpoint.tablet);
      expect(Breakpoint.forWidth(899), Breakpoint.tablet);
    });

    test('larguras entre tablet e wide resolvem para desktop', () {
      expect(Breakpoint.forWidth(900), Breakpoint.desktop);
      expect(Breakpoint.forWidth(1280), Breakpoint.desktop);
      expect(Breakpoint.forWidth(1599), Breakpoint.desktop);
    });

    test('larguras a partir de wide resolvem para wide', () {
      expect(Breakpoint.forWidth(1600), Breakpoint.wide);
      expect(Breakpoint.forWidth(2560), Breakpoint.wide);
    });
  });

  group('Breakpoint flags', () {
    test('isHandheld cobre mobile e tablet', () {
      expect(Breakpoint.mobile.isHandheld, isTrue);
      expect(Breakpoint.tablet.isHandheld, isTrue);
      expect(Breakpoint.desktop.isHandheld, isFalse);
      expect(Breakpoint.wide.isHandheld, isFalse);
    });

    test('isDesktop cobre desktop e wide', () {
      expect(Breakpoint.desktop.isDesktop, isTrue);
      expect(Breakpoint.wide.isDesktop, isTrue);
      expect(Breakpoint.mobile.isDesktop, isFalse);
      expect(Breakpoint.tablet.isDesktop, isFalse);
    });
  });
}
