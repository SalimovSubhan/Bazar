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
      builder: (_, __) => const CategoriesScreen(),
    ),
    GoRoute(
      path: AppRoutes.categoryProducts,
      builder: (context, state) {
        final slug = state.pathParameters['slug']!;
        return CategoryProductsScreen(category: slug);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (_, __) => const SearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return ProductDetailScreen(productId: id);
      },
    ),
  ],
);
