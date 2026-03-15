part of 'expense_bloc.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object?> get props => [];
}

class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

class ExpenseLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;

  ExpenseLoaded(this.expenses)
      : totalAmount = expenses.fold(0.0, (sum, e) => sum + e.amount);

  @override
  List<Object> get props => [expenses, totalAmount];
}

class ExpenseOperationSuccess extends ExpenseState {
  final String message;
  const ExpenseOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ExpenseError extends ExpenseState {
  final String message;
  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}
