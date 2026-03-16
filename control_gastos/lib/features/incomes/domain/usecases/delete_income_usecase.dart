import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/incomes/domain/repositories/income_repository.dart';

class DeleteIncomeUseCase {
  final IncomeRepository repository;
  DeleteIncomeUseCase(this.repository);

  Future<Either<Failure, void>> call(String incomeId) =>
      repository.deleteIncome(incomeId);
}
