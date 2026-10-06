import '../entities/product.dart';
import '../repositories/product_repository.dart';

class SearchProductsUseCase {
  final ProductRepository _repo;
  const SearchProductsUseCase(this._repo);

  Future<List<Product>> call(String query) => _repo.searchProducts(query);
}
