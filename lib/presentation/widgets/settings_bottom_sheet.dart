import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../app/theme/app_colors.dart';
import '../../core/constants/locale_keys.dart';
import '../../core/utils/app_extensions.dart';
import '../blocs/locale/locale_cubit.dart';
import '../blocs/theme/theme_cubit.dart';

void showSettingsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ThemeCubit>(),
      child: const _SettingsSheet(),
    ),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final borderColor =
        context.isDark ? AppColors.borderDark : AppColors.borderLight;
    final bgColor =
        context.isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(LocaleKeys.settings.tr(),
                  style: context.textTheme.headlineSmall),
            ],
          ),
          const SizedBox(height: 16),

          // Dark theme toggle
          BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, mode) {
              final isDark = mode == ThemeMode.dark;
              return _SettingsTile(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                title: LocaleKeys.darkTheme.tr(),
                trailing: Switch.adaptive(
                  value: isDark,
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withAlpha(120),
                  onChanged: (_) => context.read<ThemeCubit>().toggle(),
                ),
              );
            },
          ),

          Divider(color: borderColor, height: 1),

          // Language selector
          _SettingsTile(
            icon: Icons.language_rounded,
            title: LocaleKeys.language.tr(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: LocaleCubit.supportedLocales.map((locale) {
                final isSelected = context.locale == locale;
                final name = LocaleCubit.localeNames[locale.languageCode] ?? '';
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: () => context.setLocale(locale),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            isSelected ? AppColors.primary : Colors.transparent,
                        foregroundColor:
                            isSelected ? Colors.white : subtitleColor,
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : borderColor,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(name),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleColor =
        context.isDark ? AppColors.subtitleDark : AppColors.subtitleLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: subtitleColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title, style: context.textTheme.bodyLarge),
          ),
          trailing,
        ],
      ),
    );
  }
}
