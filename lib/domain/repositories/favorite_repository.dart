import '../entities/product.dart';

abstract interface class FavoriteRepository {
  Stream<List<Product>> watchFavorites();
  Future<void> addFavorite(Product product);
  Future<void> removeFavorite(int productId);
  Future<bool> isFavorite(int productId);
}
