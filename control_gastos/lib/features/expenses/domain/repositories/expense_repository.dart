import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses(String userId);
  Future<Either<Failure, List<Expense>>> getExpensesByCategory({
    required String userId,
    required String categoryId,
  });
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  });
  Future<Either<Failure, void>> addExpense(Expense expense);
  Future<Either<Failure, void>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Stream<List<Expense>> watchExpenses(String userId);
}
