part of 'income_bloc.dart';

abstract class IncomeEvent extends Equatable {
  const IncomeEvent();
  @override
  List<Object?> get props => [];
}

class FetchIncomesEvent extends IncomeEvent {
  final String userId;
  const FetchIncomesEvent(this.userId);
  @override
  List<Object?> get props => [userId];
}

class FetchGroupIncomesEvent extends IncomeEvent {
  final String groupId;
  const FetchGroupIncomesEvent(this.groupId);
  @override
  List<Object?> get props => [groupId];
}

class AddIncomeEvent extends IncomeEvent {
  final Income income;
  const AddIncomeEvent(this.income);
  @override
  List<Object?> get props => [income];
}

class UpdateIncomeEvent extends IncomeEvent {
  final Income income;
  const UpdateIncomeEvent(this.income);
  @override
  List<Object?> get props => [income];
}

class DeleteIncomeEvent extends IncomeEvent {
  final String incomeId;
  const DeleteIncomeEvent(this.incomeId);
  @override
  List<Object?> get props => [incomeId];
}
