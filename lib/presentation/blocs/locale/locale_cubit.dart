import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit(super.initial);

  void setLocale(BuildContext context, Locale locale) {
    context.setLocale(locale);
    emit(locale);
  }

  static const supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('tg'),
  ];

  static const localeNames = {
    'en': 'English',
    'ru': 'Русский',
    'tg': 'Тоҷикӣ',
  };
}
