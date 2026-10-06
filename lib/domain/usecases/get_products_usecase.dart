import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repo;
  const GetProductsUseCase(this._repo);

  Future<({List<Product> products, bool hasMore})> call({
    int page = 0,
    String? category,
  }) =>
      _repo.getProducts(page: page, category: category);
}
