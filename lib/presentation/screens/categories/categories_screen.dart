import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../injection_container.dart';
import '../../blocs/categories/categories_bloc.dart';
import '../../widgets/app_gradient_bar.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoriesBloc>()..add(const CategoriesLoadRequested()),
      child: const _CategoriesView(),
    );
  }
}

class _CategoriesView extends StatefulWidget {
  const _CategoriesView();

  @override
  State<_CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<_CategoriesView> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final subtitleColor =
        isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppGradientBar(
        title: Text(LocaleKeys.categories.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CategoriesBloc, CategoriesState>(
        builder: (context, state) {
          if (state is CategoriesLoading || state is CategoriesInitial) {
            return _ShimmerGrid(isDark: isDark);
          }
          if (state is CategoriesError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 48, color: subtitleColor),
                  const SizedBox(height: 12),
                  Text(state.message,
                      style: TextStyle(color: subtitleColor),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<CategoriesBloc>()
                        .add(const CategoriesLoadRequested()),
                    child: Text(LocaleKeys.tryAgain.tr()),
                  ),
                ],
              ),
            );
          }

          final all = (state as CategoriesLoaded).categories;
          final filtered = _query.isEmpty
              ? all
              : all
                  .where((c) =>
                      c.replaceAll('-', ' ').contains(_query.toLowerCase()))
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  onChanged: (q) => setState(() => _query = q),
                  onTap: () => context.push(AppRoutes.search),
                  readOnly: true,
                  style: context.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: LocaleKeys.searchCategoriesHint.tr(),
                    suffixIcon: Icon(Icons.search_rounded,
                        color: subtitleColor, size: 20),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          LocaleKeys.noResults.tr(),
                          style: context.textTheme.bodyMedium
                              ?.copyWith(color: subtitleColor),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _CategoryCard(slug: filtered[index]);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ShimmerGrid extends StatelessWidget {
  final bool isDark;

  const _ShimmerGrid({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor =
        isDark ? AppColors.shimmerHighDark : AppColors.shimmerHighLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 18,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String slug;

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

  const _CategoryCard({required this.slug});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return GestureDetector(
      onTap: () => context.pop(slug),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _emojis[slug] ?? '🏷️',
              style: const TextStyle(fontSize: 36, height: 1),
            ),
            const SizedBox(height: 6),
            Text(
              slug.titleCase,
              style: context.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
