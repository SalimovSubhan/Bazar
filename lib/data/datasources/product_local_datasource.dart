import 'dart:convert';

import '../../domain/entities/product.dart';
import '../local/app_database.dart';
import '../models/product_model.dart';

class ProductLocalDataSource {
  final AppDatabase _db;

  ProductLocalDataSource(this._db);

  Future<void> cacheProducts({
    required String cacheKey,
    required List<Product> products,
    required int total,
  }) {
    final json = jsonEncode(products
        .map((p) => {
              'id': p.id,
              'title': p.title,
              'description': p.description,
              'price': p.price,
              'discountPercentage': p.discountPercentage,
              'rating': p.rating,
              'stock': p.stock,
              'brand': p.brand,
              'category': p.category,
              'thumbnail': p.thumbnail,
              'images': p.images,
            })
        .toList());

    return _db.into(_db.cachedProducts).insertOnConflictUpdate(
          CachedProductsCompanion.insert(
            cacheKey: cacheKey,
            productsJson: json,
            total: total,
          ),
        );
  }

  Future<({List<Product> products, int total})?> getCachedProducts(
      String cacheKey) async {
    final row = await (_db.select(_db.cachedProducts)
          ..where((t) => t.cacheKey.equals(cacheKey)))
        .getSingleOrNull();

    if (row == null) return null;

    final list = (jsonDecode(row.productsJson) as List)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return (products: list, total: row.total);
  }
}
