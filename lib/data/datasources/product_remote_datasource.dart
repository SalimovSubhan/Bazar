import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';
import '../models/products_response.dart';

class ProductRemoteDataSource {
  final Dio _dio;
  const ProductRemoteDataSource(this._dio);

  Future<ProductsResponse> getProducts({int page = 0, String? category}) async {
    final skip = page * ApiConstants.pageSize;
    final path = category != null
        ? '${ApiConstants.categoryPath}/$category'
        : ApiConstants.productsPath;

    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: {'limit': ApiConstants.pageSize, 'skip': skip},
    );
    return ProductsResponse.fromJson(response.data!);
  }

  Future<Product> getProductById(int id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.productsPath}/$id',
    );
    return ProductModel.fromJson(response.data!);
  }

  Future<List<String>> getCategories() async {
    final response = await _dio.get<List>(ApiConstants.categoriesPath);
    return List<String>.from(response.data!);
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.searchPath,
      queryParameters: {'q': query, 'limit': 20},
    );
    return ProductsResponse.fromJson(response.data!).products;
  }
}
