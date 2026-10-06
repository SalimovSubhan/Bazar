import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_extensions.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final high = context.isDark ? AppColors.shimmerHighDark : AppColors.shimmerHighLight;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: high,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(width: double.infinity, color: Colors.white),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 13, width: double.infinity, color: Colors.white),
                    const SizedBox(height: 5),
                    Container(height: 13, width: 120, color: Colors.white),
                    const Spacer(),
                    Container(height: 11, width: 70, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 15, width: 100, color: Colors.white),
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

class ShimmerCategoryBar extends StatelessWidget {
  const ShimmerCategoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final high = context.isDark ? AppColors.shimmerHighDark : AppColors.shimmerHighLight;

    return SizedBox(
      height: 48,
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: high,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Container(
            width: i == 0 ? 44 : 80 + (i % 2) * 20.0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final base = context.isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final high = context.isDark ? AppColors.shimmerHighDark : AppColors.shimmerHighLight;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: high,
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
