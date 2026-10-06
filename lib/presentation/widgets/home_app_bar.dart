import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/locale_keys.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCategoryTap;
  final VoidCallback onSearchTap;
  final VoidCallback onSettingsTap;

  const HomeAppBar({
    super.key,
    required this.onCategoryTap,
    required this.onSearchTap,
    required this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            tooltip: LocaleKeys.categories.tr(),
            onPressed: onCategoryTap,
          ),
          title: _SearchTapTarget(onTap: onSearchTap),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              tooltip: LocaleKeys.settings.tr(),
              onPressed: onSettingsTap,
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}

class _SearchTapTarget extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchTapTarget({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(70)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.white.withAlpha(200), size: 18),
            const SizedBox(width: 8),
            Text(
              LocaleKeys.searchHint.tr(),
              style: TextStyle(
                color: Colors.white.withAlpha(180),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
