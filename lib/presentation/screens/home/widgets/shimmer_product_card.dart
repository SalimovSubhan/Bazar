import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/app_extensions.dart';

class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor =
        context.isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBaseLight;
    final highlightColor =
        context.isDark ? AppColors.shimmerHighDark : AppColors.shimmerHighLight;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.white,
              ),
            ),
            // Text placeholders
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 13, width: double.infinity, color: Colors.white),
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
