import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/constants/locale_keys.dart';
import '../../../core/utils/app_extensions.dart';
import '../../../domain/entities/product.dart';
import '../../../injection_container.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/product_detail/product_detail_bloc.dart';
import '../../widgets/app_gradient_bar.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ProductDetailBloc>()..add(ProductDetailLoadRequested(productId)),
      child: _ProductDetailView(productId: productId),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  final int productId;
  const _ProductDetailView({required this.productId});

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, detailState) {
        final product = detailState is ProductDetailLoaded
            ? detailState.product
            : null;

        return BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, favState) {
            final isFavorite =
                product != null && favState.isFavorite(product.id);

            return Scaffold(
              backgroundColor: context.isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLight,
              appBar: AppGradientBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => context.pop(),
                ),
                title: product != null
                    ? Text(
                        product.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                actions: product != null
                    ? [
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(isFavorite),
                              color: isFavorite
                                  ? Colors.redAccent
                                  : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            context
                                .read<FavoritesBloc>()
                                .add(FavoriteToggleRequested(product));
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(SnackBar(
                                content: Text(isFavorite
                                    ? LocaleKeys.removedFromFavorites.tr()
                                    : LocaleKeys.addedToFavorites.tr()),
                                duration: const Duration(seconds: 2),
                              ));
                          },
                        ),
                      ]
                    : null,
              ),
              body: switch (detailState) {
                ProductDetailInitial() ||
                ProductDetailLoading() =>
                  const Center(child: CircularProgressIndicator()),
                ProductDetailError() => _ErrorBody(
                    message: detailState.message,
                    onRetry: () => context
                        .read<ProductDetailBloc>()
                        .add(ProductDetailLoadRequested(widget.productId)),
                  ),
                ProductDetailLoaded() =>
                  _ProductBody(product: detailState.product),
              },
              bottomNavigationBar:
                  product != null ? _BottomBar(product: product) : null,
            );
          },
        );
      },
    );
  }
}

// ─── Error body ────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              LocaleKeys.errorTitle.tr(),
              style: context.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style:
                  context.textTheme.bodyMedium?.copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(LocaleKeys.tryAgain.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product body ──────────────────────────────────────────────────────────────

class _ProductBody extends StatefulWidget {
  final Product product;

  const _ProductBody({required this.product});

  @override
  State<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<_ProductBody> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
  }

  void _onPageScroll() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) setState(() => _currentPage = page);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isDark = context.isDark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final subtitleColor =
        isDark ? AppColors.subtitleDark : AppColors.subtitleLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;

    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _ImageGallery(
          images: images,
          pageController: _pageController,
          currentPage: _currentPage,
          borderColor: borderColor,
          onPageChanged: (i) => setState(() => _currentPage = i),
        ),

        // Info card with rounded top corners
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category chip + stock badge row
              Row(
                children: [
                  _CategoryChip(category: p.category),
                  const Spacer(),
                  _StockBadge(isInStock: p.isInStock, stock: p.stock),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                p.title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

              // Brand
              if (p.brand.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      p.brand,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ] else
                const SizedBox(height: 8),

              // Visual star rating
              _StarRating(rating: p.rating),
              const SizedBox(height: 18),

              Divider(color: borderColor),
              const SizedBox(height: 18),

              // Price block
              _PriceBlock(product: p, subtitleColor: subtitleColor),
              const SizedBox(height: 18),

              Divider(color: borderColor),
              const SizedBox(height: 18),

              // Description
              Text(
                LocaleKeys.description.tr(),
                style: context.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                p.description,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: subtitleColor,
                  height: 1.65,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Image gallery ─────────────────────────────────────────────────────────────

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final PageController pageController;
  final int currentPage;
  final Color borderColor;
  final ValueChanged<int> onPageChanged;

  const _ImageGallery({
    required this.images,
    required this.pageController,
    required this.currentPage,
    required this.borderColor,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image with counter + dot indicator overlaid
        Stack(
          children: [
            Container(
              height: 300,
              color: Colors.white,
              child: PageView.builder(
                controller: pageController,
                itemCount: images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: CachedNetworkImage(
                    imageUrl: images[i],
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const SizedBox.shrink(),
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: AppColors.subtitleLight,
                    ),
                  ),
                ),
              ),
            ),

            // "1 / N" counter badge
            if (images.length > 1)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(130),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentPage + 1} / ${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

            // Dot indicator at bottom
            if (images.length > 1)
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Center(
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: images.length,
                    effect: WormEffect(
                      dotWidth: 7,
                      dotHeight: 7,
                      activeDotColor: AppColors.primary,
                      dotColor: borderColor,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Thumbnail strip
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 68,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final selected = i == currentPage;
                return GestureDetector(
                  onTap: () => pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? AppColors.primary : borderColor,
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withAlpha(50),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: CachedNetworkImage(
                        imageUrl: images[i],
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_outlined,
                          size: 24,
                          color: AppColors.subtitleLight,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ] else
          const SizedBox(height: 10),
      ],
    );
  }
}

// ─── Visual star rating ────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Row(
      children: [
        ...List.generate(5, (i) {
          final starValue = i + 1;
          final IconData icon;
          if (rating >= starValue) {
            icon = Icons.star_rounded;
          } else if (rating >= starValue - 0.5) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, color: AppColors.star, size: 22);
        }),
        const SizedBox(width: 8),
        Text(
          rating.toStringAsFixed(1),
          style: context.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Text(
          '/ 5',
          style:
              context.textTheme.bodySmall?.copyWith(color: subtitleColor),
        ),
      ],
    );
  }
}

// ─── Price block ───────────────────────────────────────────────────────────────

class _PriceBlock extends StatelessWidget {
  final Product product;
  final Color subtitleColor;

  const _PriceBlock(
      {required this.product, required this.subtitleColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          product.finalPrice.priceFormatted,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 10),
          Text(
            product.price.priceFormatted,
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
              decoration: TextDecoration.lineThrough,
              decorationColor: subtitleColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.discount,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '-${product.discountPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.titleCase,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Stock badge ───────────────────────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  final bool isInStock;
  final int stock;

  const _StockBadge({required this.isInStock, required this.stock});

  @override
  Widget build(BuildContext context) {
    final color = isInStock ? AppColors.success : AppColors.error;
    final label = isInStock
        ? '$stock ${LocaleKeys.stock.tr()}'
        : LocaleKeys.outOfStock.tr();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sticky bottom bar ─────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final Product product;

  const _BottomBar({required this.product});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final surfaceColor =
        isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final subtitleColor =
        isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              // Price column
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.hasDiscount)
                      Text(
                        product.price.priceFormatted,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: subtitleColor,
                        ),
                      ),
                    Text(
                      product.finalPrice.priceFormatted,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Add to cart button
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: Text(
                    LocaleKeys.addToCart.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
