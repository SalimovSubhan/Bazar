import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../widgets/app_empty_widget.dart';
import '../../widgets/app_gradient_bar.dart';
import '../home/widgets/product_card.dart';
import '../home/widgets/shimmer_product_card.dart' show ShimmerProductCard;

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: AppGradientBar(
            title: Text(LocaleKeys.favoritesTitle.tr()),
            actions: state.favorites.isNotEmpty
                ? [
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      tooltip: LocaleKeys.clearAll.tr(),
                      onPressed: () => _confirmClearAll(context),
                    ),
                  ]
                : null,
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, FavoritesState state) {
    if (state.isLoading && state.favorites.isEmpty) {
      return _buildShimmer();
    }

    if (state.favorites.isEmpty) {
      return AppEmptyWidget(
        icon: Icons.favorite_outline_rounded,
        title: LocaleKeys.emptyFavorites.tr(),
        subtitle: LocaleKeys.emptyFavoritesDescription.tr(),
      );
    }

    return _buildGrid(context, state);
  }

  Widget _buildShimmer() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.63,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => const ShimmerProductCard(),
    );
  }

  Widget _buildGrid(BuildContext context, FavoritesState state) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.63,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = state.favorites[index];
                return ProductCard(
                  product: product,
                  isFavorite: true,
                  onFavoriteTap: () {
                    context
                        .read<FavoritesBloc>()
                        .add(FavoriteToggleRequested(product));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(
                        content: Text(LocaleKeys.removedFromFavorites.tr()),
                        duration: const Duration(seconds: 2),
                      ));
                  },
                  onTap: () =>
                      context.push(AppRoutes.productDetailPath(product.id)),
                );
              },
              childCount: state.favorites.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: Text(
                '${state.favorites.length} ${state.favorites.length == 1 ? 'item' : 'items'}',
                style: TextStyle(
                  fontSize: 13,
                  color: context.isDark
                      ? AppColors.subtitleDark
                      : AppColors.subtitleLight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(LocaleKeys.clearAll.tr()),
        content: const Text('Remove all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final favorites =
                  context.read<FavoritesBloc>().state.favorites.toList();
              for (final product in favorites) {
                context
                    .read<FavoritesBloc>()
                    .add(FavoriteToggleRequested(product));
              }
            },
            child: Text(LocaleKeys.clearAll.tr()),
          ),
        ],
      ),
    );
  }
}
