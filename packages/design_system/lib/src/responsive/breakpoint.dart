import 'package:design_system/src/breakpoints/app_breakpoints.dart';
import 'package:flutter/widgets.dart';

/// Faixas de viewport. Resolva a partir da largura logica do MediaQuery.
enum Breakpoint {
  mobile,
  tablet,
  desktop,
  wide;

  /// Resolve o breakpoint a partir de uma largura em pixels logicos.
  static Breakpoint forWidth(double width) {
    if (width < AppBreakpoints.mobile) return Breakpoint.mobile;
    if (width < AppBreakpoints.tablet) return Breakpoint.tablet;
    if (width < AppBreakpoints.wide) return Breakpoint.desktop;
    return Breakpoint.wide;
  }

  bool get isMobile => this == Breakpoint.mobile;
  bool get isTablet => this == Breakpoint.tablet;
  bool get isDesktop => this == Breakpoint.desktop || this == Breakpoint.wide;
  bool get isHandheld => isMobile || isTablet;
}

/// Acesso conveniente: `context.breakpoint`, `context.isMobile`.
extension BreakpointContext on BuildContext {
  Breakpoint get breakpoint =>
      Breakpoint.forWidth(MediaQuery.sizeOf(this).width);

  bool get isMobile => breakpoint.isMobile;
  bool get isTablet => breakpoint.isTablet;
  bool get isDesktop => breakpoint.isDesktop;
  bool get isHandheld => breakpoint.isHandheld;

  /// Seleciona um valor por breakpoint. Hoje so divide mobile vs resto
  /// — centraliza o branch `isMobile ?` espalhado em spacing, fontes,
  /// alturas e aspect ratios. Args nomeados removem a ambiguidade de
  /// ordem do ternario. Funciona com qualquer T (double, TextStyle?,
  /// int, etc.). Se um dia entrar um terceiro ponto de corte, e o unico
  /// lugar a mudar.
  T responsive<T>({required T mobile, required T desktop}) =>
      isMobile ? mobile : desktop;
}
