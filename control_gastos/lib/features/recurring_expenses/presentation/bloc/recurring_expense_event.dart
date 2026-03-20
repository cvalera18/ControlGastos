import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';

abstract class RecurringExpenseEvent extends Equatable {
  const RecurringExpenseEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecurringExpensesEvent extends RecurringExpenseEvent {
  final String userId;
  const FetchRecurringExpensesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddRecurringExpenseEvent extends RecurringExpenseEvent {
  final RecurringExpense expense;
  const AddRecurringExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateRecurringExpenseEvent extends RecurringExpenseEvent {
  final RecurringExpense expense;
  const UpdateRecurringExpenseEvent(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteRecurringExpenseEvent extends RecurringExpenseEvent {
  final String id;
  const DeleteRecurringExpenseEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GenerateDueExpensesEvent extends RecurringExpenseEvent {
  final String userId;
  const GenerateDueExpensesEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
