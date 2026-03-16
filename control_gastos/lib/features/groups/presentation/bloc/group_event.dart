part of 'group_bloc.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class FetchGroupsEvent extends GroupEvent {
  final String userId;
  const FetchGroupsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class CreateGroupEvent extends GroupEvent {
  final Group group;
  const CreateGroupEvent(this.group);

  @override
  List<Object> get props => [group];
}

class JoinGroupEvent extends GroupEvent {
  final String inviteCode;
  final String userId;
  const JoinGroupEvent({required this.inviteCode, required this.userId});

  @override
  List<Object> get props => [inviteCode, userId];
}

class FetchGroupExpensesEvent extends GroupEvent {
  final String groupId;
  const FetchGroupExpensesEvent(this.groupId);

  @override
  List<Object> get props => [groupId];
}

class AddGroupExpenseEvent extends GroupEvent {
  final GroupExpense expense;
  const AddGroupExpenseEvent(this.expense);

  @override
  List<Object> get props => [expense];
}
