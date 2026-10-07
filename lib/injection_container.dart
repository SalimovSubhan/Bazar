import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'core/services/connectivity_cubit.dart';
import 'core/utils/scroll_to_top_notifier.dart';
import 'data/datasources/favorite_local_datasource.dart';
import 'data/datasources/product_local_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/local/app_database.dart';
import 'data/repositories/favorite_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/favorite_repository.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/get_favorites_usecase.dart';
import 'domain/usecases/get_product_by_id_usecase.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'domain/usecases/search_products_usecase.dart';
import 'domain/usecases/toggle_favorite_usecase.dart';
import 'presentation/blocs/categories/categories_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/product_detail/product_detail_bloc.dart';
import 'presentation/blocs/products/products_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerSingleton<ScrollToTopNotifier>(ScrollToTopNotifier());
  sl.registerSingleton<InternetConnection>(InternetConnection());
  sl.registerSingleton<ConnectivityCubit>(ConnectivityCubit(sl()));
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<Dio>(createDio());

  // Local DB
  sl.registerSingleton<AppDatabase>(AppDatabase());

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSource(sl()),
  );
  sl.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSource(sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remote: sl(), local: sl()),
  );
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  // BLoCs / Cubits
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));
  sl.registerFactory<ProductsBloc>(
    () => ProductsBloc(getProducts: sl()),
  );
  sl.registerFactory<ProductDetailBloc>(
    () => ProductDetailBloc(getProductById: sl()),
  );
  sl.registerFactory<CategoriesBloc>(
    () => CategoriesBloc(getCategories: sl()),
  );
  sl.registerSingleton<FavoritesBloc>(
    FavoritesBloc(getFavorites: sl(), toggleFavorite: sl())
      ..add(const FavoritesSubscribed()),
  );
}
