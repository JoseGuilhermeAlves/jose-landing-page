import 'package:feature_showcase/src/data/properties_catalog.dart';
import 'package:feature_showcase/src/domain/property.dart';
import 'package:feature_showcase/src/presentation/realestate/realestate_bloc.dart';
import 'package:feature_showcase/src/presentation/realestate/solar_brand.dart';
import 'package:feature_showcase/src/presentation/realestate/solar_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Demo do template imobiliario — mock multi-tela da marca ficticia
/// "Solar" (paleta terracota/musgo/creme, ar de revista de arquitetura
/// com pegada de imobiliaria de campo). Substitui o demo single-screen
/// anterior por uma experiencia completa: home → listagem com filtros
/// → detalhe com planta baixa + mapa + corretor → form de contato.
///
/// Theme override aplica `SolarBrand.palette` localmente — todos os
/// widgets internos que leem `context.colors` recebem a paleta da
/// marca sem propagacao manual. Tipografia em serif nos displays;
/// body fica em sans pra legibilidade.
class RealEstateDemo extends StatelessWidget {
  const RealEstateDemo({this.properties, super.key});

  /// Override do catalogo. Quando null, usa [PropertiesCatalog.all].
  /// Permite que widget tests injetem catalogos enxutos sem mexer no
  /// dataset canonico.
  final List<Property>? properties;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: SolarBrand.buildTheme(context),
      child: BlocProvider(
        create: (_) => RealEstateBloc(
          initialProperties: properties ?? PropertiesCatalog.all,
        ),
        child: const SolarHomePage(),
      ),
    );
  }
}
