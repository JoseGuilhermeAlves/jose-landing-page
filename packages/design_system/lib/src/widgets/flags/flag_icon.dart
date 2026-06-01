import 'package:flutter/material.dart';

import 'package:design_system/src/widgets/flags/brazil_flag_painter.dart';
import 'package:design_system/src/widgets/flags/china_flag_painter.dart';
import 'package:design_system/src/widgets/flags/france_flag_painter.dart';
import 'package:design_system/src/widgets/flags/germany_flag_painter.dart';
import 'package:design_system/src/widgets/flags/italy_flag_painter.dart';
import 'package:design_system/src/widgets/flags/japan_flag_painter.dart';
import 'package:design_system/src/widgets/flags/russia_flag_painter.dart';
import 'package:design_system/src/widgets/flags/spain_flag_painter.dart';
import 'package:design_system/src/widgets/flags/uk_flag_painter.dart';

class FlagIcon extends StatelessWidget {
  const FlagIcon({required this.locale, this.size = 24, super.key});

  final Locale locale;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CustomPaint(
        size: Size.square(size),
        painter: _painterFor(locale),
        isComplex: true,
      ),
    );
  }

  CustomPainter _painterFor(Locale locale) {
    return switch (locale.languageCode) {
      'pt' => const BrazilFlagPainter(),
      'en' => const UkFlagPainter(),
      'es' => const SpainFlagPainter(),
      'de' => const GermanyFlagPainter(),
      'zh' => const ChinaFlagPainter(),
      'ja' => const JapanFlagPainter(),
      'it' => const ItalyFlagPainter(),
      'fr' => const FranceFlagPainter(),
      'ru' => const RussiaFlagPainter(),
      _ => const BrazilFlagPainter(),
    };
  }
}
