import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/mock/mock_products.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../core/utils/debouncer.dart';
import '../../../domain/entities/product.dart';
import '../../widgets/app_empty_widget.dart';
import '../../widgets/settings_bottom_sheet.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/product_card.dart';
import 'widgets/product_search_bar.dart';
import 'widgets/shimmer_product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _selectedCategory;
  String _searchQuery = '';
  final Set<int> _favorites = {};
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    var list = mockProducts;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.title.toLowerCase().contains(q) ||
              p.brand.toLowerCase().contains(q) ||
              p.category.toLowerCase().contains(q))
          .toList();
    }
    return list;
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

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Bazar',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.isDark
                      ? AppColors.primaryLight
                      : AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: LocaleKeys.settings.tr(),
            onPressed: () => showSettingsSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          ProductSearchBar(
            onChanged: (q) =>
                _debouncer(() => setState(() => _searchQuery = q)),
          ),
          // Categories
          CategoryFilterBar(
            categories: mockCategories,
            selectedCategory: _selectedCategory,
            onSelected: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 4),
          // Grid
          Expanded(
            child: _isLoading
                ? _buildShimmerGrid()
                : _buildProductGrid(),
          ),
        ],
      ),
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

  Widget _buildProductGrid() {
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.63,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              isFavorite: _favorites.contains(product.id),
              onFavoriteTap: () => _toggleFavorite(product.id),
              onTap: () => context.push(AppRoutes.productDetailPath(product.id)),
            );
          },
        ),
      ),
    );
  }
}
