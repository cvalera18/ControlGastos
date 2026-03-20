import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class GetRecurringExpensesByPaymentMethodUseCase {
  final RecurringExpenseRepository repository;

  const GetRecurringExpensesByPaymentMethodUseCase(this.repository);

  Future<Either<Failure, List<RecurringExpense>>> call(
      String userId, String paymentMethodId) {
    return repository.getByPaymentMethod(userId, paymentMethodId);
  }
}
