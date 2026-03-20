import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class AddRecurringExpenseUseCase {
  final RecurringExpenseRepository repository;
  const AddRecurringExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(RecurringExpense expense) =>
      repository.addRecurringExpense(expense);
}
