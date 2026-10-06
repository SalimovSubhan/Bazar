import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.discountPercentage,
    required super.rating,
    required super.stock,
    required super.brand,
    required super.category,
    required super.thumbnail,
    required super.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        discountPercentage: (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        stock: json['stock'] as int? ?? 0,
        brand: json['brand'] as String? ?? '',
        category: json['category'] as String,
        thumbnail: json['thumbnail'] as String,
        images: List<String>.from(json['images'] as List? ?? []),
      );
}
