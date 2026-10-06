import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/mock/mock_categories.dart';
import '../../../core/utils/app_extensions.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _query = '';

  List<AppCategory> get _filtered {
    if (_query.isEmpty) return appCategories;
    final q = _query.toLowerCase();
    return appCategories
        .where((c) => c.key.replaceAll('-', ' ').contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor =
        context.isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final cardColor =
        context.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        context.isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(LocaleKeys.categories.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (q) => setState(() => _query = q),
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: LocaleKeys.searchCategoriesHint.tr(),
                suffixIcon:
                    Icon(Icons.search_rounded, color: subtitleColor, size: 20),
              ),
            ),
          ),
          // Grid
          Expanded(
            child: _filtered.isEmpty
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
                      childAspectRatio: 0.88,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final cat = _filtered[index];
                      return _CategoryCard(
                        category: cat,
                        cardColor: cardColor,
                        borderColor: borderColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AppCategory category;
  final Color cardColor;
  final Color borderColor;

  const _CategoryCard({
    required this.category,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(category.key),
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
              category.emoji,
              style: const TextStyle(fontSize: 40, height: 1),
            ),
            const SizedBox(height: 8),
            Text(
              category.key.titleCase,
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
