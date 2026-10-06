import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
}

class ProductsLoadRequested extends ProductsEvent {
  const ProductsLoadRequested();
  @override
  List<Object?> get props => [];
}

class ProductsRefreshRequested extends ProductsEvent {
  const ProductsRefreshRequested();
  @override
  List<Object?> get props => [];
}

class ProductsLoadMoreRequested extends ProductsEvent {
  const ProductsLoadMoreRequested();
  @override
  List<Object?> get props => [];
}

class ProductsCategoryChanged extends ProductsEvent {
  final String? category;
  const ProductsCategoryChanged(this.category);
  @override
  List<Object?> get props => [category];
}
