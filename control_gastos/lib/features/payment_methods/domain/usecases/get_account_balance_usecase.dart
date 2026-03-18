import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class GetAccountBalanceParams {
  final String userId;
  final String paymentMethodId;
  final double initialBalance;
  final DateTime? since;

  const GetAccountBalanceParams({
    required this.userId,
    required this.paymentMethodId,
    required this.initialBalance,
    this.since,
  });
}

class GetAccountBalanceUseCase {
  final ExpenseRepository expenseRepository;

  GetAccountBalanceUseCase(this.expenseRepository);

  Future<Either<Failure, double>> call(GetAccountBalanceParams params) async {
    final result = await expenseRepository.getExpenses(params.userId);
    return result.fold(
      Left.new,
      (expenses) {
        final filtered = expenses.where((e) {
          if (e.paymentMethodId != params.paymentMethodId) return false;
          if (params.since != null && e.date.isBefore(params.since!)) return false;
          return true;
        });
        final spent = filtered.fold(0.0, (sum, e) => sum + e.amount);
        return Right(params.initialBalance - spent);
      },
    );
  }
}
