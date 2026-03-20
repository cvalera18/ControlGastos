import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class UpdateRecurringExpenseUseCase {
  final RecurringExpenseRepository repository;
  const UpdateRecurringExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(RecurringExpense expense) =>
      repository.updateRecurringExpense(expense);
}
