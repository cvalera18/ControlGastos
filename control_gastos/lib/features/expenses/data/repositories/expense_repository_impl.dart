import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/data/datasources/expense_local_datasource.dart';
import 'package:control_gastos/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:control_gastos/features/expenses/data/mappers/expense_mapper.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remote;
  final ExpenseLocalDataSource local;

  ExpenseRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String userId) async {
    try {
      final models = await remote.getExpenses(userId);
      try {
        await local.saveExpenses(models); // best-effort: no bloqueamos si falla caché
      } catch (_) {}
      return Right(models.map(ExpenseMapper.toDomain).toList());
    } on ServerException {
      try {
        final cached = await local.getExpenses(userId);
        return Right(cached.map(ExpenseMapper.toDomain).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory({required String userId, required String categoryId}) async {
    try {
      final models = await remote.getExpensesByCategory(userId: userId, categoryId: categoryId);
      return Right(models.map(ExpenseMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange({required String userId, required DateTime start, required DateTime end}) async {
    try {
      final models = await remote.getExpensesByDateRange(userId: userId, start: start, end: end);
      return Right(models.map(ExpenseMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addExpense(Expense expense) async {
    try {
      final model = ExpenseMapper.toModel(expense);
      await remote.addExpense(model);
      await local.saveExpense(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final model = ExpenseMapper.toModel(expense);
      await remote.updateExpense(model);
      await local.saveExpense(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await remote.deleteExpense(expenseId);
      await local.deleteExpense(expenseId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<Expense>> watchExpenses(String userId) {
    return remote.watchExpenses(userId).map((models) => models.map(ExpenseMapper.toDomain).toList());
  }
}
