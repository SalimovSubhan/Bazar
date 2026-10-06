import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/get_favorites_usecase.dart';
import '../../../domain/usecases/toggle_favorite_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
}

class FavoritesSubscribed extends FavoritesEvent {
  const FavoritesSubscribed();
  @override
  List<Object?> get props => [];
}

class FavoriteToggleRequested extends FavoritesEvent {
  final Product product;
  const FavoriteToggleRequested(this.product);
  @override
  List<Object?> get props => [product];
}

// Internal — fired when the DB stream emits new data
class _FavoritesUpdated extends FavoritesEvent {
  final List<Product> products;
  const _FavoritesUpdated(this.products);
  @override
  List<Object?> get props => [products];
}

// ─── State ────────────────────────────────────────────────────────────────────

class FavoritesState extends Equatable {
  final List<Product> favorites;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
  });

  bool isFavorite(int productId) =>
      favorites.any((p) => p.id == productId);

  FavoritesState copyWith({
    List<Product>? favorites,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      FavoritesState(
        favorites: favorites ?? this.favorites,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );

  @override
  List<Object?> get props => [favorites, isLoading, error];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoritesUseCase _getFavorites;
  final ToggleFavoriteUseCase _toggleFavorite;
  StreamSubscription<List<Product>>? _subscription;

  FavoritesBloc({
    required GetFavoritesUseCase getFavorites,
    required ToggleFavoriteUseCase toggleFavorite,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        super(const FavoritesState()) {
    on<FavoritesSubscribed>(_onSubscribed);
    on<FavoriteToggleRequested>(_onToggle);
    on<_FavoritesUpdated>(_onUpdated);
  }

  Future<void> _onSubscribed(
    FavoritesSubscribed event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    await _subscription?.cancel();
    _subscription = _getFavorites().listen(
      (products) => add(_FavoritesUpdated(products)),
      onError: (Object e) =>
          emit(state.copyWith(isLoading: false, error: e.toString())),
    );
  }

  void _onUpdated(
    _FavoritesUpdated event,
    Emitter<FavoritesState> emit,
  ) {
    emit(state.copyWith(
      favorites: event.products,
      isLoading: false,
      clearError: true,
    ));
  }

  Future<void> _onToggle(
    FavoriteToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      await _toggleFavorite(event.product);
      // Stream subscription will push the updated list automatically.
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
