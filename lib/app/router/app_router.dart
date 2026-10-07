import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/categories/categories_screen.dart';
import '../../presentation/screens/category_products/category_products_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/product_detail/product_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/widgets/main_scaffold.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const favorites = '/favorites';
  static const categories = '/categories';
  static const categoryProducts = '/category/:slug';
  static const search = '/search';
  static const productDetail = '/product/:id';

  static String productDetailPath(int id) => '/product/$id';
  static String categoryProductsPath(String slug) => '/category/$slug';
}

final navigatorKey = GlobalKey<NavigatorState>();

// Slide from right + fade — стандартный push
CustomTransitionPage<T> _slidePage<T>(LocalKey key, Widget child) =>
    CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );

// Slide from bottom — для модальных экранов (поиск)
CustomTransitionPage<T> _slideUpPage<T>(LocalKey key, Widget child) =>
    CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

final appRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainScaffold(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (_, __) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.favorites,
              builder: (_, __) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.categories,
      pageBuilder: (_, state) => _slidePage(state.pageKey, const CategoriesScreen()),
    ),
    GoRoute(
      path: AppRoutes.categoryProducts,
      pageBuilder: (_, state) => _slidePage(
        state.pageKey,
        CategoryProductsScreen(category: state.pathParameters['slug']!),
      ),
    ),
    GoRoute(
      path: AppRoutes.search,
      pageBuilder: (_, state) => _slideUpPage(state.pageKey, const SearchScreen()),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      pageBuilder: (_, state) => _slidePage(
        state.pageKey,
        ProductDetailScreen(productId: int.parse(state.pathParameters['id']!)),
      ),
    ),
  ],
);
