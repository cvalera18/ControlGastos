import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class GetExpensesByCategoryUseCase {
  final ExpenseRepository repository;

  const GetExpensesByCategoryUseCase(this.repository);

  Future<Either<Failure, List<Expense>>> call(GetExpensesByCategoryParams params) {
    return repository.getExpensesByCategory(
      userId: params.userId,
      categoryId: params.categoryId,
    );
  }
}

class GetExpensesByCategoryParams extends Equatable {
  final String userId;
  final String categoryId;

  const GetExpensesByCategoryParams({
    required this.userId,
    required this.categoryId,
  });

  @override
  List<Object> get props => [userId, categoryId];
}
