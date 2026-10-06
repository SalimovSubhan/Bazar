import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/locale_keys.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainScaffold({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
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
    );
  }
}
