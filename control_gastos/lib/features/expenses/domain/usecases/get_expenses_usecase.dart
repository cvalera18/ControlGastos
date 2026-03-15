import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesUseCase {
  final ExpenseRepository repository;

  const GetExpensesUseCase(this.repository);

  Future<Either<Failure, List<Expense>>> call(String userId) {
    return repository.getExpenses(userId);
  }
}
