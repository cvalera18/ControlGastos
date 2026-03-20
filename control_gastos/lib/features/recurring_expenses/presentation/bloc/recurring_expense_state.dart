import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';

abstract class RecurringExpenseState extends Equatable {
  const RecurringExpenseState();

  @override
  List<Object?> get props => [];
}

class RecurringExpenseInitial extends RecurringExpenseState {
  const RecurringExpenseInitial();
}

class RecurringExpenseLoading extends RecurringExpenseState {
  const RecurringExpenseLoading();
}

class RecurringExpenseLoaded extends RecurringExpenseState {
  final List<RecurringExpense> expenses;
  const RecurringExpenseLoaded(this.expenses);

  @override
  List<Object?> get props => [expenses];
}

class RecurringExpenseOperationSuccess extends RecurringExpenseState {
  final String message;
  const RecurringExpenseOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted after [GenerateDueExpensesEvent] completes successfully.
/// [count] is the number of expense records created.
class RecurringExpenseGenerationDone extends RecurringExpenseState {
  final int count;
  const RecurringExpenseGenerationDone(this.count);

  @override
  List<Object?> get props => [count];
}

class RecurringExpenseError extends RecurringExpenseState {
  final String message;
  const RecurringExpenseError(this.message);

  @override
  List<Object?> get props => [message];
}
