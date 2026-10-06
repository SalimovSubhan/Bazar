import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/entities/product.dart';
import '../local/app_database.dart';
import '../models/product_model.dart';

class FavoriteLocalDataSource {
  final AppDatabase _db;

  FavoriteLocalDataSource(this._db);

  Stream<List<Product>> watchFavorites() {
    return (_db.select(_db.favorites)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows
            .map((r) => ProductModel.fromJson(
                jsonDecode(r.productJson) as Map<String, dynamic>))
            .toList());
  }

  Future<void> addFavorite(Product p) {
    final json = jsonEncode({
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
    });
    return _db.into(_db.favorites).insertOnConflictUpdate(
          FavoritesCompanion.insert(
            id: Value(p.id),
            productJson: json,
          ),
        );
  }

  Future<void> removeFavorite(int productId) {
    return (_db.delete(_db.favorites)
          ..where((t) => t.id.equals(productId)))
        .go();
  }

  Future<bool> isFavorite(int productId) async {
    final row = await (_db.select(_db.favorites)
          ..where((t) => t.id.equals(productId)))
        .getSingleOrNull();
    return row != null;
  }
}
