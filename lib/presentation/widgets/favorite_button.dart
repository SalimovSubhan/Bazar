import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  final double size;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          size: size * 0.55,
          color: isFavorite ? AppColors.discount : AppColors.subtitleLight,
        ),
      ),
    );
  }
}
