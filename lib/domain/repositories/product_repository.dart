import '../entities/product.dart';

abstract interface class ProductRepository {
  Future<({List<Product> products, bool hasMore})> getProducts({
    int page = 0,
    String? category,
  });

  Future<Product> getProductById(int id);

  Future<List<String>> getCategories();

  Future<List<Product>> searchProducts(String query);
}
