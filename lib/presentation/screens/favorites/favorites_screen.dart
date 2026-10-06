import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/locale_keys.dart';
import '../../widgets/app_empty_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.favoritesTitle.tr()),
      ),
      body: AppEmptyWidget(
        icon: Icons.favorite_outline_rounded,
        title: LocaleKeys.emptyFavorites.tr(),
        subtitle: LocaleKeys.emptyFavoritesDescription.tr(),
      ),
    );
  }
}
