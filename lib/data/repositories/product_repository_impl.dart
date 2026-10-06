import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;

  const ProductRepositoryImpl(this._remote);

  @override
  Future<({List<Product> products, bool hasMore})> getProducts({
    int page = 0,
    String? category,
  }) async {
    final response = await _remote.getProducts(page: page, category: category);
    return (products: response.products, hasMore: response.hasMore);
  }

  @override
  Future<Product> getProductById(int id) => _remote.getProductById(id);

  @override
  Future<List<String>> getCategories() => _remote.getCategories();

  @override
  Future<List<Product>> searchProducts(String query) =>
      _remote.searchProducts(query);
}
