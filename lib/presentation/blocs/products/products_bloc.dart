import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_products_usecase.dart';
import 'products_event.dart';
import 'products_state.dart';

export 'products_event.dart';
export 'products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProductsUseCase _getProducts;

  ProductsBloc({required GetProductsUseCase getProducts})
      : _getProducts = getProducts,
        super(const ProductsState()) {
    on<ProductsLoadRequested>(_onLoad);
    on<ProductsRefreshRequested>(_onRefresh);
    on<ProductsLoadMoreRequested>(_onLoadMore);
    on<ProductsCategoryChanged>(_onCategoryChanged);
  }

  Future<void> _onLoad(
    ProductsLoadRequested event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final result = await _getProducts(page: 0, category: state.selectedCategory);
      emit(state.copyWith(
        products: result.products,
        currentPage: 0,
        hasMore: result.hasMore,
        isLoading: false,
        isInitialized: true,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRefresh(
    ProductsRefreshRequested event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null, products: []));
    try {
      final result = await _getProducts(page: 0, category: state.selectedCategory);
      emit(state.copyWith(
        products: result.products,
        currentPage: 0,
        hasMore: result.hasMore,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    ProductsLoadMoreRequested event,
    Emitter<ProductsState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadingMore: true));
    try {
      final result =
          await _getProducts(page: nextPage, category: state.selectedCategory);
      emit(state.copyWith(
        products: [...state.products, ...result.products],
        currentPage: nextPage,
        hasMore: result.hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onCategoryChanged(
    ProductsCategoryChanged event,
    Emitter<ProductsState> emit,
  ) async {
    emit(state.copyWith(
      selectedCategory: event.category,
      products: [],
      isLoading: true,
      error: null,
    ));
    try {
      final result = await _getProducts(page: 0, category: event.category);
      emit(state.copyWith(
        products: result.products,
        currentPage: 0,
        hasMore: result.hasMore,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
