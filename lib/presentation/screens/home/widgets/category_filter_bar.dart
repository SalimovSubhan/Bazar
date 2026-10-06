import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/locale_keys.dart';
import '../../../../core/utils/app_extensions.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategory == null;
            return _CategoryChip(
              label: LocaleKeys.allCategories.tr(),
              isSelected: isSelected,
              onTap: () => onSelected(null),
            );
          }
          final cat = categories[index - 1];
          final isSelected = selectedCategory == cat;
          return _CategoryChip(
            label: cat.titleCase,
            isSelected: isSelected,
            onTap: () => onSelected(isSelected ? null : cat),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.primary
              : context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.colors.outline.withAlpha(80),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
