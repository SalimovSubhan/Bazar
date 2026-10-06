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
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailBloc, ProductDetailState>(
      builder: (context, state) => Scaffold(
        appBar: AppGradientBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
          title: state is ProductDetailLoaded
              ? Text(
                  state.product.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
        ),
        body: switch (state) {
          ProductDetailInitial() ||
          ProductDetailLoading() =>
            const Center(child: CircularProgressIndicator()),
          ProductDetailError() => _ErrorBody(message: state.message),
          ProductDetailLoaded() => _ProductBody(product: state.product),
        },
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  const _ErrorBody({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message,
              style: TextStyle(
                  color: context.isDark
                      ? AppColors.subtitleDark
                      : AppColors.subtitleLight),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.pop(),
            child: Text(LocaleKeys.tryAgain.tr()),
          ),
        ],
      ),
    );
  }
}

class _ProductBody extends StatefulWidget {
  final Product product;
  const _ProductBody({required this.product});

  @override
  State<_ProductBody> createState() => _ProductBodyState();
}

class _ProductBodyState extends State<_ProductBody> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isDark = context.isDark;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final subtitleColor =
        isDark ? AppColors.subtitleDark : AppColors.subtitleLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;

    final images = p.images.isNotEmpty ? p.images : [p.thumbnail];

    return ListView(
      children: [
        // Image gallery
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                itemBuilder: (context, i) => CachedNetworkImage(
                  imageUrl: images[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => Container(color: bgColor),
                  errorWidget: (_, __, ___) => Container(
                    color: bgColor,
                    child: const Icon(Icons.image_not_supported_outlined,
                        size: 48),
                  ),
                ),
              ),
            ),
            if (images.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: images.length,
                  effect: WormEffect(
                    dotWidth: 8,
                    dotHeight: 8,
                    activeDotColor: AppColors.primary,
                    dotColor: borderColor,
                  ),
                ),
              ),
          ],
        ),

        // Info card
        Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  p.category.titleCase,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Title
              Text(p.title, style: context.textTheme.headlineSmall),
              const SizedBox(height: 4),

              // Brand
              if (p.brand.isNotEmpty)
                Text(p.brand,
                    style: context.textTheme.bodyMedium
                        ?.copyWith(color: subtitleColor)),
              const SizedBox(height: 12),

              // Rating + stock
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.star, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    p.rating.toStringAsFixed(1),
                    style: context.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    p.isInStock
                        ? Icons.check_circle_outline_rounded
                        : Icons.cancel_outlined,
                    size: 16,
                    color: p.isInStock ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p.isInStock
                        ? '${p.stock} ${LocaleKeys.stock.tr()}'
                        : LocaleKeys.outOfStock.tr(),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: p.isInStock ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: borderColor),
              const SizedBox(height: 16),

              // Price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    p.finalPrice.priceFormatted,
                    style: context.textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (p.hasDiscount) ...[
                    const SizedBox(width: 10),
                    Text(
                      p.price.priceFormatted,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: subtitleColor,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.discount,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '-${p.discountPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: borderColor),
              const SizedBox(height: 16),

              // Description
              Text(LocaleKeys.description.tr(),
                  style: context.textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                p.description,
                style: context.textTheme.bodyMedium
                    ?.copyWith(color: subtitleColor, height: 1.6),
              ),
              const SizedBox(height: 24),

              // CTA button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Add to Cart'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
