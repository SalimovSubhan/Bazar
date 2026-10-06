import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/locale_keys.dart';
import '../../core/utils/app_extensions.dart';

class AppErrorWidget extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const AppErrorWidget({
    super.key,
    this.message,
    required this.onRetry,
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
                color: AppColors.error.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              LocaleKeys.errorTitle.tr(),
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ?? LocaleKeys.errorDescription.tr(),
              style: context.textTheme.bodyMedium
                  ?.copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(LocaleKeys.tryAgain.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
