import 'package:equatable/equatable.dart';
import '../../../domain/entities/product.dart';

class ProductsState extends Equatable {
  final List<Product> products;
  final String? selectedCategory;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const ProductsState({
    this.products = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  bool get hasError => error != null;

  static const _sentinel = Object();

  ProductsState copyWith({
    List<Product>? products,
    Object? selectedCategory = _sentinel,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    Object? error = _sentinel,
  }) {
    return ProductsState(
      products: products ?? this.products,
      selectedCategory: identical(selectedCategory, _sentinel)
          ? this.selectedCategory
          : selectedCategory as String?,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: identical(error, _sentinel) ? this.error : error as String?,
    );
  }

  @override
  List<Object?> get props => [
        products,
        selectedCategory,
        isLoading,
        isLoadingMore,
        hasMore,
        currentPage,
        error,
      ];
}
