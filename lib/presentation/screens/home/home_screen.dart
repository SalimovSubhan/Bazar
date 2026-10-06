import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../core/utils/scroll_to_top_notifier.dart';
import '../../../injection_container.dart';
import '../../blocs/categories/categories_bloc.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/products/products_bloc.dart';
import '../../widgets/app_empty_widget.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/home_app_bar.dart';
import '../../widgets/settings_bottom_sheet.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/shimmer_product_card.dart'
    show ShimmerProductCard, ShimmerCategoryBar, ShimmerBanner;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<ProductsBloc>()..add(const ProductsLoadRequested()),
        ),
        BlocProvider(
          create: (_) =>
              sl<CategoriesBloc>()..add(const CategoriesLoadRequested()),
        ),
      ],
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    sl<ScrollToTopNotifier>().addListener(_scrollToTop);
  }

  @override
  void dispose() {
    sl<ScrollToTopNotifier>().removeListener(_scrollToTop);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 300) return;
    final state = context.read<ProductsBloc>().state;
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    context.read<ProductsBloc>().add(const ProductsLoadMoreRequested());
  }

  void _toggleFavorite(BuildContext ctx, product) {
    final favBloc = ctx.read<FavoritesBloc>();
    final wasAdded = !favBloc.state.isFavorite(product.id);
    favBloc.add(FavoriteToggleRequested(product));
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(wasAdded
            ? LocaleKeys.addedToFavorites.tr()
            : LocaleKeys.removedFromFavorites.tr()),
        duration: const Duration(seconds: 2),
      ));
  }

  Future<void> _openCategories() async {
    final result = await context.push<String>(AppRoutes.categories);
    if (result != null && mounted) {
      context.read<ProductsBloc>().add(ProductsCategoryChanged(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsBloc, ProductsState>(
      listenWhen: (prev, curr) =>
          curr.error != null && curr.error != prev.error,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(LocaleKeys.noInternet.tr()),
            duration: const Duration(seconds: 3),
          ));
      },
      child: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) => Scaffold(
        backgroundColor: context.isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: HomeAppBar(
          onCategoryTap: _openCategories,
          onSearchTap: () => context.push(AppRoutes.search),
          onSettingsTap: () => showSettingsSheet(context),
        ),
        body: _buildBody(context, state),
      ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    if (!state.isInitialized && state.isLoading) return _buildShimmer();

    if (state.hasError && state.products.isEmpty) {
      return AppErrorWidget(
        onRetry: () =>
            context.read<ProductsBloc>().add(const ProductsLoadRequested()),
      );
    }
    return _buildContent(context, state);
  }

  Widget _buildShimmer() {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: ShimmerCategoryBar()),
        const SliverToBoxAdapter(child: ShimmerBanner()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.63,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, __) => const ShimmerProductCard(),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProductsState state) {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, catState) {
        final categories =
            catState is CategoriesLoaded ? catState.categories : <String>[];

        return RefreshIndicator(
          onRefresh: () async {
            final bloc = context.read<ProductsBloc>();
            if (!bloc.state.hasMore) return;
            bloc.add(const ProductsRefreshRequested());
            await bloc.stream.firstWhere((s) => !s.isLoading);
          },
          color: AppColors.primary,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: CategoryFilterBar(
                  categories: categories,
                  selectedCategory: state.selectedCategory,
                  onSelected: (cat) => context
                      .read<ProductsBloc>()
                      .add(ProductsCategoryChanged(cat)),
                ),
              ),
              const SliverToBoxAdapter(child: BannerCarousel()),

              if (state.isLoading && state.products.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.63,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerProductCard(),
                      childCount: 6,
                    ),
                  ),
                )
              else if (!state.isLoading && state.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyWidget(
                    icon: Icons.search_off_rounded,
                    title: LocaleKeys.noResults.tr(),
                    subtitle: LocaleKeys.noResultsDescription.tr(),
                  ),
                )
              else ...[
                // Products grid — reacts to FavoritesBloc changes
                BlocBuilder<FavoritesBloc, FavoritesState>(
                  builder: (context, favState) => SliverPadding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.63,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = state.products[index];
                          return ProductCard(
                            product: product,
                            isFavorite: favState.isFavorite(product.id),
                            onFavoriteTap: () =>
                                _toggleFavorite(context, product),
                            onTap: () => context.push(
                                AppRoutes.productDetailPath(product.id)),
                          );
                        },
                        childCount: state.products.length,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: state.isLoadingMore
                        ? const Center(child: CircularProgressIndicator())
                        : !state.hasMore
                            ? Center(
                                child: Text(
                                  LocaleKeys.noMoreProducts.tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: context.isDark
                                        ? AppColors.subtitleDark
                                        : AppColors.subtitleLight,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
