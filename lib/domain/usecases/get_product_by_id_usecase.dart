import '../entities/product.dart';
import '../repositories/product_repository.dart';

class GetProductByIdUseCase {
  final ProductRepository _repo;
  const GetProductByIdUseCase(this._repo);

  Future<Product> call(int id) => _repo.getProductById(id);
}
