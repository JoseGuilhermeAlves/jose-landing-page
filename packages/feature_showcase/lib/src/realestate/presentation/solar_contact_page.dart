import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/realestate/data/solar_brokers_catalog.dart';
import 'package:feature_showcase/src/realestate/domain/broker.dart';
import 'package:feature_showcase/src/realestate/domain/property.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_bloc.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_event.dart';
import 'package:feature_showcase/src/realestate/presentation/realestate_state.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_app_bar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_brand.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_broker_avatar.dart';
import 'package:feature_showcase/src/realestate/presentation/solar_confirmation_badge.dart';
import 'package:feature_showcase/src/shared/presentation/mock_body_constraint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'solar_contact_widgets.dart';

/// Tela de contato com o corretor — form simples (nome + telefone +
/// mensagem) com estado local; submit dispara `RealEstateContactSent`
/// no bloc, troca o conteudo pra success state com badge animado.
///
/// Se o usuario voltar pra esta tela depois de ja ter enviado (state
/// guarda os ids contatados), pula direto pro success.
class SolarContactPage extends StatefulWidget {
  const SolarContactPage({required this.property, super.key});

  final Property property;

  @override
  State<SolarContactPage> createState() => _SolarContactPageState();
}

class _SolarContactPageState extends State<SolarContactPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _messageController;
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _messageController = TextEditingController(
      text:
          'Olá, tenho interesse no imóvel "${widget.property.headline.isEmpty ? widget.property.neighborhood : widget.property.headline}". '
          'Poderia me passar mais detalhes?',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<RealEstateBloc>().add(
      RealEstateContactSent(widget.property.id),
    );
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final property = widget.property;
    final broker = SolarBrokersCatalog.byId(property.brokerId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const SolarAppBar(),
      body: MockBodyConstraint(
        child: SafeArea(
          top: false,
          child: BlocBuilder<RealEstateBloc, RealEstateState>(
            buildWhen: (a, b) =>
                a.hasSentContact(property.id) != b.hasSentContact(property.id),
            builder: (context, state) {
              final alreadySent = state.hasSentContact(property.id);
              if (_submitted || alreadySent) {
                return _SuccessState(
                  property: property,
                  broker: broker,
                  colors: colors,
                  textTheme: textTheme,
                );
              }
              return _FormState(
                property: property,
                broker: broker,
                colors: colors,
                textTheme: textTheme,
                formKey: _formKey,
                nameController: _nameController,
                phoneController: _phoneController,
                messageController: _messageController,
                onSubmit: _submit,
              );
            },
          ),
        ),
      ),
    );
  }
}
