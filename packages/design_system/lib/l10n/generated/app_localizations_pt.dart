// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get common_cancel => 'Cancelar';

  @override
  String get common_back => 'Voltar';

  @override
  String get common_close => 'Fechar';

  @override
  String get common_continue => 'Continuar';

  @override
  String get common_confirm => 'Confirmar';

  @override
  String get common_retry => 'Tentar novamente';

  @override
  String get common_loadMore => 'Carregar mais';

  @override
  String get common_save => 'Salvar';

  @override
  String get common_delete => 'Excluir';

  @override
  String get common_edit => 'Editar';

  @override
  String get common_share => 'Compartilhar';

  @override
  String get common_loading => 'Carregando…';

  @override
  String get common_empty => 'Sem itens por aqui.';

  @override
  String get common_genericError =>
      'Algo deu errado. Tente novamente em instantes.';

  @override
  String get common_openInNew => 'Abrir em nova guia';

  @override
  String get common_search => 'Buscar';

  @override
  String get common_semanticsClose => 'Fechar';

  @override
  String get common_semanticsLoadingSpinner => 'Carregando conteúdo';

  @override
  String get hero_eyebrow => 'Disponível para freelas';

  @override
  String get hero_headline1 => 'Front end mobile com Flutter.';

  @override
  String get hero_headline2 => 'Do MVP ao app em produção.';

  @override
  String get hero_bio =>
      '6 anos construindo o front end de apps mobile (e web quando faz sentido) — atuando do varejo B2B a produto fintech em escala.';

  @override
  String get hero_scrollHint => 'role para continuar';

  @override
  String get hero_ctaWhatsapp => 'Falar no WhatsApp';

  @override
  String get hero_ctaProjects => 'Ver projetos';

  @override
  String get hero_trustYearsValue => '6';

  @override
  String get hero_trustYearsLabel => 'anos de Flutter';

  @override
  String get hero_trustDomainsValue => '5+';

  @override
  String get hero_trustDomainsLabel => 'domínios atuados';

  @override
  String get hero_trustPlatformsValue => 'Mobile · Web';

  @override
  String get hero_trustPlatformsLabel => 'plataformas-alvo';

  @override
  String get hero_portraitSemantics => 'Foto de Jose Guilherme Alves';

  @override
  String get about_eyebrow => 'Sobre';

  @override
  String get about_title => 'Quem te';

  @override
  String get about_titleAccent => 'atende.';

  @override
  String get about_subtitle =>
      'Front end mobile com Flutter há 6 anos. Foco em entregar app robusto, com escopo claro e expectativa alinhada desde o kickoff.';

  @override
  String get about_domainsMapLabel => 'Mapa de domínios';

  @override
  String get about_domainsHint => '· toque um planeta';

  @override
  String get about_deliveryTitle => 'Como eu entrego';

  @override
  String get about_bioName => 'José Guilherme Alves';

  @override
  String get about_bioTitle => 'Front end mobile · Flutter Developer · Brasil';

  @override
  String get about_bioParagraph =>
      'A carreira começou em apps mobile de operação varejista — front end Flutter do design ao deploy, em time pequeno, durante 5 anos. Em seguida, atuação em times de produto em domínios maiores: setor público, plataforma interna, operação em campo e, atualmente, fintech em escala. Sempre no front end mobile, com Flutter web quando o produto demandou. Foco constante em arquitetura, performance e consistência de UX em devices reais.';

  @override
  String get delivery_entrega_eyebrow => 'ENTREGA';

  @override
  String get delivery_entrega_title => 'Escopo claro,';

  @override
  String get delivery_entrega_titleAccent => 'expectativa alinhada.';

  @override
  String get delivery_entrega_body =>
      'Cada projeto começa pelo recorte: o que entra, o que fica de fora, e como cada decisão amarra um critério de aceite. Sem isso, sprint vira corrida de prazo. Trabalho com PO e design desde o kickoff pra que o backlog reflita o que vai pra produção — não o que parece bonito no protótipo.';

  @override
  String get delivery_craft_eyebrow => 'CRAFT';

  @override
  String get delivery_craft_title => 'Arquitetura e';

  @override
  String get delivery_craft_titleAccent => 'performance reais.';

  @override
  String get delivery_craft_body =>
      'Clean Architecture por feature, Bloc/Cubit pra estado, CustomPainter quando vetor é mais barato que asset. Mede tempo de frame em device real (não emulador), perfila build time, audita rebuilds. Stack de produção sustenta evolução — não emperra dois meses depois do MVP.';

  @override
  String get delivery_collab_eyebrow => 'COLABORAÇÃO';

  @override
  String get delivery_collab_title => 'No time de produto';

  @override
  String get delivery_collab_titleAccent => 'ou no Flutter inteiro.';

  @override
  String get delivery_collab_body =>
      'Em time grande entro como front end mobile com escopo de feature ou stewardship arquitetural. Em time pequeno (varejo B2B, 5 anos) cuidei do Flutter inteiro — do design ao deploy, integrando APIs já existentes e ajudando a moldar contratos novos quando o caminho era esse. Ajusto-me ao tamanho do time, não ao contrário.';

  @override
  String get domain_fintech_label => 'Fintech';

  @override
  String get domain_fintech_blurb =>
      'Apps de crédito mobile em escala — base ativa de milhões de usuários.';

  @override
  String get domain_publicServices_label => 'Setor público';

  @override
  String get domain_publicServices_blurb =>
      'Serviços digitais ao cidadão com integração a identidade governamental.';

  @override
  String get domain_sanitation_label => 'Operação em campo';

  @override
  String get domain_sanitation_blurb =>
      'Apps de coleta e inspeção em devices industriais com sincronização offline-first.';

  @override
  String get domain_platform_label => 'Plataforma interna';

  @override
  String get domain_platform_blurb =>
      'Ferramentas internas pra gestão de equipes e operação corporativa em larga escala.';

  @override
  String get domain_retail_label => 'Varejo B2B';

  @override
  String get domain_retail_blurb =>
      'Apps mobile de operação de loja, controle de estoque, inventário e pedidos. Front end Flutter inteiro, em time pequeno, ao longo de 5 anos.';

  @override
  String get services_eyebrow => 'Serviços';

  @override
  String get services_title => 'Front end mobile.';

  @override
  String get services_titleAccent => 'Do brief ao deploy.';

  @override
  String get services_subtitle =>
      'Apps mobile com Flutter, versão web/PWA quando aplicável, integração com APIs existentes e consultoria de arquitetura. Backend e infra permanecem com o time do cliente.';

  @override
  String get services_mobile_title => 'Front end mobile';

  @override
  String get services_mobile_description =>
      'Android nativo via Flutter — performance e consistência de UX em devices reais.';

  @override
  String get services_web_title => 'Web Apps & PWA';

  @override
  String get services_web_description =>
      'O mesmo código Flutter como app web — instalável como PWA, rápido e responsivo.';

  @override
  String get services_integrations_title => 'Integração com APIs';

  @override
  String get services_integrations_description =>
      'REST, OAuth, Bluetooth e NFC — integro o app mobile a APIs e periféricos já existentes.';

  @override
  String get services_maintenance_title => 'Manutenção e evolução';

  @override
  String get services_maintenance_description =>
      'Refator, estabilização e novas features no front end de apps já em produção.';

  @override
  String get services_consulting_title => 'Consultoria mobile';

  @override
  String get services_consulting_description =>
      'Arquitetura, code review e definição de stack — apoio técnico antes da feature virar débito.';

  @override
  String get contact_eyebrow => 'Contato';

  @override
  String get contact_title => 'Vamos';

  @override
  String get contact_titleAccent => 'conversar?';

  @override
  String get contact_subtitle =>
      'Manda uma mensagem por aqui ou direto pelos canais abaixo. Respondo rápido durante a semana.';

  @override
  String get contact_ctaWhatsapp => 'WhatsApp direto';

  @override
  String get contact_ctaEmail => 'Email';

  @override
  String get contact_ctaLinkedin => 'LinkedIn';

  @override
  String get contact_ctaGithub => 'GitHub';

  @override
  String get contact_orDirect => 'Ou direto:';

  @override
  String get contact_formName => 'Nome';

  @override
  String get contact_formEmail => 'Email';

  @override
  String get contact_formProjectType => 'Tipo de projeto';

  @override
  String get contact_formMessage => 'Mensagem';

  @override
  String get contact_formSubmit => 'Enviar pelo WhatsApp';

  @override
  String get contact_formSubmitting => 'Enviando...';

  @override
  String get contact_projectNewApp => 'App novo (do zero ao MVP)';

  @override
  String get contact_projectExisting => 'Evoluir um app existente';

  @override
  String get contact_projectConsulting => 'Consultoria técnica / arquitetura';

  @override
  String get contact_projectOther => 'Outro';

  @override
  String get nav_showcase => 'Showcase';

  @override
  String get nav_about => 'Sobre';

  @override
  String get nav_engineering => 'Engenharia';

  @override
  String get nav_caseStudy => 'Estudo';

  @override
  String get nav_contact => 'Contato';

  @override
  String get nav_backToTop => 'Voltar ao topo';

  @override
  String get nav_ctaContact => 'Contato';

  @override
  String get footer_madeWith => 'Feito em Flutter';

  @override
  String get engineering_eyebrow => 'Engenharia e serviços';

  @override
  String get engineering_title => 'A stack que sustenta';

  @override
  String get engineering_titleAccent => 'cada decisão do projeto.';

  @override
  String get engineering_subtitle =>
      'Tecnologias que domino e aplico em produção. Toque em qualquer tile para saber mais.';

  @override
  String get engineering_githubButton => 'Ver repositório no GitHub';

  @override
  String get caseStudy_eyebrow => 'Case study';

  @override
  String get caseStudy_title => 'Cosmos em Canvas —';

  @override
  String get caseStudy_titleAccent => 'Custom Painters a 60 fps.';

  @override
  String get caseStudy_subtitle =>
      'O fundo desta landing não é imagem nem Lottie — são 7 tipos de corpos celestes pintados em tempo real via CustomPainter. Mais de 140 draw calls por frame, seed-determinístico, tudo derivado de um único tick.';

  @override
  String get caseStudy_pivotEyebrow => 'POR QUE PINTAR';

  @override
  String get caseStudy_pivotTitle =>
      'Canvas supera assets quando geometria é parametrizável.';

  @override
  String get caseStudy_pivotPara1 =>
      'Imagens de planetas seriam estáticas — tamanho fixo, cor fixa, sem animação de órbita nem drift. Lottie resolveria animação mas adicionaria dependência, bundle e limitaria variações. CustomPainter recebe parâmetros (paleta, padrão de superfície, raio, seed) e desenha ao vivo — cada planeta é único sem custar um asset a mais.';

  @override
  String get caseStudy_pivotPara2 =>
      'O CosmosPainter renderiza 7 tipos de corpos: planetas (com anéis e luas), nebulosas, galáxias espirais, pulsares, cinturões de asteroides, wisps de gás e cometas com janela temporal. Um único AnimationController alimenta o tick [0..1] que deriva todas as animações — órbitas, pulsos, drifts — sem timers paralelos nem máquinas de estado.';

  @override
  String get caseStudy_pivotPara3 =>
      'Cada planeta passa por 6 camadas de pintura: bloom (glow externo), rim atmosférico, corpo sólido com gradient, padrão de superfície (bands, speckled ou hemispheres), terminador (sombra 3D) e highlight. O resultado é um planeta neon em ~15 draw calls que roda a 60 fps em web e mobile.';

  @override
  String get caseStudy_recoveryLabel => 'COSMOS · AO VIVO';

  @override
  String get caseStudy_recoveryHint =>
      'O que você vê acima está sendo pintado em tempo real.\nNenhuma imagem, nenhum asset estático.';

  @override
  String get caseStudy_painterStrainTitle => 'Planeta em 6 camadas';

  @override
  String get caseStudy_painterStrainCaption =>
      'Bloom → rim → corpo → superfície → terminador → highlight. Cada camada é um RadialGradient posicionado com canvas.clipPath isolando a geometria. Paleta de 5 cores interpolada automaticamente.';

  @override
  String get caseStudy_painterTempoTitle => 'Galáxia espiral';

  @override
  String get caseStudy_painterTempoCaption =>
      'Braços em espiral logarítmica com até 320 partículas de poeira. drawPoints() agrupa em 3 chamadas GPU por tier de tamanho — 100× menos overhead que drawCircle individual.';

  @override
  String get caseStudy_painterPeriodTitle => 'Constelações nomeadas';

  @override
  String get caseStudy_painterPeriodCaption =>
      'Cruzeiro do Sul, Orion e Triângulo Austral com estrelas pulsantes e arestas conectando pares. AnimationController via super(repaint:) — engine pula build/layout, pinta direto.';

  @override
  String get caseStudy_decisionArchEyebrow => 'RENDERING';

  @override
  String get caseStudy_decisionArchTitle =>
      'super(repaint:) em vez de AnimatedBuilder';

  @override
  String get caseStudy_decisionArchBody =>
      'O AnimationController é passado direto ao CustomPainter via super(repaint:). O engine do Flutter pula as fases de build e layout do pipeline e vai direto pro paint a cada tick. Em cenas de 140+ draw calls, essa economia elimina rebuilds de widget desnecessários a cada 16ms.';

  @override
  String get caseStudy_decisionPaintersEyebrow => 'DETERMINISMO';

  @override
  String get caseStudy_decisionPaintersTitle =>
      'Seed-based: mesma entrada, mesma cena';

  @override
  String get caseStudy_decisionPaintersBody =>
      'Toda posição estocástica — manchas de planeta, posições de asteroides, fases de drift — usa Random(seed). O cosmos é reproduzível: mesmo seed, mesma cena em qualquer plataforma, qualquer restart. Permite teste visual determinístico e screenshots consistentes.';

  @override
  String get caseStudy_decisionStateEyebrow => 'BATCH';

  @override
  String get caseStudy_decisionStateTitle =>
      'drawPoints() para densidade sem custo';

  @override
  String get caseStudy_decisionStateBody =>
      'Galáxias espirais e cinturões de asteroides usam drawPoints(PointMode.points, offsets, paint) para renderizar centenas de partículas em 1-3 chamadas GPU. Abordagem ingênua (um drawCircle por partícula) custaria 320 chamadas. Batching é o que viabiliza cenas densas a 60 fps.';

  @override
  String get caseStudy_takeawayEyebrow => 'TAKEAWAY';

  @override
  String get caseStudy_takeawayTitle =>
      'O cosmos que você vê nesta página é código — não asset, não captura, não biblioteca externa.';

  @override
  String get caseStudy_takeawayBody =>
      'São ~1200 LOC de painter puro, sem dependência fora do Flutter SDK. Paint reutilizado como campo, shouldRepaint comparando propriedades, canvas.save/restore em torno de cada transform. O mesmo painter renderiza o hero da landing e pode ser reusado em qualquer tela do app com parâmetros diferentes.';

  @override
  String get showcase_eyebrow => 'Showcase';

  @override
  String get showcase_title => 'Cinco nichos,';

  @override
  String get showcase_titleAccent => 'cinco protótipos.';

  @override
  String get showcase_subtitle =>
      'Mocks funcionais por nicho — delivery, agendamento, fitness, imobiliária e investimentos. Toque num card pra abrir. Sem backend de verdade; demonstram o tipo de produto que consigo entregar.';

  @override
  String get showcase_financeLabel => 'Investimentos';

  @override
  String get showcase_financeDescription =>
      'Mira — watchlist, candlestick interativo com crosshair, envio de ordem e portfolio com donut de alocação.';

  @override
  String get showcase_deliveryLabel => 'Delivery';

  @override
  String get showcase_deliveryDescription =>
      'Aurora — marketplace de hortifruti com mapa animado, timeline do pedido e histórico.';

  @override
  String get showcase_schedulingLabel => 'Agendamento';

  @override
  String get showcase_schedulingDescription =>
      'Vitral — estúdio de serviços com calendário interativo, relógio animado e confirmação com badge.';

  @override
  String get showcase_fitnessLabel => 'Fitness';

  @override
  String get showcase_fitnessDescription =>
      'Pulso — recovery dashboard, logger set-a-set com RPE e periodização de 8 semanas.';

  @override
  String get showcase_realestateLabel => 'Imobiliária';

  @override
  String get showcase_realestateDescription =>
      'Listagem de imóveis com filtros por bairro, faixa de preço e número de quartos.';

  @override
  String get pulso_eyebrowTodayWorkout => 'TREINO DE HOJE';

  @override
  String get pulso_eyebrowProgram => 'PROGRAMA';

  @override
  String get pulso_eyebrowRecovery => 'RECOVERY';

  @override
  String get pulso_eyebrowContributors => 'CONTRIBUINTES';

  @override
  String get pulso_eyebrowSleep => 'SONO';

  @override
  String get pulso_eyebrowMuscleHeatmap => 'HEATMAP MUSCULAR';

  @override
  String get pulso_eyebrowStrainHistory => 'STRAIN · 7 DIAS';

  @override
  String get pulso_eyebrowPrescribedLoad => 'CARGA PRESCRITA';

  @override
  String get pulso_eyebrowExecutionTempo => 'TEMPO DE EXECUÇÃO';

  @override
  String get pulso_eyebrowLoadHistory => 'HISTÓRICO DE CARGA';

  @override
  String get pulso_eyebrowTakeaway => 'TAKEAWAY';

  @override
  String get pulso_labelStrain => 'STRAIN';

  @override
  String get pulso_labelStrainTarget => 'STRAIN ALVO';

  @override
  String get pulso_labelHrv => 'HRV';

  @override
  String get pulso_labelRhr => 'RHR';

  @override
  String get pulso_labelSleep => 'SONO';

  @override
  String get pulso_labelWeek => 'SEMANA';

  @override
  String get pulso_labelFocus => 'FOCO';

  @override
  String get pulso_labelIntensity => 'INTENSIDADE';

  @override
  String get pulso_labelSets => 'SETS';

  @override
  String get pulso_labelVolume => 'VOLUME';

  @override
  String get pulso_ctaStartWorkout => 'Iniciar treino';

  @override
  String get pulso_ctaFinish => 'Finalizar';

  @override
  String get pulso_ctaSwapExercise => 'Trocar exercício';

  @override
  String get pulso_restDayTitle => 'Dia de descanso';

  @override
  String get pulso_restDayBody =>
      'Use o dia pra mobilidade leve e sono prolongado.';

  @override
  String get pulso_errorSessionNotStarted => 'Sessão não iniciada.';

  @override
  String get pulso_errorExerciseNotFound => 'Exercício não encontrado.';

  @override
  String get pulso_snackbarSessionFinished =>
      'Sessão finalizada. Strain registrado.';

  @override
  String get pulso_recoveryAdviceLow =>
      'Corpo pede pausa. Aceite o stiff hoje, pegue intensidade amanhã.';

  @override
  String get pulso_recoveryAdviceMedium =>
      'Banda média. Mantenha o volume planejado, sem buscar PR.';

  @override
  String get pulso_recoveryAdviceHigh =>
      'Tudo verde. Use a janela pra trabalho intenso no padrão do mesociclo.';

  @override
  String get pulso_muscleAdviceLow =>
      'Cadeia trashada. Foque em alongamento e hidratação.';

  @override
  String get pulso_muscleAdviceMedium =>
      'Banda média. Mantenha o trabalho na zona prescrita.';

  @override
  String get pulso_muscleAdviceHigh =>
      'Boa janela. Use pra carga pesada se o plano pedir.';

  @override
  String get pulso_weekdayMon => 'Segunda';

  @override
  String get pulso_weekdayTue => 'Terça';

  @override
  String get pulso_weekdayWed => 'Quarta';

  @override
  String get pulso_weekdayThu => 'Quinta';

  @override
  String get pulso_weekdayFri => 'Sexta';

  @override
  String get pulso_weekdaySat => 'Sábado';

  @override
  String get pulso_weekdaySun => 'Domingo';

  @override
  String get pulso_programSelectDay => 'Selecione um dia';

  @override
  String get pulso_programTouchHint =>
      'Toque uma célula do grid pra previsualizar a sessão.';

  @override
  String get pulso_recoveryHeaderTitle => 'Como o corpo respondeu ontem.';

  @override
  String get pulso_recoveryTodayLabel => 'HOJE';

  @override
  String get pulso_recoveryRhrLabel => 'Freq. cardíaca em repouso';

  @override
  String get pulso_recoveryRespiratoryLabel => 'Respiratória';

  @override
  String get pulso_sleepEfficiencySuffix => '% eficiência';

  @override
  String get pulso_sleepDeepLabel => 'Profundo';

  @override
  String get pulso_sleepRemLabel => 'REM';

  @override
  String get pulso_sleepLightLabel => 'Leve';

  @override
  String get pulso_muscleHeatmapGeneralLabel => 'Geral';

  @override
  String get pulso_exerciseDetailTitle => 'Exercício';

  @override
  String get pulso_exerciseSwapTooltip => 'Trocar';

  @override
  String pulso_sessionWeekSubtitle(int week, String label) {
    return 'Semana $week · $label';
  }

  @override
  String get pulso_swapExerciseTitle => 'Trocar exercício';

  @override
  String get pulso_swapExerciseSubtitle =>
      'Alternativas que ativam a mesma cadeia muscular.';

  @override
  String get pulso_swapExerciseEmpty =>
      'Sem alternativas catalogadas pra este exercício.';

  @override
  String get aurora_closeDemoTooltip => 'Fechar demo';

  @override
  String get aurora_resetDemoTooltip => 'Reiniciar demo';

  @override
  String get aurora_historyTooltip => 'Histórico de pedidos';

  @override
  String get aurora_categoriesEyebrow => 'Categorias';

  @override
  String get aurora_categoriesTitle => 'O que vai pro caixote';

  @override
  String get aurora_vendorsEyebrow => 'Bancas em destaque';

  @override
  String get aurora_vendorsTitle => 'Quem entrega hoje';

  @override
  String get aurora_heroTag => 'marketplace de hortifruti · são paulo';

  @override
  String get aurora_heroSubtitle =>
      'Bancas de bairro, padarias e queijarias entregam no mesmo dia. Pedido pela manhã, na sua mesa no almoço.';

  @override
  String get aurora_storesEyebrow => 'bancas';

  @override
  String get aurora_storesTitleAll => 'Todas as bancas';

  @override
  String aurora_storesTitleFiltered(String category) {
    return 'Em $category';
  }

  @override
  String get aurora_storesCountSingular => '1 banca';

  @override
  String aurora_storesCountPlural(int count) {
    return '$count bancas';
  }

  @override
  String get aurora_storesEmpty =>
      'Nenhuma banca nessa categoria por enquanto.';

  @override
  String get aurora_orderTimelineTitle => 'Onde está seu pedido';

  @override
  String get aurora_orderItemsTitle => 'Itens';

  @override
  String get vitral_closeDemoTooltip => 'Fechar demo';

  @override
  String get vitral_categoriesTitle => 'O que você precisa hoje';

  @override
  String get vitral_specialistsTitle => 'Quem está na agenda';

  @override
  String get solar_closeDemoTooltip => 'Fechar demo';

  @override
  String get solar_neighborhoodsEyebrow => 'Bairros';

  @override
  String get solar_neighborhoodsTitle => 'Por onde você procura';

  @override
  String get solar_featuredEyebrow => 'Em destaque';

  @override
  String get solar_featuredTitle => 'Selecionados a mão';

  @override
  String get solar_heroTag => 'imobiliária · interior de são paulo';

  @override
  String get solar_heroSubtitle =>
      'Casas, chácaras, terrenos e apartamentos em cidades do interior — com curadoria, planta baixa e corretor local em cada anúncio.';

  @override
  String get solar_heroCta => 'Ver imóveis';

  @override
  String get mira_closeDemoTooltip => 'Fechar demo';

  @override
  String get mira_portfolioTooltip => 'Meu portfólio';

  @override
  String get mira_historyTooltip => 'Histórico de ordens';

  @override
  String get mira_watchlistEyebrow => 'WATCHLIST';

  @override
  String get mira_watchlistTitle => 'Acompanhando';

  @override
  String get mira_catalogEyebrow => 'CATÁLOGO';

  @override
  String get mira_otherAssetsTitle => 'Outros ativos';

  @override
  String get mira_marketStatusLabel => 'B3 · TEMPO REAL';

  @override
  String get mira_totalAssetsLabel => 'PATRIMÔNIO TOTAL';

  @override
  String get stack_cat_framework => 'Framework';

  @override
  String get stack_cat_state => 'Estado';

  @override
  String get stack_cat_routing => 'Rotas';

  @override
  String get stack_cat_graphics => 'Gráficos';

  @override
  String get stack_cat_networking => 'Rede';

  @override
  String get stack_cat_persistence => 'Persistência';

  @override
  String get stack_cat_codegen => 'Code Generation';

  @override
  String get stack_cat_architecture => 'Arquitetura';

  @override
  String get stack_cat_quality => 'Qualidade';

  @override
  String get stack_cat_web => 'Web / PWA';

  @override
  String get stack_cat_tooling => 'Tooling';

  @override
  String get stack_flutter_role => 'Framework base, Material 3 dark-only';

  @override
  String get stack_dart_role => 'SDK, null safety e records';

  @override
  String get stack_equatable_role => 'Equality sem codegen pra value objects';

  @override
  String get stack_platformChannels_role => 'Ponte nativa Dart ↔ Kotlin/Swift';

  @override
  String get stack_flutterBloc_role => 'Bloc + Cubit pros fluxos com eventos';

  @override
  String get stack_provider_role => 'InheritedWidget simplificado, DI leve';

  @override
  String get stack_riverpod_role => 'Estado reativo com code generation';

  @override
  String get stack_getx_role => 'Estado reativo, rotas e DI integrados';

  @override
  String get stack_mobx_role => 'Observables e reactions transparentes';

  @override
  String get stack_blocTest_role => 'Test harness pra blocs e cubits';

  @override
  String get stack_goRouter_role => 'Routing declarativo com deferred loading';

  @override
  String get stack_flutterModular_role => 'DI + rotas modulares por feature';

  @override
  String get stack_customPainter_role =>
      'Renderização 2D de baixo nível no Canvas';

  @override
  String get stack_animations_role => 'Implícitas, explícitas e Tween chains';

  @override
  String get stack_dio_role => 'HTTP client com interceptors e cancel tokens';

  @override
  String get stack_http_role => 'HTTP client leve do Dart team';

  @override
  String get stack_sqlite_role => 'Banco relacional local no device';

  @override
  String get stack_hive_role => 'Key-value store rápido, sem SQL';

  @override
  String get stack_sharedPreferences_role =>
      'Key-value persistente simples por plataforma';

  @override
  String get stack_firebase_role =>
      'Auth, Firestore, Analytics, Push, Crashlytics';

  @override
  String get stack_freezed_role =>
      'Unions, copyWith e serialização por codegen';

  @override
  String get stack_jsonSerializable_role =>
      'Serialização JSON type-safe com codegen';

  @override
  String get stack_cleanArch_role =>
      'Camadas data / domain / presentation por feature';

  @override
  String get stack_mvvm_role => 'View-ViewModel binding reativo';

  @override
  String get stack_solid_role =>
      'Inversão de dependência e responsabilidade única';

  @override
  String get stack_monorepo_role =>
      'Pacotes independentes com contratos explícitos';

  @override
  String get stack_getIt_role => 'Service locator para inversão de dependência';

  @override
  String get stack_injectable_role =>
      'DI por anotações com codegen sobre get_it';

  @override
  String get stack_designSystem_role =>
      'Cores, tipografia, spacing e componentes reutilizáveis';

  @override
  String get stack_sdui_role => 'UI dirigida por contrato remoto, sem deploy';

  @override
  String get stack_featureFirst_role =>
      'Módulos isolados por domínio, sem dependência cruzada';

  @override
  String get stack_vga_role => 'Lints estritos com failFast no CI';

  @override
  String get stack_flutterTest_role => 'Widget tests por feature + bloc tests';

  @override
  String get stack_mocktail_role => 'Mocks sem codegen pra testes unitários';

  @override
  String get stack_integrationTest_role =>
      'Testes E2E no device real ou emulador';

  @override
  String get stack_skwasm_role =>
      'Renderer WASM, fallback CanvasKit automático';

  @override
  String get stack_pwa_role => 'Instalável, indexável, com loading custom';

  @override
  String get stack_urlLauncher_role =>
      'Deep links externos (WhatsApp, mail, GitHub)';

  @override
  String get stack_melos_role => 'Orquestrador do monorepo Pub Workspaces';

  @override
  String get stack_githubActions_role =>
      'Pipelines de analyze, test e build web';

  @override
  String get stack_fastlane_role => 'Automação de build, sign e deploy mobile';

  @override
  String get locale_pt => 'Português';

  @override
  String get locale_en => 'English';

  @override
  String get locale_es => 'Español';

  @override
  String get locale_de => 'Deutsch';

  @override
  String get locale_zh => '中文';

  @override
  String get locale_ja => '日本語';

  @override
  String get locale_it => 'Italiano';
}
