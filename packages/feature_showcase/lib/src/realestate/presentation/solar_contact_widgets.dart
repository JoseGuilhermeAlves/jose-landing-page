part of 'solar_contact_page.dart';

// =============================================================================
// FORM
// =============================================================================

class _FormState extends StatelessWidget {
  const _FormState({
    required this.property,
    required this.broker,
    required this.colors,
    required this.textTheme,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.messageController,
    required this.onSubmit,
  });

  final Property property;
  final Broker? broker;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController messageController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'falar com o corretor'.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tem interesse neste imovel?',
            key: const Key('solar-contact-title'),
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'O corretor entra em contato em ate 4 horas uteis. Sem '
            'compromisso — voce nao paga nada pelo atendimento.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
          if (broker != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _BrokerRow(broker: broker!, colors: colors, textTheme: textTheme),
          ],
          const SizedBox(height: AppSpacing.xl),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  controller: nameController,
                  label: 'Nome',
                  hint: 'Seu nome',
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe seu nome'
                      : null,
                  fieldKey: const Key('solar-contact-name'),
                ),
                const SizedBox(height: AppSpacing.md),
                _Field(
                  controller: phoneController,
                  label: 'Telefone',
                  hint: '(11) 99999-0000',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 8)
                      ? 'Informe um telefone valido'
                      : null,
                  fieldKey: const Key('solar-contact-phone'),
                ),
                const SizedBox(height: AppSpacing.md),
                _Field(
                  controller: messageController,
                  label: 'Mensagem',
                  hint: 'Conte rapidamente o que quer saber',
                  maxLines: context.responsive(mobile: 3, desktop: 4),
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'Mensagem curta demais'
                      : null,
                  fieldKey: const Key('solar-contact-message'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('solar-contact-submit'),
            label: 'Enviar pedido de contato',
            icon: Icons.send_rounded,
            size: AppButtonSize.large,
            expand: true,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    required this.fieldKey,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?) validator;
  final Key fieldKey;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceMuted,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: maxLines,
          validator: validator,
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrokerRow extends StatelessWidget {
  const _BrokerRow({
    required this.broker,
    required this.colors,
    required this.textTheme,
  });

  final Broker broker;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          SolarBrokerAvatar(
            monogram: broker.monogram,
            size: 44,
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  broker.name,
                  style: textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontFamily: SolarBrand.displayFontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  broker.creci,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUCCESS
// =============================================================================

class _SuccessState extends StatelessWidget {
  const _SuccessState({
    required this.property,
    required this.broker,
    required this.colors,
    required this.textTheme,
  });

  final Property property;
  final Broker? broker;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: SolarConfirmationBadge(
              fillColor: colors.primary,
              checkColor: colors.onPrimary,
              ringColor: colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'pedido enviado'.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: colors.accent,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'O corretor recebeu seu interesse.',
            key: const Key('solar-contact-success-title'),
            style: textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontFamily: SolarBrand.displayFontFamily,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.4,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            broker == null
                ? 'Em ate 4 horas uteis voce recebe o retorno por telefone '
                      'ou e-mail.'
                : '${broker!.name} retorna em ate 4 horas uteis pelo telefone '
                      'informado.',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Imovel',
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceMuted,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  property.headline.isEmpty
                      ? '${property.type.label} em ${property.neighborhood}'
                      : property.headline,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.onSurface,
                    fontFamily: SolarBrand.displayFontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  property.formattedPrice,
                  style: textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontFamily: SolarBrand.displayFontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            key: const Key('solar-contact-success-back'),
            label: 'Voltar ao imovel',
            icon: Icons.arrow_back_rounded,
            size: AppButtonSize.large,
            expand: true,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }
}
