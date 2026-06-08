part of 'mira_home_page.dart';

/// Hero do portfolio — Stack do backdrop animado com o card de
/// patrimonio sobreposto. O backdrop ocupa todo o slot; o card vive
/// no padding interno e expoe o numero monumental + sparkline 30d.
class _PortfolioHero extends StatelessWidget {
  const _PortfolioHero({required this.state});

  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final value = state.marketValueCents;
    final pnl = state.unrealizedPnlCents;
    final pnlBps = state.unrealizedPnlBps;
    final isUp = pnl >= 0;
    final heroHeight = context.responsive<double>(mobile: 248, desktop: 320);

    return SizedBox(
      key: const Key('mira-portfolio-hero'),
      height: heroHeight,
      child: Stack(
        children: [
          Positioned.fill(child: MiraHeroBackdrop(height: heroHeight)),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MarketStatusChip(),
                      const Spacer(),
                      Text(
                        context.l10n.mira_marketStatusLabel,
                        style: TextStyle(
                          color: colors.onSurfaceMuted,
                          fontSize: 10,
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                          fontFamily: MiraBrand.monoFontFamily,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.mira_totalAssetsLabel,
                    style: TextStyle(
                      color: colors.onSurfaceMuted,
                      fontSize: 11,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    formatMiraTotal(value),
                    style: context
                        .responsive(
                          mobile: textTheme.displaySmall,
                          desktop: textTheme.displayMedium,
                        )
                        ?.copyWith(
                          color: colors.onSurface,
                          fontFamily: MiraBrand.monoFontFamily,
                          fontWeight: FontWeight.w800,
                          fontFeatures: const [FontFeature.tabularFigures()],
                          height: 1.05,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      MiraChangePill(changeBps: pnlBps),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${isUp ? '+' : '-'}${formatMiraTotal(pnl.abs())}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isUp ? colors.success : colors.error,
                          fontWeight: FontWeight.w700,
                          fontFamily: MiraBrand.monoFontFamily,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'desde a abertura',
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Text(
                        '30D',
                        style: TextStyle(
                          color: colors.onSurfaceMuted,
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                          fontFamily: MiraBrand.monoFontFamily,
                        ),
                      ),
                      Expanded(
                        child: MiraPortfolioSparkline(endValueCents: value),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicador "MERCADO ABERTO" com dot piscando — joia de marca pra
/// reforcar que e produto financeiro em tempo real.
class _MarketStatusChip extends StatefulWidget {
  @override
  State<_MarketStatusChip> createState() => _MarketStatusChipState();
}

class _MarketStatusChipState extends State<_MarketStatusChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: colors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) => Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colors.success.withValues(
                      alpha: 0.4 + _pulse.value * 0.4,
                    ),
                    blurRadius: 4 + _pulse.value * 6,
                    spreadRadius: _pulse.value * 1.5,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'MERCADO ABERTO',
            style: TextStyle(
              color: colors.success,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              fontFamily: MiraBrand.monoFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// Campo de busca da watchlist/catalogo. Mantem um `TextEditingController`
/// local pro texto digitado, mas o termo efetivo (que dirige a
/// filtragem) vive no `FinanceBloc` via `FinanceSearchQueryChanged` —
/// o controller so reflete o estado, sem ser fonte de verdade do filtro.
class _AssetSearchField extends StatefulWidget {
  const _AssetSearchField({required this.query});

  final String query;

  @override
  State<_AssetSearchField> createState() => _AssetSearchFieldState();
}

class _AssetSearchFieldState extends State<_AssetSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(_AssetSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sincroniza o controller quando o bloc muda o termo por fora (ex.:
    // reset do demo) sem mover o cursor durante a digitacao normal.
    if (widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      key: const Key('mira-asset-search-field'),
      controller: _controller,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        color: colors.onSurface,
        fontFamily: MiraBrand.monoFontFamily,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
      ),
      onChanged: (value) =>
          context.read<FinanceBloc>().add(FinanceSearchQueryChanged(value)),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: colors.surface,
        hintText: 'Buscar ativo, setor ou ticker',
        hintStyle: TextStyle(
          color: colors.onSurfaceMuted,
          fontWeight: FontWeight.w500,
          fontFamily: MiraBrand.displayFontFamily,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.onSurfaceMuted,
          size: 20,
        ),
        suffixIcon: widget.query.isEmpty
            ? null
            : IconButton(
                key: const Key('mira-asset-search-clear'),
                tooltip: 'Limpar busca',
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.onSurfaceMuted,
                  size: 18,
                ),
                onPressed: () {
                  _controller.clear();
                  context.read<FinanceBloc>().add(
                    const FinanceSearchQueryChanged(''),
                  );
                },
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
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
          borderSide: BorderSide(color: MiraBrand.neonMint, width: 1.4),
        ),
      ),
    );
  }
}

/// Bloco da home sem busca ativa — watchlist (favoritos) seguida do
/// resto do catalogo, cada uma com seu header.
class _WatchlistAndCatalog extends StatelessWidget {
  const _WatchlistAndCatalog({required this.state});

  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final favoriteIds = state.favoriteIds;
    final watchlist = MiraAssetsCatalog.all
        .where((a) => favoriteIds.contains(a.id))
        .toList();
    final others = MiraAssetsCatalog.all
        .where((a) => !favoriteIds.contains(a.id))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          eyebrow: context.l10n.mira_watchlistEyebrow,
          title: context.l10n.mira_watchlistTitle,
          count: watchlist.isEmpty ? null : watchlist.length,
        ),
        const SizedBox(height: AppSpacing.md),
        if (watchlist.isEmpty)
          const _EmptyFavoritesNote()
        else
          ...watchlist.map((a) => _AssetRow(asset: a, isFavorite: true)),
        SizedBox(
          height: context.responsive(
            mobile: AppSpacing.xl,
            desktop: AppSpacing.xxl,
          ),
        ),
        _SectionHeader(
          eyebrow: context.l10n.mira_catalogEyebrow,
          title: context.l10n.mira_otherAssetsTitle,
          count: others.length,
        ),
        const SizedBox(height: AppSpacing.md),
        ...others.map((a) => _AssetRow(asset: a, isFavorite: false)),
      ],
    );
  }
}

/// Bloco da home com busca ativa — lista unica dos ativos que casam com
/// o termo, mantendo o estado de favorito de cada um. Mostra empty state
/// quando nada casa.
class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.state});

  final FinanceState state;

  @override
  Widget build(BuildContext context) {
    final results = state.searchResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          eyebrow: context.l10n.mira_catalogEyebrow,
          title: 'Resultados',
          count: results.isEmpty ? null : results.length,
        ),
        const SizedBox(height: AppSpacing.md),
        if (results.isEmpty)
          _NoSearchResults(query: state.searchQuery.trim())
        else
          ...results.map(
            (a) => _AssetRow(
              asset: a,
              isFavorite: state.favoriteIds.contains(a.id),
            ),
          ),
      ],
    );
  }
}

/// Empty state da busca — nenhum ativo casou com o termo.
class _NoSearchResults extends StatelessWidget {
  const _NoSearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      key: const Key('mira-search-empty'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_off_rounded,
            color: colors.onSurfaceMuted,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Nenhum ativo encontrado para "$query".',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section header opinionated — eyebrow uppercase + headline em sans
/// + linha neon mint abaixo + opcional contador.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.count,
  });

  final String eyebrow;
  final String title;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              eyebrow,
              style: const TextStyle(
                color: MiraBrand.neonMint,
                fontSize: 10,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w800,
                fontFamily: MiraBrand.monoFontFamily,
              ),
            ),
            const Spacer(),
            if (count != null)
              Text(
                count.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: colors.onSurfaceMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  fontFamily: MiraBrand.monoFontFamily,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Container(
                height: 1.2,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      MiraBrand.neonMint.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyFavoritesNote extends StatelessWidget {
  const _EmptyFavoritesNote();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        'Toque na estrela de qualquer ativo abaixo pra adicionar a sua '
        'watchlist.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceMuted),
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.asset, required this.isFavorite});

  final Asset asset;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          key: Key('mira-asset-row-${asset.id}'),
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => miraWithDemoBloc(
                context,
                MiraAssetDetailPage(assetId: asset.id),
              ),
            ),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: context.responsive(
                mobile: AppSpacing.md,
                desktop: AppSpacing.lg,
              ),
              vertical: context.responsive(
                mobile: AppSpacing.sm,
                desktop: AppSpacing.md,
              ),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: colors.border),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                _SectorBadge(asset: asset),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.symbol,
                        style: textTheme.titleSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          fontFamily: MiraBrand.monoFontFamily,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Text(
                        asset.name,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMiraPrice(asset.currentPriceCents),
                      style: textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontFamily: MiraBrand.monoFontFamily,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 2),
                    MiraChangePill(
                      changeBps: asset.dailyChangeBps,
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton(
                  key: Key('mira-favorite-toggle-${asset.id}'),
                  tooltip: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => context.read<FinanceBloc>().add(
                    FinanceFavoriteToggled(asset.id),
                  ),
                  icon: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: isFavorite ? colors.accent : colors.onSurfaceMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge de setor — duas letras do simbolo + cor de fundo derivada do
/// setor (cada setor com seu tom). Mais legivel que "PE" sem cor.
class _SectorBadge extends StatelessWidget {
  const _SectorBadge({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context) {
    final label = asset.symbol.substring(0, 2);
    final tone = _toneForSector(asset);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFamily: MiraBrand.monoFontFamily,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Color _toneForSector(Asset asset) {
    // Hash simples do nome do setor pra um indice numa paleta curada de
    // 4 swatches tiradas da marca (mint, azul-info, dourado, violeta
    // suave) — sem candy colors off-brand, pra os badges lerem como
    // sistema intencional num fintech de 3 cores e nao acidental.
    final palette = [
      const Color(0xFF22D17E),
      const Color(0xFF4FB8FF),
      const Color(0xFFF7B233),
      const Color(0xFF8B7CF0),
    ];
    var seed = 0;
    for (final c in asset.sector.name.codeUnits) {
      seed = (seed * 31 + c) & 0x7fffffff;
    }
    return palette[seed % palette.length];
  }
}

/// Footnote da marca — pequena assinatura no rodape pra firmar
/// identidade visual.
class _BrandFootnote extends StatelessWidget {
  const _BrandFootnote();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.show_chart_rounded,
            color: MiraBrand.neonMint,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            'MIRA · ${MiraBrand.tagline.toUpperCase()}',
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 10,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
              fontFamily: MiraBrand.monoFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
