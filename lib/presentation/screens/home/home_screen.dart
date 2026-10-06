import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../injection_container.dart';
import '../../blocs/categories/categories_bloc.dart';
import '../../blocs/products/products_bloc.dart';
import '../../widgets/app_empty_widget.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/home_app_bar.dart';
import '../../widgets/settings_bottom_sheet.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/shimmer_product_card.dart';

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
  final Set<int> _favorites = {};
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 300) return;
    final state = context.read<ProductsBloc>().state;
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    context.read<ProductsBloc>().add(const ProductsLoadMoreRequested());
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favorites.contains(id)) {
        _favorites.remove(id);
        _showSnack(LocaleKeys.removedFromFavorites.tr());
      } else {
        _favorites.add(id);
        _showSnack(LocaleKeys.addedToFavorites.tr());
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
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
    return BlocBuilder<ProductsBloc, ProductsState>(
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
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    // Full-screen shimmer only on very first load (app just opened)
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.63,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const ShimmerProductCard(),
      ),
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
              // Shimmer grid when category loading (isInitialized = true, products cleared)
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
              // Empty state inside the scroll view
              else if (!state.isLoading && state.products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AppEmptyWidget(
                    icon: Icons.search_off_rounded,
                    title: LocaleKeys.noResults.tr(),
                    subtitle: LocaleKeys.noResultsDescription.tr(),
                  ),
                )
              // Normal products grid
              else
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
                      (context, index) {
                        if (index == state.products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          isFavorite: _favorites.contains(product.id),
                          onFavoriteTap: () => _toggleFavorite(product.id),
                          onTap: () => context
                              .push(AppRoutes.productDetailPath(product.id)),
                        );
                      },
                      childCount: state.products.length +
                          (state.isLoadingMore ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
