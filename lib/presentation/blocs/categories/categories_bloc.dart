import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_categories_usecase.dart';

// Events
abstract class CategoriesEvent extends Equatable {
  const CategoriesEvent();
}

class CategoriesLoadRequested extends CategoriesEvent {
  const CategoriesLoadRequested();
  @override
  List<Object?> get props => [];
}

// States
sealed class CategoriesState extends Equatable {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  @override
  List<Object?> get props => [];
}

class CategoriesLoading extends CategoriesState {
  @override
  List<Object?> get props => [];
}

class CategoriesLoaded extends CategoriesState {
  final List<String> categories;
  const CategoriesLoaded(this.categories);
  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  final String message;
  const CategoriesError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase _getCategories;

  CategoriesBloc({required GetCategoriesUseCase getCategories})
      : _getCategories = getCategories,
        super(CategoriesInitial()) {
    on<CategoriesLoadRequested>(_onLoad);
  }

  Future<void> _onLoad(
    CategoriesLoadRequested event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await _getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      emit(CategoriesError(e.toString()));
    }
  }
}
