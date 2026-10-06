import 'package:flutter/material.dart';
import '../../core/constants/locale_keys.dart';

class BannerItem {
  final String titleKey;
  final String subtitleKey;
  final List<Color> gradient;
  final String emoji;

  const BannerItem({
    required this.titleKey,
    required this.subtitleKey,
    required this.gradient,
    required this.emoji,
  });
}

final mockBanners = <BannerItem>[
  BannerItem(
    titleKey: LocaleKeys.bannerSaleTitle,
    subtitleKey: LocaleKeys.bannerSaleSubtitle,
    gradient: const [Color(0xFF2563EB), Color(0xFF7C3AED)],
    emoji: '🛍️',
  ),
  BannerItem(
    titleKey: LocaleKeys.bannerNewTitle,
    subtitleKey: LocaleKeys.bannerNewSubtitle,
    gradient: const [Color(0xFFEF4444), Color(0xFFF97316)],
    emoji: '✨',
  ),
  BannerItem(
    titleKey: LocaleKeys.bannerShipTitle,
    subtitleKey: LocaleKeys.bannerShipSubtitle,
    gradient: const [Color(0xFF059669), Color(0xFF0EA5E9)],
    emoji: '🚀',
  ),
];
