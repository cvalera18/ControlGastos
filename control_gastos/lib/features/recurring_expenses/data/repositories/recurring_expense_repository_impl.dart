import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/recurring_expenses/data/datasources/recurring_expense_remote_datasource.dart';
import 'package:control_gastos/features/recurring_expenses/data/models/recurring_expense_model.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class RecurringExpenseRepositoryImpl implements RecurringExpenseRepository {
  final RecurringExpenseRemoteDataSource remoteDataSource;

  RecurringExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RecurringExpense>>> getRecurringExpenses(
      String userId) async {
    try {
      final models = await remoteDataSource.getRecurringExpenses(userId);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RecurringExpense>>> getByPaymentMethod(
      String userId, String paymentMethodId) async {
    try {
      final all = await remoteDataSource.getRecurringExpenses(userId);
      return Right(all.where((e) => e.paymentMethodId == paymentMethodId).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addRecurringExpense(
      RecurringExpense expense) async {
    try {
      await remoteDataSource
          .addRecurringExpense(RecurringExpenseModel.fromEntity(expense));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRecurringExpense(
      RecurringExpense expense) async {
    try {
      await remoteDataSource
          .updateRecurringExpense(RecurringExpenseModel.fromEntity(expense));
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecurringExpense(String id) async {
    try {
      await remoteDataSource.deleteRecurringExpense(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
