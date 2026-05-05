import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:landing/router/app_router.dart';

/// Raiz do app. Envolve [MaterialApp.router] com o [AppTheme] do
/// design system. Mantemos a instancia do [GoRouter] como campo final
/// para evitar reconstrucao a cada rebuild do app.
class LandingApp extends StatefulWidget {
  const LandingApp({super.key});

  @override
  State<LandingApp> createState() => _LandingAppState();
}

class _LandingAppState extends State<LandingApp> {
  late final GoRouter _router = AppRouter.create();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jose Guilherme Alves — Flutter Developer',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
    );
  }
}
