import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class DeleteRecurringExpenseUseCase {
  final RecurringExpenseRepository repository;
  const DeleteRecurringExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) =>
      repository.deleteRecurringExpense(id);
}
