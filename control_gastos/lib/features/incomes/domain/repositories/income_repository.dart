import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';

abstract class IncomeRepository {
  Future<Either<Failure, List<Income>>> getIncomes(String userId);
  Future<Either<Failure, List<Income>>> getGroupIncomes(String groupId);
  Future<Either<Failure, void>> addIncome(Income income);
  Future<Either<Failure, void>> updateIncome(Income income);
  Future<Either<Failure, void>> deleteIncome(String incomeId);
}
