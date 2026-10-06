import '../../domain/entities/product.dart';
import 'product_model.dart';

class ProductsResponse {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const ProductsResponse({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + limit < total;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) => ProductsResponse(
        products: (json['products'] as List)
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: json['total'] as int,
        skip: json['skip'] as int,
        limit: json['limit'] as int,
      );
}
