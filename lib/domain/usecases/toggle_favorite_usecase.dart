import '../entities/product.dart';
import '../repositories/favorite_repository.dart';

class ToggleFavoriteUseCase {
  final FavoriteRepository _repo;

  ToggleFavoriteUseCase(this._repo);

  /// Returns true if the product is now a favorite, false if removed.
  Future<bool> call(Product product) async {
    final isFav = await _repo.isFavorite(product.id);
    if (isFav) {
      await _repo.removeFavorite(product.id);
      return false;
    } else {
      await _repo.addFavorite(product);
      return true;
    }
  }
}
