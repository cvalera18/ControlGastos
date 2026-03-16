import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/incomes/data/datasources/income_remote_datasource.dart';
import 'package:control_gastos/features/incomes/data/mappers/income_mapper.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final IncomeRemoteDataSource remote;

  IncomeRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<Income>>> getIncomes(String userId) async {
    try {
      final models = await remote.getIncomes(userId);
      return Right(models.map(IncomeMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Income>>> getGroupIncomes(String groupId) async {
    try {
      final models = await remote.getGroupIncomes(groupId);
      return Right(models.map(IncomeMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addIncome(Income income) async {
    try {
      await remote.addIncome(IncomeMapper.toModel(income));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateIncome(Income income) async {
    try {
      await remote.updateIncome(IncomeMapper.toModel(income));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteIncome(String incomeId) async {
    try {
      await remote.deleteIncome(incomeId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
