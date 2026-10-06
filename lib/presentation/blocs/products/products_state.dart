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
  // true after the very first successful load — used to decide shimmer scope
  final bool isInitialized;

  const ProductsState({
    this.products = const [],
    this.selectedCategory,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.isInitialized = false,
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
    bool? isInitialized,
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
      isInitialized: isInitialized ?? this.isInitialized,
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
        isInitialized,
      ];
}
