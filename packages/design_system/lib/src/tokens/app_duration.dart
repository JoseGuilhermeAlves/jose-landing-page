/// Duracoes padrao de animacao. Use em transitions, AnimatedContainer, etc.
abstract final class AppDuration {
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration deliberate = Duration(milliseconds: 800);
}
