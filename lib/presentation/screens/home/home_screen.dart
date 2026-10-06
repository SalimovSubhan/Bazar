import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/mock/mock_products.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/app_empty_widget.dart';
import '../../widgets/home_app_bar.dart';
import '../../widgets/settings_bottom_sheet.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/shimmer_product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _selectedCategory;
  final Set<int> _favorites = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == null) return mockProducts;
    return mockProducts.where((p) => p.category == _selectedCategory).toList();
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
      setState(() => _selectedCategory = result);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          context.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: HomeAppBar(
        onCategoryTap: _openCategories,
        onSearchTap: () => context.push(AppRoutes.search),
        onSettingsTap: () => showSettingsSheet(context),
      ),
      body: _isLoading ? _buildShimmerGrid() : _buildContent(),
    );
  }

  Widget _buildShimmerGrid() {
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

  Widget _buildContent() {
    final products = _filteredProducts;

    if (products.isEmpty) {
      return AppEmptyWidget(
        icon: Icons.search_off_rounded,
        title: LocaleKeys.noResults.tr(),
        subtitle: LocaleKeys.noResultsDescription.tr(),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CategoryFilterBar(
              categories: mockCategories,
              selectedCategory: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
          const SliverToBoxAdapter(child: BannerCarousel()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.63,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = products[index];
                  return ProductCard(
                    product: product,
                    isFavorite: _favorites.contains(product.id),
                    onFavoriteTap: () => _toggleFavorite(product.id),
                    onTap: () =>
                        context.push(AppRoutes.productDetailPath(product.id)),
                  );
                },
                childCount: products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
