import 'package:design_system/l10n/generated/app_localizations.dart';
import 'package:feature_tech/src/domain/stack_category.dart';
import 'package:feature_tech/src/domain/stack_item.dart';

abstract final class StackCatalog {
  static List<StackItem> all(AppLocalizations l10n) => [
    StackItem(
      name: 'Flutter',
      version: '>=3.38',
      role: l10n.stack_flutter_role,
      category: StackCategory.framework,
    ),
    StackItem(
      name: 'Dart',
      version: '>=3.10',
      role: l10n.stack_dart_role,
      category: StackCategory.framework,
    ),
    StackItem(
      name: 'Platform Channels',
      version: 'Flutter API',
      role: l10n.stack_platformChannels_role,
      category: StackCategory.framework,
    ),

    StackItem(
      name: 'flutter_bloc',
      version: '9.x',
      role: l10n.stack_flutterBloc_role,
      category: StackCategory.state,
    ),
    StackItem(
      name: 'Provider',
      version: '6.x',
      role: l10n.stack_provider_role,
      category: StackCategory.state,
    ),
    StackItem(
      name: 'Riverpod',
      version: '2.x',
      role: l10n.stack_riverpod_role,
      category: StackCategory.state,
    ),
    StackItem(
      name: 'GetX',
      version: '4.x',
      role: l10n.stack_getx_role,
      category: StackCategory.state,
    ),
    StackItem(
      name: 'MobX',
      version: '2.x',
      role: l10n.stack_mobx_role,
      category: StackCategory.state,
    ),
    StackItem(
      name: 'bloc_test',
      version: '10.x',
      role: l10n.stack_blocTest_role,
      category: StackCategory.quality,
    ),

    StackItem(
      name: 'go_router',
      version: '16.2.4',
      role: l10n.stack_goRouter_role,
      category: StackCategory.routing,
    ),
    StackItem(
      name: 'flutter_modular',
      version: '6.x',
      role: l10n.stack_flutterModular_role,
      category: StackCategory.routing,
    ),

    StackItem(
      name: 'CustomPainter',
      version: 'Flutter API',
      role: l10n.stack_customPainter_role,
      category: StackCategory.graphics,
    ),
    StackItem(
      name: 'Animations',
      version: 'Flutter API',
      role: l10n.stack_animations_role,
      category: StackCategory.graphics,
    ),

    StackItem(
      name: 'SQLite',
      version: 'sqflite',
      role: l10n.stack_sqlite_role,
      category: StackCategory.persistence,
    ),
    StackItem(
      name: 'Hive',
      version: '4.x',
      role: l10n.stack_hive_role,
      category: StackCategory.persistence,
    ),
    StackItem(
      name: 'shared_preferences',
      version: '2.x',
      role: l10n.stack_sharedPreferences_role,
      category: StackCategory.persistence,
    ),
    StackItem(
      name: 'Firebase',
      version: 'FlutterFire',
      role: l10n.stack_firebase_role,
      category: StackCategory.persistence,
    ),

    StackItem(
      name: 'Clean Architecture',
      version: 'Padrao',
      role: l10n.stack_cleanArch_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'MVVM',
      version: 'Padrao',
      role: l10n.stack_mvvm_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'SOLID',
      version: 'Principios',
      role: l10n.stack_solid_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'Monorepo',
      version: 'Pub Workspaces',
      role: l10n.stack_monorepo_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'get_it',
      version: '8.x',
      role: l10n.stack_getIt_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'injectable',
      version: '2.x',
      role: l10n.stack_injectable_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'Design System',
      version: 'Tokens',
      role: l10n.stack_designSystem_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'SDUI',
      version: 'Server-Driven',
      role: l10n.stack_sdui_role,
      category: StackCategory.architecture,
    ),
    StackItem(
      name: 'Feature-First',
      version: 'Organizacao',
      role: l10n.stack_featureFirst_role,
      category: StackCategory.architecture,
    ),

    StackItem(
      name: 'Datadog',
      version: 'SaaS',
      role: l10n.stack_datadog_role,
      category: StackCategory.observability,
    ),

    StackItem(
      name: 'very_good_analysis',
      version: '6.0.0',
      role: l10n.stack_vga_role,
      category: StackCategory.quality,
    ),
    StackItem(
      name: 'flutter_test',
      version: 'SDK',
      role: l10n.stack_flutterTest_role,
      category: StackCategory.quality,
    ),
    StackItem(
      name: 'mocktail',
      version: '1.x',
      role: l10n.stack_mocktail_role,
      category: StackCategory.quality,
    ),
    StackItem(
      name: 'integration_test',
      version: 'SDK',
      role: l10n.stack_integrationTest_role,
      category: StackCategory.quality,
    ),

    StackItem(
      name: 'Melos',
      version: '7.3.0',
      role: l10n.stack_melos_role,
      category: StackCategory.tooling,
    ),
    StackItem(
      name: 'GitHub Actions',
      version: 'CI',
      role: l10n.stack_githubActions_role,
      category: StackCategory.tooling,
    ),
    StackItem(
      name: 'Fastlane',
      version: 'CI/CD',
      role: l10n.stack_fastlane_role,
      category: StackCategory.tooling,
    ),
  ];

  static Map<StackCategory, List<StackItem>> byCategory(AppLocalizations l10n) {
    final items = all(l10n);
    final map = <StackCategory, List<StackItem>>{};
    for (final category in StackCategory.values) {
      map[category] = items.where((i) => i.category == category).toList();
    }
    return map;
  }
}
