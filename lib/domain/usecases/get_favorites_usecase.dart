import '../entities/product.dart';
import '../repositories/favorite_repository.dart';

class GetFavoritesUseCase {
  final FavoriteRepository _repo;

  GetFavoritesUseCase(this._repo);

  Stream<List<Product>> call() => _repo.watchFavorites();
}
