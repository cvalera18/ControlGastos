part of 'group_bloc.dart';

abstract class GroupState extends Equatable {
  const GroupState();

  @override
  List<Object?> get props => [];
}

class GroupInitial extends GroupState {
  const GroupInitial();
}

class GroupLoading extends GroupState {
  const GroupLoading();
}

class GroupsLoaded extends GroupState {
  final List<Group> groups;
  const GroupsLoaded(this.groups);

  @override
  List<Object> get props => [groups];
}

class GroupExpensesLoaded extends GroupState {
  final List<GroupExpense> expenses;
  const GroupExpensesLoaded(this.expenses);

  @override
  List<Object> get props => [expenses];
}

class GroupOperationSuccess extends GroupState {
  final String message;
  const GroupOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class GroupError extends GroupState {
  final String message;
  const GroupError(this.message);

  @override
  List<Object> get props => [message];
}
