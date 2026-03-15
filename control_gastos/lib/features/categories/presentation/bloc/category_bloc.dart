import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/domain/usecases/add_category_usecase.dart';
import 'package:control_gastos/features/categories/domain/usecases/delete_category_usecase.dart';
import 'package:control_gastos/features/categories/domain/usecases/get_categories_usecase.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoryInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onFetchCategories(
    FetchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await getCategoriesUseCase(event.userId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onAddCategory(
    AddCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await addCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(const CategoryOperationSuccess('Categoría agregada correctamente')),
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await deleteCategoryUseCase(event.categoryId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => emit(const CategoryOperationSuccess('Categoría eliminada correctamente')),
    );
  }
}
