import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_client.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/usecases/get_categories_usecase.dart';
import 'domain/usecases/get_product_by_id_usecase.dart';
import 'domain/usecases/get_products_usecase.dart';
import 'domain/usecases/search_products_usecase.dart';
import 'presentation/blocs/categories/categories_bloc.dart';
import 'presentation/blocs/product_detail/product_detail_bloc.dart';
import 'presentation/blocs/products/products_bloc.dart';
import 'presentation/blocs/theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerSingleton<Dio>(createDio());

  // Data
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));

  // BLoCs
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
}
