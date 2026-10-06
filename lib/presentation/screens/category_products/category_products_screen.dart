import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../injection_container.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/products/products_bloc.dart';
import '../../widgets/app_error_widget.dart';
import '../../widgets/app_gradient_bar.dart';
import '../home/widgets/product_card.dart';
import '../home/widgets/shimmer_product_card.dart' show ShimmerProductCard;

class CategoryProductsScreen extends StatelessWidget {
  final String category;

  const CategoryProductsScreen({super.key, required this.category});

  static const _emojis = <String, String>{
    'smartphones': '📱',
    'laptops': '💻',
    'tablets': '📲',
    'fragrances': '🌸',
    'skincare': '✨',
    'beauty': '💄',
    'groceries': '🛒',
    'furniture': '🛋️',
    'home-decoration': '🏠',
    'mens-shirts': '👔',
    'womens-dresses': '👗',
    'mens-shoes': '👟',
    'womens-shoes': '👠',
    'mens-watches': '⌚',
    'womens-watches': '💎',
    'sunglasses': '🕶️',
    'sports-accessories': '⚽',
    'vehicle': '🚗',
    'motorcycle': '🏍️',
    'womens-bags': '👜',
    'womens-jewellery': '💍',
    'kitchen-accessories': '🍳',
    'mobile-accessories': '🎧',
    'tops': '👕',
  };

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductsBloc>()
        ..add(ProductsCategoryChanged(category)),
      child: _CategoryProductsView(
        category: category,
        emoji: _emojis[category] ?? '🏷️',
      ),
    );
  }
}

class _CategoryProductsView extends StatefulWidget {
  final String category;
  final String emoji;

  const _CategoryProductsView({
    required this.category,
    required this.emoji,
  });

  @override
  State<_CategoryProductsView> createState() => _CategoryProductsViewState();
}

class _CategoryProductsViewState extends State<_CategoryProductsView> {
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppGradientBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(
              '${widget.emoji}  ${widget.category.titleCase}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, ProductsState state) {
    if (state.isLoading && state.products.isEmpty) {
      return _buildShimmer();
    }

    if (state.hasError && state.products.isEmpty) {
      return AppErrorWidget(
        onRetry: () => context
            .read<ProductsBloc>()
            .add(ProductsCategoryChanged(widget.category)),
      );
    }

    return _buildGrid(context, state);
  }

  Widget _buildShimmer() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.63,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerProductCard(),
    );
  }

  Widget _buildGrid(BuildContext context, ProductsState state) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, favState) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
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
                      onTap: () => context
                          .push(AppRoutes.productDetailPath(product.id)),
                    );
                  },
                  childCount: state.products.length,
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
        );
      },
    );
  }
}
