import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;

  const AddExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(Expense expense) {
    return repository.addExpense(expense);
  }
}
