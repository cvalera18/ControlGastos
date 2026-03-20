import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';

abstract class RecurringExpenseRepository {
  Future<Either<Failure, List<RecurringExpense>>> getRecurringExpenses(String userId);
  Future<Either<Failure, List<RecurringExpense>>> getByPaymentMethod(String userId, String paymentMethodId);
  Future<Either<Failure, void>> addRecurringExpense(RecurringExpense expense);
  Future<Either<Failure, void>> updateRecurringExpense(RecurringExpense expense);
  Future<Either<Failure, void>> deleteRecurringExpense(String id);
}
