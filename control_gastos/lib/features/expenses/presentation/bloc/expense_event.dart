part of 'expense_bloc.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class FetchExpensesEvent extends ExpenseEvent {
  final String userId;
  const FetchExpensesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddExpenseEvent extends ExpenseEvent {
  final Expense expense;
  const AddExpenseEvent(this.expense);

  @override
  List<Object> get props => [expense];
}

class UpdateExpenseEvent extends ExpenseEvent {
  final Expense expense;
  const UpdateExpenseEvent(this.expense);

  @override
  List<Object> get props => [expense];
}

class DeleteExpenseEvent extends ExpenseEvent {
  final String expenseId;
  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object> get props => [expenseId];
}

class WatchExpensesEvent extends ExpenseEvent {
  final String userId;
  const WatchExpensesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}
