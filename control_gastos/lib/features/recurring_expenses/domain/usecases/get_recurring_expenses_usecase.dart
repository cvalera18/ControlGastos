import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class GetRecurringExpensesUseCase {
  final RecurringExpenseRepository repository;
  const GetRecurringExpensesUseCase(this.repository);

  Future<Either<Failure, List<RecurringExpense>>> call(String userId) =>
      repository.getRecurringExpenses(userId);
}
