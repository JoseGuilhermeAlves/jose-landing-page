import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @common_cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get common_cancel;

  /// No description provided for @common_back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get common_back;

  /// No description provided for @common_close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get common_close;

  /// No description provided for @common_continue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get common_continue;

  /// No description provided for @common_confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get common_confirm;

  /// No description provided for @common_retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get common_retry;

  /// No description provided for @common_loadMore.
  ///
  /// In pt, this message translates to:
  /// **'Carregar mais'**
  String get common_loadMore;

  /// No description provided for @common_save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get common_edit;

  /// No description provided for @common_share.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar'**
  String get common_share;

  /// No description provided for @common_loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando…'**
  String get common_loading;

  /// No description provided for @common_empty.
  ///
  /// In pt, this message translates to:
  /// **'Sem itens por aqui.'**
  String get common_empty;

  /// No description provided for @common_genericError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente novamente em instantes.'**
  String get common_genericError;

  /// No description provided for @common_openInNew.
  ///
  /// In pt, this message translates to:
  /// **'Abrir em nova guia'**
  String get common_openInNew;

  /// No description provided for @common_search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get common_search;

  /// No description provided for @common_semanticsClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get common_semanticsClose;

  /// No description provided for @common_semanticsLoadingSpinner.
  ///
  /// In pt, this message translates to:
  /// **'Carregando conteúdo'**
  String get common_semanticsLoadingSpinner;

  /// No description provided for @hero_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Front end mobile · Flutter'**
  String get hero_eyebrow;

  /// No description provided for @hero_headline1.
  ///
  /// In pt, this message translates to:
  /// **'Front end mobile em Flutter.'**
  String get hero_headline1;

  /// No description provided for @hero_headline2.
  ///
  /// In pt, this message translates to:
  /// **'Do MVP ao app em produção.'**
  String get hero_headline2;

  /// No description provided for @hero_bio.
  ///
  /// In pt, this message translates to:
  /// **'Construí o front end completo de cinco apps de operação de varejo B2B — do design ao deploy — e hoje atuo em um produto financeiro de larga escala. Arquitetura por feature, estado com Bloc, fluidez em device real.'**
  String get hero_bio;

  /// No description provided for @hero_scopeLine.
  ///
  /// In pt, this message translates to:
  /// **'Integro com APIs e ecossistemas existentes.'**
  String get hero_scopeLine;

  /// No description provided for @hero_scrollHint.
  ///
  /// In pt, this message translates to:
  /// **'role para continuar'**
  String get hero_scrollHint;

  /// No description provided for @hero_ctaContact.
  ///
  /// In pt, this message translates to:
  /// **'Falar comigo'**
  String get hero_ctaContact;

  /// No description provided for @hero_ctaProjects.
  ///
  /// In pt, this message translates to:
  /// **'Ver projetos'**
  String get hero_ctaProjects;

  /// No description provided for @hero_trustYearsValue.
  ///
  /// In pt, this message translates to:
  /// **'6'**
  String get hero_trustYearsValue;

  /// No description provided for @hero_trustYearsLabel.
  ///
  /// In pt, this message translates to:
  /// **'anos de Flutter'**
  String get hero_trustYearsLabel;

  /// No description provided for @hero_trustAppsValue.
  ///
  /// In pt, this message translates to:
  /// **'5'**
  String get hero_trustAppsValue;

  /// No description provided for @hero_trustAppsLabel.
  ///
  /// In pt, this message translates to:
  /// **'apps de varejo em produção'**
  String get hero_trustAppsLabel;

  /// No description provided for @hero_trustCanvasValue.
  ///
  /// In pt, this message translates to:
  /// **'15+'**
  String get hero_trustCanvasValue;

  /// No description provided for @hero_trustCanvasLabel.
  ///
  /// In pt, this message translates to:
  /// **'telas demo no showcase'**
  String get hero_trustCanvasLabel;

  /// No description provided for @hero_portraitSemantics.
  ///
  /// In pt, this message translates to:
  /// **'Foto de Jose Guilherme Alves'**
  String get hero_portraitSemantics;

  /// No description provided for @about_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get about_eyebrow;

  /// No description provided for @about_title.
  ///
  /// In pt, this message translates to:
  /// **'Quem'**
  String get about_title;

  /// No description provided for @about_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'entrega.'**
  String get about_titleAccent;

  /// No description provided for @about_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Front end mobile com Flutter há 6 anos. Foco em entregar app robusto, com escopo claro e expectativa alinhada desde o kickoff.'**
  String get about_subtitle;

  /// No description provided for @about_domainsMapLabel.
  ///
  /// In pt, this message translates to:
  /// **'Onde já entreguei'**
  String get about_domainsMapLabel;

  /// No description provided for @about_deliveryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como eu entrego'**
  String get about_deliveryTitle;

  /// No description provided for @about_bioName.
  ///
  /// In pt, this message translates to:
  /// **'José Guilherme Alves'**
  String get about_bioName;

  /// No description provided for @about_bioTitle.
  ///
  /// In pt, this message translates to:
  /// **'Front end mobile · Flutter Developer · Brasil'**
  String get about_bioTitle;

  /// No description provided for @about_bioLead.
  ///
  /// In pt, this message translates to:
  /// **'Seis anos com a mesma régua — front end mobile em Flutter — aplicada em contextos que não se parecem.'**
  String get about_bioLead;

  /// No description provided for @about_factRetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Varejo B2B (5 anos)'**
  String get about_factRetailTitle;

  /// No description provided for @about_factRetailBody.
  ///
  /// In pt, this message translates to:
  /// **'Front end completo de cinco apps de operação: estoque, distribuição entre unidades, vendas e comunicação interna. Do design ao deploy, em time pequeno.'**
  String get about_factRetailBody;

  /// No description provided for @about_factFieldTitle.
  ///
  /// In pt, this message translates to:
  /// **'Campo offline-first'**
  String get about_factFieldTitle;

  /// No description provided for @about_factFieldBody.
  ///
  /// In pt, this message translates to:
  /// **'Coleta de dados com sincronização sob rede instável.'**
  String get about_factFieldBody;

  /// No description provided for @about_factPublicTitle.
  ///
  /// In pt, this message translates to:
  /// **'Setor público'**
  String get about_factPublicTitle;

  /// No description provided for @about_factPublicBody.
  ///
  /// In pt, this message translates to:
  /// **'Serviço ao cidadão com fluxo sensível de dados.'**
  String get about_factPublicBody;

  /// No description provided for @about_factToolsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ferramentas internas'**
  String get about_factToolsTitle;

  /// No description provided for @about_factToolsBody.
  ///
  /// In pt, this message translates to:
  /// **'Produtividade com gamificação.'**
  String get about_factToolsBody;

  /// No description provided for @about_factFintechTitle.
  ///
  /// In pt, this message translates to:
  /// **'Fintech de larga escala (atual)'**
  String get about_factFintechTitle;

  /// No description provided for @about_factFintechBody.
  ///
  /// In pt, this message translates to:
  /// **'Produto financeiro em monorepo com design system próprio.'**
  String get about_factFintechBody;

  /// No description provided for @about_bioClose.
  ///
  /// In pt, this message translates to:
  /// **'Domínios distintos, mesma entrega: o front end mobile inteiro. Backend permanece com o time — eu integro com ele.'**
  String get about_bioClose;

  /// No description provided for @delivery_entrega_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'ENTREGA'**
  String get delivery_entrega_eyebrow;

  /// No description provided for @delivery_entrega_title.
  ///
  /// In pt, this message translates to:
  /// **'Escopo claro,'**
  String get delivery_entrega_title;

  /// No description provided for @delivery_entrega_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'expectativa alinhada.'**
  String get delivery_entrega_titleAccent;

  /// No description provided for @delivery_entrega_body.
  ///
  /// In pt, this message translates to:
  /// **'Cada projeto começa pelo recorte: o que entra, o que fica de fora, e como cada decisão amarra um critério de aceite. Sem isso, sprint vira corrida de prazo. Trabalho com PO e design desde o kickoff para que o backlog reflita o que vai para produção — não o que parece bonito no protótipo.'**
  String get delivery_entrega_body;

  /// No description provided for @delivery_craft_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'CRAFT'**
  String get delivery_craft_eyebrow;

  /// No description provided for @delivery_craft_title.
  ///
  /// In pt, this message translates to:
  /// **'Arquitetura e'**
  String get delivery_craft_title;

  /// No description provided for @delivery_craft_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'boas práticas.'**
  String get delivery_craft_titleAccent;

  /// No description provided for @delivery_craft_body.
  ///
  /// In pt, this message translates to:
  /// **'Decisões de arquitetura explícitas: Clean Architecture por feature e SOLID definindo os limites de cada classe. Patterns de código consistentes (Bloc/Cubit, repositório, injeção por construtor) e desenvolvimento orientado a comportamento (BDD) e a especificação (SDD) — cada feature nasce com contrato e teste, não com improviso.'**
  String get delivery_craft_body;

  /// No description provided for @delivery_collab_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'COLABORAÇÃO'**
  String get delivery_collab_eyebrow;

  /// No description provided for @delivery_collab_title.
  ///
  /// In pt, this message translates to:
  /// **'No time de produto'**
  String get delivery_collab_title;

  /// No description provided for @delivery_collab_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'ou no Flutter inteiro.'**
  String get delivery_collab_titleAccent;

  /// No description provided for @delivery_collab_body.
  ///
  /// In pt, this message translates to:
  /// **'Em time grande entro como front end mobile com escopo de feature ou stewardship arquitetural. Em time pequeno (varejo B2B, 5 anos) cuidei do Flutter inteiro — do design ao deploy, integrando APIs já existentes e ajudando a moldar contratos novos quando o caminho era esse. Ajusto-me ao tamanho do time, não ao contrário.'**
  String get delivery_collab_body;

  /// No description provided for @domain_fintech_label.
  ///
  /// In pt, this message translates to:
  /// **'Serviço financeiro'**
  String get domain_fintech_label;

  /// No description provided for @domain_fintech_blurb.
  ///
  /// In pt, this message translates to:
  /// **'Produto financeiro de larga escala no front end Flutter — monorepo, design system próprio e arquitetura por feature, foco em correção e consistência sob alto volume.'**
  String get domain_fintech_blurb;

  /// No description provided for @domain_publicServices_label.
  ///
  /// In pt, this message translates to:
  /// **'Setor público'**
  String get domain_publicServices_label;

  /// No description provided for @domain_publicServices_blurb.
  ///
  /// In pt, this message translates to:
  /// **'Serviço público ao cidadão — fluxo sensível de dados com Bloc, foco em confiabilidade e privacidade.'**
  String get domain_publicServices_blurb;

  /// No description provided for @domain_sanitation_label.
  ///
  /// In pt, this message translates to:
  /// **'Operação em campo'**
  String get domain_sanitation_label;

  /// No description provided for @domain_sanitation_blurb.
  ///
  /// In pt, this message translates to:
  /// **'Coleta de dados em campo offline-first — Flutter Modular e Provider, sincronização confiável sob rede instável.'**
  String get domain_sanitation_blurb;

  /// No description provided for @domain_retail_label.
  ///
  /// In pt, this message translates to:
  /// **'Varejo B2B'**
  String get domain_retail_label;

  /// No description provided for @domain_retail_blurb.
  ///
  /// In pt, this message translates to:
  /// **'Front end Flutter inteiro — do design ao deploy, por cinco anos. Cinco apps de operação: estoque, distribuição entre unidades, vendas e comunicação interna.'**
  String get domain_retail_blurb;

  /// No description provided for @services_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Serviços'**
  String get services_eyebrow;

  /// No description provided for @services_title.
  ///
  /// In pt, this message translates to:
  /// **'Front end mobile.'**
  String get services_title;

  /// No description provided for @services_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'Do brief ao deploy.'**
  String get services_titleAccent;

  /// No description provided for @services_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Apps mobile com Flutter, versão web/PWA quando aplicável, integração com APIs existentes e consultoria de arquitetura. Backend e infra permanecem com o time do cliente.'**
  String get services_subtitle;

  /// No description provided for @services_mobile_title.
  ///
  /// In pt, this message translates to:
  /// **'Front end mobile'**
  String get services_mobile_title;

  /// No description provided for @services_mobile_description.
  ///
  /// In pt, this message translates to:
  /// **'Android nativo via Flutter — performance e consistência de UX em devices reais.'**
  String get services_mobile_description;

  /// No description provided for @services_web_title.
  ///
  /// In pt, this message translates to:
  /// **'Web Apps & PWA'**
  String get services_web_title;

  /// No description provided for @services_web_description.
  ///
  /// In pt, this message translates to:
  /// **'O mesmo código Flutter como app web — instalável como PWA, rápido e responsivo.'**
  String get services_web_description;

  /// No description provided for @services_integrations_title.
  ///
  /// In pt, this message translates to:
  /// **'Integração com APIs'**
  String get services_integrations_title;

  /// No description provided for @services_integrations_description.
  ///
  /// In pt, this message translates to:
  /// **'REST, OAuth, Bluetooth e NFC — integro o app mobile a APIs e periféricos já existentes.'**
  String get services_integrations_description;

  /// No description provided for @services_maintenance_title.
  ///
  /// In pt, this message translates to:
  /// **'Manutenção e evolução'**
  String get services_maintenance_title;

  /// No description provided for @services_maintenance_description.
  ///
  /// In pt, this message translates to:
  /// **'Refator, estabilização e novas features no front end de apps já em produção.'**
  String get services_maintenance_description;

  /// No description provided for @services_consulting_title.
  ///
  /// In pt, this message translates to:
  /// **'Consultoria mobile'**
  String get services_consulting_title;

  /// No description provided for @services_consulting_description.
  ///
  /// In pt, this message translates to:
  /// **'Arquitetura, code review e definição de stack — apoio técnico antes da feature virar débito.'**
  String get services_consulting_description;

  /// No description provided for @contact_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Contato'**
  String get contact_eyebrow;

  /// No description provided for @contact_title.
  ///
  /// In pt, this message translates to:
  /// **'Vamos'**
  String get contact_title;

  /// No description provided for @contact_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'conversar?'**
  String get contact_titleAccent;

  /// No description provided for @contact_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Conversas sobre projetos e parcerias em Flutter são bem-vindas. Email e LinkedIn são os canais mais rápidos; respondo em até um dia útil.'**
  String get contact_subtitle;

  /// No description provided for @contact_ctaWhatsapp.
  ///
  /// In pt, this message translates to:
  /// **'WhatsApp direto'**
  String get contact_ctaWhatsapp;

  /// No description provided for @contact_ctaEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get contact_ctaEmail;

  /// No description provided for @contact_ctaLinkedin.
  ///
  /// In pt, this message translates to:
  /// **'LinkedIn — histórico completo'**
  String get contact_ctaLinkedin;

  /// No description provided for @contact_ctaGithub.
  ///
  /// In pt, this message translates to:
  /// **'GitHub'**
  String get contact_ctaGithub;

  /// No description provided for @contact_ctaResume.
  ///
  /// In pt, this message translates to:
  /// **'Baixar currículo (PDF)'**
  String get contact_ctaResume;

  /// No description provided for @nav_showcase.
  ///
  /// In pt, this message translates to:
  /// **'Showcase'**
  String get nav_showcase;

  /// No description provided for @nav_about.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get nav_about;

  /// No description provided for @nav_engineering.
  ///
  /// In pt, this message translates to:
  /// **'Engenharia'**
  String get nav_engineering;

  /// No description provided for @nav_contact.
  ///
  /// In pt, this message translates to:
  /// **'Contato'**
  String get nav_contact;

  /// No description provided for @nav_backToTop.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao topo'**
  String get nav_backToTop;

  /// No description provided for @nav_ctaContact.
  ///
  /// In pt, this message translates to:
  /// **'Contato'**
  String get nav_ctaContact;

  /// No description provided for @footer_madeWith.
  ///
  /// In pt, this message translates to:
  /// **'Feito em Flutter'**
  String get footer_madeWith;

  /// No description provided for @engineering_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Engenharia'**
  String get engineering_eyebrow;

  /// No description provided for @engineering_title.
  ///
  /// In pt, this message translates to:
  /// **'A stack que sustenta'**
  String get engineering_title;

  /// No description provided for @engineering_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'cada decisão do projeto.'**
  String get engineering_titleAccent;

  /// No description provided for @engineering_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tecnologias que uso em produção e outras que conheço de perto. Toque em qualquer tile para saber mais.'**
  String get engineering_subtitle;

  /// No description provided for @engineering_githubButton.
  ///
  /// In pt, this message translates to:
  /// **'Ver meu GitHub'**
  String get engineering_githubButton;

  /// No description provided for @showcase_eyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Showcase'**
  String get showcase_eyebrow;

  /// No description provided for @showcase_title.
  ///
  /// In pt, this message translates to:
  /// **'Três nichos,'**
  String get showcase_title;

  /// No description provided for @showcase_titleAccent.
  ///
  /// In pt, this message translates to:
  /// **'três protótipos.'**
  String get showcase_titleAccent;

  /// No description provided for @showcase_subtitle.
  ///
  /// In pt, this message translates to:
  /// **'Três marcas fictícias, três identidades visuais, mais de quinze telas navegáveis — e zero backend, por decisão. Tudo que se move aqui é front end Flutter: estado com Bloc e Custom Painters dedicados. Toque em um card para abrir.'**
  String get showcase_subtitle;

  /// No description provided for @showcase_financeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Investimentos'**
  String get showcase_financeLabel;

  /// No description provided for @showcase_financeDescription.
  ///
  /// In pt, this message translates to:
  /// **'Mira — watchlist, candlestick interativo com crosshair, envio de ordem e portfolio com donut de alocação.'**
  String get showcase_financeDescription;

  /// No description provided for @showcase_deliveryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Delivery'**
  String get showcase_deliveryLabel;

  /// No description provided for @showcase_deliveryDescription.
  ///
  /// In pt, this message translates to:
  /// **'Aurora — marketplace de hortifruti com mapa animado, timeline do pedido e histórico.'**
  String get showcase_deliveryDescription;

  /// No description provided for @showcase_schedulingLabel.
  ///
  /// In pt, this message translates to:
  /// **'Agendamento'**
  String get showcase_schedulingLabel;

  /// No description provided for @showcase_schedulingDescription.
  ///
  /// In pt, this message translates to:
  /// **'Vitral — estúdio de serviços com calendário interativo, relógio animado e confirmação com badge.'**
  String get showcase_schedulingDescription;

  /// No description provided for @showcase_fitnessLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fitness'**
  String get showcase_fitnessLabel;

  /// No description provided for @showcase_fitnessDescription.
  ///
  /// In pt, this message translates to:
  /// **'Pulso — recovery dashboard, logger set-a-set com RPE e periodização de 8 semanas.'**
  String get showcase_fitnessDescription;

  /// No description provided for @showcase_realestateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Imobiliária'**
  String get showcase_realestateLabel;

  /// No description provided for @showcase_realestateDescription.
  ///
  /// In pt, this message translates to:
  /// **'Solar — imobiliária com planta baixa gerada por dados, mapa de bairro e jornada da busca ao contato com o corretor.'**
  String get showcase_realestateDescription;

  /// No description provided for @pulso_eyebrowTodayWorkout.
  ///
  /// In pt, this message translates to:
  /// **'TREINO DE HOJE'**
  String get pulso_eyebrowTodayWorkout;

  /// No description provided for @pulso_eyebrowProgram.
  ///
  /// In pt, this message translates to:
  /// **'PROGRAMA'**
  String get pulso_eyebrowProgram;

  /// No description provided for @pulso_eyebrowRecovery.
  ///
  /// In pt, this message translates to:
  /// **'RECOVERY'**
  String get pulso_eyebrowRecovery;

  /// No description provided for @pulso_eyebrowContributors.
  ///
  /// In pt, this message translates to:
  /// **'CONTRIBUINTES'**
  String get pulso_eyebrowContributors;

  /// No description provided for @pulso_eyebrowSleep.
  ///
  /// In pt, this message translates to:
  /// **'SONO'**
  String get pulso_eyebrowSleep;

  /// No description provided for @pulso_eyebrowMuscleHeatmap.
  ///
  /// In pt, this message translates to:
  /// **'HEATMAP MUSCULAR'**
  String get pulso_eyebrowMuscleHeatmap;

  /// No description provided for @pulso_eyebrowStrainHistory.
  ///
  /// In pt, this message translates to:
  /// **'STRAIN · 7 DIAS'**
  String get pulso_eyebrowStrainHistory;

  /// No description provided for @pulso_eyebrowPrescribedLoad.
  ///
  /// In pt, this message translates to:
  /// **'CARGA PRESCRITA'**
  String get pulso_eyebrowPrescribedLoad;

  /// No description provided for @pulso_eyebrowExecutionTempo.
  ///
  /// In pt, this message translates to:
  /// **'TEMPO DE EXECUÇÃO'**
  String get pulso_eyebrowExecutionTempo;

  /// No description provided for @pulso_eyebrowLoadHistory.
  ///
  /// In pt, this message translates to:
  /// **'HISTÓRICO DE CARGA'**
  String get pulso_eyebrowLoadHistory;

  /// No description provided for @pulso_eyebrowTakeaway.
  ///
  /// In pt, this message translates to:
  /// **'TAKEAWAY'**
  String get pulso_eyebrowTakeaway;

  /// No description provided for @pulso_labelStrain.
  ///
  /// In pt, this message translates to:
  /// **'STRAIN'**
  String get pulso_labelStrain;

  /// No description provided for @pulso_labelStrainTarget.
  ///
  /// In pt, this message translates to:
  /// **'STRAIN ALVO'**
  String get pulso_labelStrainTarget;

  /// No description provided for @pulso_labelHrv.
  ///
  /// In pt, this message translates to:
  /// **'HRV'**
  String get pulso_labelHrv;

  /// No description provided for @pulso_labelRhr.
  ///
  /// In pt, this message translates to:
  /// **'RHR'**
  String get pulso_labelRhr;

  /// No description provided for @pulso_labelSleep.
  ///
  /// In pt, this message translates to:
  /// **'SONO'**
  String get pulso_labelSleep;

  /// No description provided for @pulso_labelWeek.
  ///
  /// In pt, this message translates to:
  /// **'SEMANA'**
  String get pulso_labelWeek;

  /// No description provided for @pulso_labelFocus.
  ///
  /// In pt, this message translates to:
  /// **'FOCO'**
  String get pulso_labelFocus;

  /// No description provided for @pulso_labelIntensity.
  ///
  /// In pt, this message translates to:
  /// **'INTENSIDADE'**
  String get pulso_labelIntensity;

  /// No description provided for @pulso_labelSets.
  ///
  /// In pt, this message translates to:
  /// **'SETS'**
  String get pulso_labelSets;

  /// No description provided for @pulso_labelVolume.
  ///
  /// In pt, this message translates to:
  /// **'VOLUME'**
  String get pulso_labelVolume;

  /// No description provided for @pulso_ctaStartWorkout.
  ///
  /// In pt, this message translates to:
  /// **'Iniciar treino'**
  String get pulso_ctaStartWorkout;

  /// No description provided for @pulso_ctaFinish.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar'**
  String get pulso_ctaFinish;

  /// No description provided for @pulso_ctaSwapExercise.
  ///
  /// In pt, this message translates to:
  /// **'Trocar exercício'**
  String get pulso_ctaSwapExercise;

  /// No description provided for @pulso_restDayTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dia de descanso'**
  String get pulso_restDayTitle;

  /// No description provided for @pulso_restDayBody.
  ///
  /// In pt, this message translates to:
  /// **'Use o dia pra mobilidade leve e sono prolongado.'**
  String get pulso_restDayBody;

  /// No description provided for @pulso_errorSessionNotStarted.
  ///
  /// In pt, this message translates to:
  /// **'Sessão não iniciada.'**
  String get pulso_errorSessionNotStarted;

  /// No description provided for @pulso_errorExerciseNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Exercício não encontrado.'**
  String get pulso_errorExerciseNotFound;

  /// No description provided for @pulso_snackbarSessionFinished.
  ///
  /// In pt, this message translates to:
  /// **'Sessão finalizada. Strain registrado.'**
  String get pulso_snackbarSessionFinished;

  /// No description provided for @pulso_recoveryAdviceLow.
  ///
  /// In pt, this message translates to:
  /// **'Corpo pede pausa. Aceite o stiff hoje, pegue intensidade amanhã.'**
  String get pulso_recoveryAdviceLow;

  /// No description provided for @pulso_recoveryAdviceMedium.
  ///
  /// In pt, this message translates to:
  /// **'Banda média. Mantenha o volume planejado, sem buscar PR.'**
  String get pulso_recoveryAdviceMedium;

  /// No description provided for @pulso_recoveryAdviceHigh.
  ///
  /// In pt, this message translates to:
  /// **'Tudo verde. Use a janela pra trabalho intenso no padrão do mesociclo.'**
  String get pulso_recoveryAdviceHigh;

  /// No description provided for @pulso_muscleAdviceLow.
  ///
  /// In pt, this message translates to:
  /// **'Cadeia trashada. Foque em alongamento e hidratação.'**
  String get pulso_muscleAdviceLow;

  /// No description provided for @pulso_muscleAdviceMedium.
  ///
  /// In pt, this message translates to:
  /// **'Banda média. Mantenha o trabalho na zona prescrita.'**
  String get pulso_muscleAdviceMedium;

  /// No description provided for @pulso_muscleAdviceHigh.
  ///
  /// In pt, this message translates to:
  /// **'Boa janela. Use pra carga pesada se o plano pedir.'**
  String get pulso_muscleAdviceHigh;

  /// No description provided for @pulso_weekdayMon.
  ///
  /// In pt, this message translates to:
  /// **'Segunda'**
  String get pulso_weekdayMon;

  /// No description provided for @pulso_weekdayTue.
  ///
  /// In pt, this message translates to:
  /// **'Terça'**
  String get pulso_weekdayTue;

  /// No description provided for @pulso_weekdayWed.
  ///
  /// In pt, this message translates to:
  /// **'Quarta'**
  String get pulso_weekdayWed;

  /// No description provided for @pulso_weekdayThu.
  ///
  /// In pt, this message translates to:
  /// **'Quinta'**
  String get pulso_weekdayThu;

  /// No description provided for @pulso_weekdayFri.
  ///
  /// In pt, this message translates to:
  /// **'Sexta'**
  String get pulso_weekdayFri;

  /// No description provided for @pulso_weekdaySat.
  ///
  /// In pt, this message translates to:
  /// **'Sábado'**
  String get pulso_weekdaySat;

  /// No description provided for @pulso_weekdaySun.
  ///
  /// In pt, this message translates to:
  /// **'Domingo'**
  String get pulso_weekdaySun;

  /// No description provided for @pulso_programSelectDay.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um dia'**
  String get pulso_programSelectDay;

  /// No description provided for @pulso_programTouchHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque uma célula do grid pra previsualizar a sessão.'**
  String get pulso_programTouchHint;

  /// No description provided for @pulso_recoveryHeaderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como o corpo respondeu ontem.'**
  String get pulso_recoveryHeaderTitle;

  /// No description provided for @pulso_recoveryTodayLabel.
  ///
  /// In pt, this message translates to:
  /// **'HOJE'**
  String get pulso_recoveryTodayLabel;

  /// No description provided for @pulso_recoveryRhrLabel.
  ///
  /// In pt, this message translates to:
  /// **'Freq. cardíaca em repouso'**
  String get pulso_recoveryRhrLabel;

  /// No description provided for @pulso_recoveryRespiratoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Respiratória'**
  String get pulso_recoveryRespiratoryLabel;

  /// No description provided for @pulso_sleepEfficiencySuffix.
  ///
  /// In pt, this message translates to:
  /// **'% eficiência'**
  String get pulso_sleepEfficiencySuffix;

  /// No description provided for @pulso_sleepDeepLabel.
  ///
  /// In pt, this message translates to:
  /// **'Profundo'**
  String get pulso_sleepDeepLabel;

  /// No description provided for @pulso_sleepRemLabel.
  ///
  /// In pt, this message translates to:
  /// **'REM'**
  String get pulso_sleepRemLabel;

  /// No description provided for @pulso_sleepLightLabel.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get pulso_sleepLightLabel;

  /// No description provided for @pulso_muscleHeatmapGeneralLabel.
  ///
  /// In pt, this message translates to:
  /// **'Geral'**
  String get pulso_muscleHeatmapGeneralLabel;

  /// No description provided for @pulso_exerciseDetailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Exercício'**
  String get pulso_exerciseDetailTitle;

  /// No description provided for @pulso_exerciseSwapTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Trocar'**
  String get pulso_exerciseSwapTooltip;

  /// No description provided for @pulso_sessionWeekSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Semana {week} · {label}'**
  String pulso_sessionWeekSubtitle(int week, String label);

  /// No description provided for @pulso_swapExerciseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Trocar exercício'**
  String get pulso_swapExerciseTitle;

  /// No description provided for @pulso_swapExerciseSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Alternativas que ativam a mesma cadeia muscular.'**
  String get pulso_swapExerciseSubtitle;

  /// No description provided for @pulso_swapExerciseEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Sem alternativas catalogadas pra este exercício.'**
  String get pulso_swapExerciseEmpty;

  /// No description provided for @aurora_closeDemoTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Fechar demo'**
  String get aurora_closeDemoTooltip;

  /// No description provided for @aurora_resetDemoTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Reiniciar demo'**
  String get aurora_resetDemoTooltip;

  /// No description provided for @aurora_historyTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de pedidos'**
  String get aurora_historyTooltip;

  /// No description provided for @aurora_categoriesEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get aurora_categoriesEyebrow;

  /// No description provided for @aurora_categoriesTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que vai pro caixote'**
  String get aurora_categoriesTitle;

  /// No description provided for @aurora_vendorsEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Bancas em destaque'**
  String get aurora_vendorsEyebrow;

  /// No description provided for @aurora_vendorsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem entrega hoje'**
  String get aurora_vendorsTitle;

  /// No description provided for @aurora_heroTag.
  ///
  /// In pt, this message translates to:
  /// **'marketplace de hortifruti · são paulo'**
  String get aurora_heroTag;

  /// No description provided for @aurora_heroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Bancas de bairro, padarias e queijarias entregam no mesmo dia. Pedido pela manhã, na sua mesa no almoço.'**
  String get aurora_heroSubtitle;

  /// No description provided for @aurora_storesEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'bancas'**
  String get aurora_storesEyebrow;

  /// No description provided for @aurora_storesTitleAll.
  ///
  /// In pt, this message translates to:
  /// **'Todas as bancas'**
  String get aurora_storesTitleAll;

  /// No description provided for @aurora_storesTitleFiltered.
  ///
  /// In pt, this message translates to:
  /// **'Em {category}'**
  String aurora_storesTitleFiltered(String category);

  /// No description provided for @aurora_storesCountSingular.
  ///
  /// In pt, this message translates to:
  /// **'1 banca'**
  String get aurora_storesCountSingular;

  /// No description provided for @aurora_storesCountPlural.
  ///
  /// In pt, this message translates to:
  /// **'{count} bancas'**
  String aurora_storesCountPlural(int count);

  /// No description provided for @aurora_storesEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma banca nessa categoria por enquanto.'**
  String get aurora_storesEmpty;

  /// No description provided for @aurora_orderTimelineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Onde está seu pedido'**
  String get aurora_orderTimelineTitle;

  /// No description provided for @aurora_orderItemsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Itens'**
  String get aurora_orderItemsTitle;

  /// No description provided for @vitral_closeDemoTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Fechar demo'**
  String get vitral_closeDemoTooltip;

  /// No description provided for @vitral_categoriesTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que você precisa hoje'**
  String get vitral_categoriesTitle;

  /// No description provided for @vitral_specialistsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem está na agenda'**
  String get vitral_specialistsTitle;

  /// No description provided for @solar_closeDemoTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Fechar demo'**
  String get solar_closeDemoTooltip;

  /// No description provided for @solar_neighborhoodsEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Bairros'**
  String get solar_neighborhoodsEyebrow;

  /// No description provided for @solar_neighborhoodsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por onde você procura'**
  String get solar_neighborhoodsTitle;

  /// No description provided for @solar_featuredEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'Em destaque'**
  String get solar_featuredEyebrow;

  /// No description provided for @solar_featuredTitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecionados a mão'**
  String get solar_featuredTitle;

  /// No description provided for @solar_heroTag.
  ///
  /// In pt, this message translates to:
  /// **'imobiliária · interior de são paulo'**
  String get solar_heroTag;

  /// No description provided for @solar_heroSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Casas, chácaras, terrenos e apartamentos em cidades do interior — com curadoria, planta baixa e corretor local em cada anúncio.'**
  String get solar_heroSubtitle;

  /// No description provided for @solar_heroCta.
  ///
  /// In pt, this message translates to:
  /// **'Ver imóveis'**
  String get solar_heroCta;

  /// No description provided for @mira_closeDemoTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Fechar demo'**
  String get mira_closeDemoTooltip;

  /// No description provided for @mira_portfolioTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Meu portfólio'**
  String get mira_portfolioTooltip;

  /// No description provided for @mira_historyTooltip.
  ///
  /// In pt, this message translates to:
  /// **'Histórico de ordens'**
  String get mira_historyTooltip;

  /// No description provided for @mira_watchlistEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'WATCHLIST'**
  String get mira_watchlistEyebrow;

  /// No description provided for @mira_watchlistTitle.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhando'**
  String get mira_watchlistTitle;

  /// No description provided for @mira_catalogEyebrow.
  ///
  /// In pt, this message translates to:
  /// **'CATÁLOGO'**
  String get mira_catalogEyebrow;

  /// No description provided for @mira_otherAssetsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Outros ativos'**
  String get mira_otherAssetsTitle;

  /// No description provided for @mira_marketStatusLabel.
  ///
  /// In pt, this message translates to:
  /// **'B3 · TEMPO REAL'**
  String get mira_marketStatusLabel;

  /// No description provided for @mira_totalAssetsLabel.
  ///
  /// In pt, this message translates to:
  /// **'PATRIMÔNIO TOTAL'**
  String get mira_totalAssetsLabel;

  /// No description provided for @stack_cat_framework.
  ///
  /// In pt, this message translates to:
  /// **'Framework'**
  String get stack_cat_framework;

  /// No description provided for @stack_cat_state.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get stack_cat_state;

  /// No description provided for @stack_cat_routing.
  ///
  /// In pt, this message translates to:
  /// **'Rotas'**
  String get stack_cat_routing;

  /// No description provided for @stack_cat_graphics.
  ///
  /// In pt, this message translates to:
  /// **'Gráficos'**
  String get stack_cat_graphics;

  /// No description provided for @stack_cat_networking.
  ///
  /// In pt, this message translates to:
  /// **'Rede'**
  String get stack_cat_networking;

  /// No description provided for @stack_cat_persistence.
  ///
  /// In pt, this message translates to:
  /// **'Persistência'**
  String get stack_cat_persistence;

  /// No description provided for @stack_cat_codegen.
  ///
  /// In pt, this message translates to:
  /// **'Code Generation'**
  String get stack_cat_codegen;

  /// No description provided for @stack_cat_architecture.
  ///
  /// In pt, this message translates to:
  /// **'Arquitetura'**
  String get stack_cat_architecture;

  /// No description provided for @stack_cat_quality.
  ///
  /// In pt, this message translates to:
  /// **'Qualidade'**
  String get stack_cat_quality;

  /// No description provided for @stack_cat_web.
  ///
  /// In pt, this message translates to:
  /// **'Web / PWA'**
  String get stack_cat_web;

  /// No description provided for @stack_cat_tooling.
  ///
  /// In pt, this message translates to:
  /// **'Tooling'**
  String get stack_cat_tooling;

  /// No description provided for @stack_cat_observability.
  ///
  /// In pt, this message translates to:
  /// **'Observabilidade'**
  String get stack_cat_observability;

  /// No description provided for @stack_flutter_role.
  ///
  /// In pt, this message translates to:
  /// **'Framework base, Material 3 dark-only'**
  String get stack_flutter_role;

  /// No description provided for @stack_dart_role.
  ///
  /// In pt, this message translates to:
  /// **'SDK, null safety e records'**
  String get stack_dart_role;

  /// No description provided for @stack_platformChannels_role.
  ///
  /// In pt, this message translates to:
  /// **'Ponte nativa Dart ↔ Kotlin/Swift'**
  String get stack_platformChannels_role;

  /// No description provided for @stack_flutterBloc_role.
  ///
  /// In pt, this message translates to:
  /// **'Bloc + Cubit para fluxos com eventos'**
  String get stack_flutterBloc_role;

  /// No description provided for @stack_provider_role.
  ///
  /// In pt, this message translates to:
  /// **'InheritedWidget simplificado, DI leve'**
  String get stack_provider_role;

  /// No description provided for @stack_riverpod_role.
  ///
  /// In pt, this message translates to:
  /// **'Estado reativo com code generation'**
  String get stack_riverpod_role;

  /// No description provided for @stack_getx_role.
  ///
  /// In pt, this message translates to:
  /// **'Estado reativo, rotas e DI integrados'**
  String get stack_getx_role;

  /// No description provided for @stack_mobx_role.
  ///
  /// In pt, this message translates to:
  /// **'Observables e reactions transparentes'**
  String get stack_mobx_role;

  /// No description provided for @stack_blocTest_role.
  ///
  /// In pt, this message translates to:
  /// **'Test harness para blocs e cubits'**
  String get stack_blocTest_role;

  /// No description provided for @stack_goRouter_role.
  ///
  /// In pt, this message translates to:
  /// **'Routing declarativo com deferred loading'**
  String get stack_goRouter_role;

  /// No description provided for @stack_flutterModular_role.
  ///
  /// In pt, this message translates to:
  /// **'DI + rotas modulares por feature'**
  String get stack_flutterModular_role;

  /// No description provided for @stack_customPainter_role.
  ///
  /// In pt, this message translates to:
  /// **'Renderização 2D de baixo nível no Canvas'**
  String get stack_customPainter_role;

  /// No description provided for @stack_animations_role.
  ///
  /// In pt, this message translates to:
  /// **'Implícitas, explícitas e Tween chains'**
  String get stack_animations_role;

  /// No description provided for @stack_dio_role.
  ///
  /// In pt, this message translates to:
  /// **'HTTP client com interceptors e cancel tokens'**
  String get stack_dio_role;

  /// No description provided for @stack_http_role.
  ///
  /// In pt, this message translates to:
  /// **'HTTP client leve do Dart team'**
  String get stack_http_role;

  /// No description provided for @stack_sqlite_role.
  ///
  /// In pt, this message translates to:
  /// **'Banco relacional local no device'**
  String get stack_sqlite_role;

  /// No description provided for @stack_hive_role.
  ///
  /// In pt, this message translates to:
  /// **'Key-value store rápido, sem SQL'**
  String get stack_hive_role;

  /// No description provided for @stack_sharedPreferences_role.
  ///
  /// In pt, this message translates to:
  /// **'Key-value persistente simples por plataforma'**
  String get stack_sharedPreferences_role;

  /// No description provided for @stack_firebase_role.
  ///
  /// In pt, this message translates to:
  /// **'Auth, Firestore, Analytics, Push, Crashlytics'**
  String get stack_firebase_role;

  /// No description provided for @stack_freezed_role.
  ///
  /// In pt, this message translates to:
  /// **'Unions, copyWith e serialização por codegen'**
  String get stack_freezed_role;

  /// No description provided for @stack_jsonSerializable_role.
  ///
  /// In pt, this message translates to:
  /// **'Serialização JSON type-safe com codegen'**
  String get stack_jsonSerializable_role;

  /// No description provided for @stack_cleanArch_role.
  ///
  /// In pt, this message translates to:
  /// **'Camadas data / domain / presentation por feature'**
  String get stack_cleanArch_role;

  /// No description provided for @stack_mvvm_role.
  ///
  /// In pt, this message translates to:
  /// **'View-ViewModel binding reativo'**
  String get stack_mvvm_role;

  /// No description provided for @stack_solid_role.
  ///
  /// In pt, this message translates to:
  /// **'Inversão de dependência e responsabilidade única'**
  String get stack_solid_role;

  /// No description provided for @stack_monorepo_role.
  ///
  /// In pt, this message translates to:
  /// **'Pacotes independentes com contratos explícitos'**
  String get stack_monorepo_role;

  /// No description provided for @stack_getIt_role.
  ///
  /// In pt, this message translates to:
  /// **'Service locator para inversão de dependência'**
  String get stack_getIt_role;

  /// No description provided for @stack_injectable_role.
  ///
  /// In pt, this message translates to:
  /// **'DI por anotações com codegen sobre get_it'**
  String get stack_injectable_role;

  /// No description provided for @stack_designSystem_role.
  ///
  /// In pt, this message translates to:
  /// **'Cores, tipografia, spacing e componentes reutilizáveis'**
  String get stack_designSystem_role;

  /// No description provided for @stack_sdui_role.
  ///
  /// In pt, this message translates to:
  /// **'UI dirigida por contrato remoto, sem deploy'**
  String get stack_sdui_role;

  /// No description provided for @stack_featureFirst_role.
  ///
  /// In pt, this message translates to:
  /// **'Módulos isolados por domínio, sem dependência cruzada'**
  String get stack_featureFirst_role;

  /// No description provided for @stack_vga_role.
  ///
  /// In pt, this message translates to:
  /// **'Lints estritos com failFast no CI'**
  String get stack_vga_role;

  /// No description provided for @stack_flutterTest_role.
  ///
  /// In pt, this message translates to:
  /// **'Widget tests por feature + bloc tests'**
  String get stack_flutterTest_role;

  /// No description provided for @stack_mocktail_role.
  ///
  /// In pt, this message translates to:
  /// **'Mocks sem codegen para testes unitários'**
  String get stack_mocktail_role;

  /// No description provided for @stack_integrationTest_role.
  ///
  /// In pt, this message translates to:
  /// **'Testes E2E no device real ou emulador'**
  String get stack_integrationTest_role;

  /// No description provided for @stack_skwasm_role.
  ///
  /// In pt, this message translates to:
  /// **'Renderer WASM, fallback CanvasKit automático'**
  String get stack_skwasm_role;

  /// No description provided for @stack_pwa_role.
  ///
  /// In pt, this message translates to:
  /// **'Instalável, indexável, com loading custom'**
  String get stack_pwa_role;

  /// No description provided for @stack_urlLauncher_role.
  ///
  /// In pt, this message translates to:
  /// **'Deep links externos (WhatsApp, mail, GitHub)'**
  String get stack_urlLauncher_role;

  /// No description provided for @stack_melos_role.
  ///
  /// In pt, this message translates to:
  /// **'Orquestrador do monorepo Pub Workspaces'**
  String get stack_melos_role;

  /// No description provided for @stack_githubActions_role.
  ///
  /// In pt, this message translates to:
  /// **'Pipelines de analyze, test e build web'**
  String get stack_githubActions_role;

  /// No description provided for @stack_fastlane_role.
  ///
  /// In pt, this message translates to:
  /// **'Automação de build, sign e deploy mobile'**
  String get stack_fastlane_role;

  /// No description provided for @stack_datadog_role.
  ///
  /// In pt, this message translates to:
  /// **'APM, logs e RUM de apps em produção'**
  String get stack_datadog_role;

  /// No description provided for @locale_pt.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get locale_pt;

  /// No description provided for @locale_en.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get locale_en;

  /// No description provided for @locale_es.
  ///
  /// In pt, this message translates to:
  /// **'Español'**
  String get locale_es;

  /// No description provided for @locale_de.
  ///
  /// In pt, this message translates to:
  /// **'Deutsch'**
  String get locale_de;

  /// No description provided for @locale_zh.
  ///
  /// In pt, this message translates to:
  /// **'中文'**
  String get locale_zh;

  /// No description provided for @locale_ja.
  ///
  /// In pt, this message translates to:
  /// **'日本語'**
  String get locale_ja;

  /// No description provided for @locale_it.
  ///
  /// In pt, this message translates to:
  /// **'Italiano'**
  String get locale_it;

  /// No description provided for @locale_fr.
  ///
  /// In pt, this message translates to:
  /// **'Français'**
  String get locale_fr;

  /// No description provided for @locale_ru.
  ///
  /// In pt, this message translates to:
  /// **'Русский'**
  String get locale_ru;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
