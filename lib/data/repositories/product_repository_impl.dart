import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;

  const ProductRepositoryImpl(this._remote, this._local);

  @override
  Future<({List<Product> products, bool hasMore})> getProducts({
    int page = 0,
    String? category,
  }) async {
    final cacheKey = category ?? '_all';

    try {
      final response =
          await _remote.getProducts(page: page, category: category);

      // Cache only the first page so offline shows fresh content.
      if (page == 0) {
        _local.cacheProducts(
          cacheKey: cacheKey,
          products: response.products,
          total: response.total,
        );
      }

      return (products: response.products, hasMore: response.hasMore);
    } catch (_) {
      // Fall back to cache only for the first page request.
      if (page == 0) {
        final cached = await _local.getCachedProducts(cacheKey);
        if (cached != null) {
          return (products: cached.products, hasMore: false);
        }
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(int id) => _remote.getProductById(id);

  @override
  Future<List<String>> getCategories() => _remote.getCategories();

  @override
  Future<List<Product>> searchProducts(String query) =>
      _remote.searchProducts(query);
}
