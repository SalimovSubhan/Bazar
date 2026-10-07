import 'package:dio/dio.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;
  final ProductLocalDataSource local;

  const ProductRepositoryImpl({required this.remote, required this.local});

  String _cacheKey(String? category, int page) =>
      '${category ?? 'all'}_$page';

  @override
  Future<({List<Product> products, bool hasMore})> getProducts({
    int page = 0,
    String? category,
  }) async {
    try {
      final response = await remote.getProducts(page: page, category: category);
      await local.cacheProducts(
        cacheKey: _cacheKey(category, page),
        products: response.products,
        total: response.products.length,
      );
      return (products: response.products, hasMore: response.hasMore);
    } on DioException {
      final cached = await local.getCachedProducts(_cacheKey(category, page));
      if (cached != null) {
        return (products: cached.products, hasMore: false);
      }
      rethrow;
    }
  }

  @override
  Future<Product> getProductById(int id) => remote.getProductById(id);

  @override
  Future<List<String>> getCategories() => remote.getCategories();

  @override
  Future<List<Product>> searchProducts(String query) =>
      remote.searchProducts(query);
}
