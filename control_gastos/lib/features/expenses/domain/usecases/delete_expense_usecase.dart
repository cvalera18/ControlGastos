import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {
  final ExpenseRepository repository;

  const DeleteExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String expenseId) {
    return repository.deleteExpense(expenseId);
  }
}
