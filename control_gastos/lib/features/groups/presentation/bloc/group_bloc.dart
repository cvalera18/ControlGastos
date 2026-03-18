import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/domain/usecases/add_group_expense_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/update_group_expense_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/delete_group_expense_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/delete_group_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_group_expenses_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/join_group_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/seed_default_group_categories_usecase.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetGroupsUseCase getGroupsUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final JoinGroupUseCase joinGroupUseCase;
  final GetGroupExpensesUseCase getGroupExpensesUseCase;
  final AddGroupExpenseUseCase addGroupExpenseUseCase;
  final UpdateGroupExpenseUseCase updateGroupExpenseUseCase;
  final DeleteGroupExpenseUseCase deleteGroupExpenseUseCase;
  final DeleteGroupUseCase deleteGroupUseCase;
  final SeedDefaultGroupCategoriesUseCase seedDefaultGroupCategoriesUseCase;

  GroupBloc({
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.joinGroupUseCase,
    required this.getGroupExpensesUseCase,
    required this.addGroupExpenseUseCase,
    required this.updateGroupExpenseUseCase,
    required this.deleteGroupExpenseUseCase,
    required this.deleteGroupUseCase,
    required this.seedDefaultGroupCategoriesUseCase,
  }) : super(const GroupInitial()) {
    on<FetchGroupsEvent>(_onFetchGroups);
    on<CreateGroupEvent>(_onCreateGroup);
    on<JoinGroupEvent>(_onJoinGroup);
    on<FetchGroupExpensesEvent>(_onFetchGroupExpenses);
    on<AddGroupExpenseEvent>(_onAddGroupExpense);
    on<UpdateGroupExpenseEvent>(_onUpdateGroupExpense);
    on<DeleteGroupExpenseEvent>(_onDeleteGroupExpense);
    on<DeleteGroupEvent>(_onDeleteGroup);
  }

  Future<void> _onFetchGroups(FetchGroupsEvent event, Emitter<GroupState> emit) async {
    emit(const GroupLoading());
    final result = await getGroupsUseCase(event.userId);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (groups) => emit(GroupsLoaded(groups)),
    );
  }

  Future<void> _onCreateGroup(CreateGroupEvent event, Emitter<GroupState> emit) async {
    emit(const GroupLoading());
    final result = await createGroupUseCase(event.group);
    await result.fold(
      (failure) async => emit(GroupError(failure.message)),
      (_) async {
        await seedDefaultGroupCategoriesUseCase(event.group.id, event.group.createdBy);
        emit(const GroupOperationSuccess('Grupo creado correctamente'));
      },
    );
  }

  Future<void> _onJoinGroup(JoinGroupEvent event, Emitter<GroupState> emit) async {
    emit(const GroupLoading());
    final result = await joinGroupUseCase(
      JoinGroupParams(inviteCode: event.inviteCode, userId: event.userId),
    );
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Te uniste al grupo correctamente')),
    );
  }

  Future<void> _onFetchGroupExpenses(
      FetchGroupExpensesEvent event, Emitter<GroupState> emit) async {
    emit(const GroupLoading());
    final result = await getGroupExpensesUseCase(event.groupId);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (expenses) => emit(GroupExpensesLoaded(expenses)),
    );
  }

  Future<void> _onAddGroupExpense(AddGroupExpenseEvent event, Emitter<GroupState> emit) async {
    emit(const GroupLoading());
    final result = await addGroupExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Gasto agregado correctamente')),
    );
  }

  Future<void> _onUpdateGroupExpense(UpdateGroupExpenseEvent event, Emitter<GroupState> emit) async {
    final result = await updateGroupExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Gasto actualizado correctamente')),
    );
  }

  Future<void> _onDeleteGroupExpense(
      DeleteGroupExpenseEvent event, Emitter<GroupState> emit) async {
    final result = await deleteGroupExpenseUseCase(event.expenseId);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Gasto de grupo eliminado')),
    );
  }

  Future<void> _onDeleteGroup(DeleteGroupEvent event, Emitter<GroupState> emit) async {
    emit(const GroupLoading());
    final result = await deleteGroupUseCase(event.groupId);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Grupo eliminado correctamente')),
    );
  }
}
