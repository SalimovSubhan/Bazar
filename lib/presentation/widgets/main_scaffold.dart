import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/locale_keys.dart';
import '../../core/utils/app_extensions.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainScaffold({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final borderColor =
        context.isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) => shell.goBranch(
            i,
            initialLocation: i == shell.currentIndex,
          ),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.storefront_outlined),
              selectedIcon: const Icon(Icons.storefront_rounded),
              label: LocaleKeys.homeTitle.tr(),
            ),
            NavigationDestination(
              icon: const Icon(Icons.favorite_outline_rounded),
              selectedIcon: const Icon(Icons.favorite_rounded),
              label: LocaleKeys.favoritesTitle.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
