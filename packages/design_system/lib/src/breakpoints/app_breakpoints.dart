/// Breakpoints em pixels logicos. Comparados com `MediaQuery.size.width`.
///
/// Convencao:
///   width &lt; mobile  ===> Breakpoint.mobile
///   width &lt; tablet  ===> Breakpoint.tablet
///   width &gt;= tablet ===> Breakpoint.desktop
abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double wide = 1600;
}
