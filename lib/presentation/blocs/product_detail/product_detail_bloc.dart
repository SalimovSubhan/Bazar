import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_product_by_id_usecase.dart';

// Events
abstract class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();
}

class ProductDetailLoadRequested extends ProductDetailEvent {
  final int id;
  const ProductDetailLoadRequested(this.id);
  @override
  List<Object?> get props => [id];
}

// States
sealed class ProductDetailState extends Equatable {
  const ProductDetailState();
}

class ProductDetailInitial extends ProductDetailState {
  @override
  List<Object?> get props => [];
}

class ProductDetailLoading extends ProductDetailState {
  @override
  List<Object?> get props => [];
}

class ProductDetailLoaded extends ProductDetailState {
  final Product product;
  const ProductDetailLoaded(this.product);
  @override
  List<Object?> get props => [product];
}

class ProductDetailError extends ProductDetailState {
  final String message;
  const ProductDetailError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  final GetProductByIdUseCase _getProductById;

  ProductDetailBloc({required GetProductByIdUseCase getProductById})
      : _getProductById = getProductById,
        super(ProductDetailInitial()) {
    on<ProductDetailLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    ProductDetailLoadRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(ProductDetailLoading());
    try {
      final product = await _getProductById(event.id);
      emit(ProductDetailLoaded(product));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }
}
