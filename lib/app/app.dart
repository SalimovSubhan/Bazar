import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/services/connectivity_cubit.dart';
import '../core/utils/fallback_localizations.dart';
import '../injection_container.dart';
import '../presentation/blocs/favorites/favorites_bloc.dart';
import '../presentation/blocs/theme/theme_cubit.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ThemeCubit>()),
        BlocProvider.value(value: sl<FavoritesBloc>()),
        BlocProvider.value(value: sl<ConnectivityCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'Bazar',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            locale: context.locale,
            localizationsDelegates: [
              ...context.localizationDelegates,
              const FallbackMaterialLocalizationsDelegate(),
              const FallbackCupertinoLocalizationsDelegate(),
            ],
            supportedLocales: context.supportedLocales,
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
