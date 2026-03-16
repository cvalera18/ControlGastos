import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/usecases/add_group_category_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/delete_group_category_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_group_categories_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/update_group_category_usecase.dart';

part 'group_category_event.dart';
part 'group_category_state.dart';

class GroupCategoryBloc extends Bloc<GroupCategoryEvent, GroupCategoryState> {
  final GetGroupCategoriesUseCase getGroupCategoriesUseCase;
  final AddGroupCategoryUseCase addGroupCategoryUseCase;
  final UpdateGroupCategoryUseCase updateGroupCategoryUseCase;
  final DeleteGroupCategoryUseCase deleteGroupCategoryUseCase;

  GroupCategoryBloc({
    required this.getGroupCategoriesUseCase,
    required this.addGroupCategoryUseCase,
    required this.updateGroupCategoryUseCase,
    required this.deleteGroupCategoryUseCase,
  }) : super(const GroupCategoryInitial()) {
    on<FetchGroupCategoriesEvent>(_onFetch);
    on<AddGroupCategoryEvent>(_onAdd);
    on<UpdateGroupCategoryEvent>(_onUpdate);
    on<DeleteGroupCategoryEvent>(_onDelete);
  }

  Future<void> _onFetch(FetchGroupCategoriesEvent event, Emitter<GroupCategoryState> emit) async {
    emit(const GroupCategoryLoading());
    final result = await getGroupCategoriesUseCase(event.groupId);
    result.fold(
      (f) => emit(GroupCategoryError(f.message)),
      (cats) => emit(GroupCategoryLoaded(cats)),
    );
  }

  Future<void> _onAdd(AddGroupCategoryEvent event, Emitter<GroupCategoryState> emit) async {
    final result = await addGroupCategoryUseCase(event.category);
    result.fold(
      (f) => emit(GroupCategoryError(f.message)),
      (_) => emit(const GroupCategoryOperationSuccess('Categoría creada')),
    );
  }

  Future<void> _onUpdate(UpdateGroupCategoryEvent event, Emitter<GroupCategoryState> emit) async {
    final result = await updateGroupCategoryUseCase(event.category);
    result.fold(
      (f) => emit(GroupCategoryError(f.message)),
      (_) => emit(const GroupCategoryOperationSuccess('Categoría actualizada')),
    );
  }

  Future<void> _onDelete(DeleteGroupCategoryEvent event, Emitter<GroupCategoryState> emit) async {
    final result = await deleteGroupCategoryUseCase(event.groupId, event.categoryId);
    result.fold(
      (f) => emit(GroupCategoryError(f.message)),
      (_) => emit(const GroupCategoryOperationSuccess('Categoría eliminada')),
    );
  }
}
