import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_extensions.dart';
import '../../../../domain/entities/product.dart';
import '../../../widgets/favorite_button.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onFavoriteTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image ──────────────────────────────
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(url: product.thumbnail),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _DiscountBadge(
                          percent: product.discountPercentage.round()),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      onTap: onFavoriteTap,
                    ),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: context.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.brand,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.isDark
                            ? AppColors.subtitleDark
                            : AppColors.subtitleLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    _RatingRow(rating: product.rating),
                    const SizedBox(height: 5),
                    _PriceRow(product: product),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────

class _ProductImage extends StatelessWidget {
  final String url;

  const _ProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final baseColor =
        context.isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highColor =
        context.isDark ? AppColors.shimmerHighDark : AppColors.shimmerHighLight;

    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, __) => Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highColor,
        child: Container(color: Colors.white),
      ),
      errorWidget: (_, __, ___) => Container(
        color: baseColor,
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 36,
          color: context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight,
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final int percent;

  const _DiscountBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.discount,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '-$percent%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;

  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 13, color: AppColors.star),
        const SizedBox(width: 3),
        Text(
          rating.toStringAsFixed(1),
          style: context.textTheme.labelSmall?.copyWith(
            color: context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final Product product;

  const _PriceRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final priceColor =
        context.isDark ? AppColors.primaryLight : AppColors.primary;
    final strikeColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          product.finalPrice.priceFormatted,
          style: context.textTheme.titleSmall?.copyWith(
            color: priceColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 5),
          Text(
            product.price.priceFormatted,
            style: context.textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              decorationColor: strikeColor,
              color: strikeColor,
            ),
          ),
        ],
      ],
    );
  }
}
