import '../../domain/entities/product.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _dataSource;

  FavoriteRepositoryImpl(this._dataSource);

  @override
  Stream<List<Product>> watchFavorites() => _dataSource.watchFavorites();

  @override
  Future<void> addFavorite(Product product) =>
      _dataSource.addFavorite(product);

  @override
  Future<void> removeFavorite(int productId) =>
      _dataSource.removeFavorite(productId);

  @override
  Future<bool> isFavorite(int productId) =>
      _dataSource.isFavorite(productId);
}
