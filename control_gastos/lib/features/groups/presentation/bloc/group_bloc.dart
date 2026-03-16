import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/domain/usecases/add_group_expense_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_group_expenses_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/get_groups_usecase.dart';
import 'package:control_gastos/features/groups/domain/usecases/join_group_usecase.dart';

part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetGroupsUseCase getGroupsUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final JoinGroupUseCase joinGroupUseCase;
  final GetGroupExpensesUseCase getGroupExpensesUseCase;
  final AddGroupExpenseUseCase addGroupExpenseUseCase;

  GroupBloc({
    required this.getGroupsUseCase,
    required this.createGroupUseCase,
    required this.joinGroupUseCase,
    required this.getGroupExpensesUseCase,
    required this.addGroupExpenseUseCase,
  }) : super(const GroupInitial()) {
    on<FetchGroupsEvent>(_onFetchGroups);
    on<CreateGroupEvent>(_onCreateGroup);
    on<JoinGroupEvent>(_onJoinGroup);
    on<FetchGroupExpensesEvent>(_onFetchGroupExpenses);
    on<AddGroupExpenseEvent>(_onAddGroupExpense);
  }

  Future<void> _onFetchGroups(
    FetchGroupsEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());
    final result = await getGroupsUseCase(event.userId);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (groups) => emit(GroupsLoaded(groups)),
    );
  }

  Future<void> _onCreateGroup(
    CreateGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());
    final result = await createGroupUseCase(event.group);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Grupo creado correctamente')),
    );
  }

  Future<void> _onJoinGroup(
    JoinGroupEvent event,
    Emitter<GroupState> emit,
  ) async {
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
    FetchGroupExpensesEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());
    final result = await getGroupExpensesUseCase(event.groupId);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (expenses) => emit(GroupExpensesLoaded(expenses)),
    );
  }

  Future<void> _onAddGroupExpense(
    AddGroupExpenseEvent event,
    Emitter<GroupState> emit,
  ) async {
    emit(const GroupLoading());
    final result = await addGroupExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(GroupError(failure.message)),
      (_) => emit(const GroupOperationSuccess('Gasto agregado correctamente')),
    );
  }
}
