import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/app_extensions.dart';

class AppEmptyWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const AppEmptyWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: subtitleColor.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: subtitleColor.withAlpha(150)),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[const SizedBox(height: 28), action!],
          ],
        ),
      ),
    );
  }
}
