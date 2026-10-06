import '../repositories/product_repository.dart';

class GetCategoriesUseCase {
  final ProductRepository _repo;
  const GetCategoriesUseCase(this._repo);

  Future<List<String>> call() => _repo.getCategories();
}
