import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/domain/repositories/income_repository.dart';

class GetIncomesUseCase {
  final IncomeRepository repository;
  GetIncomesUseCase(this.repository);

  Future<Either<Failure, List<Income>>> call(String userId) =>
      repository.getIncomes(userId);
}
