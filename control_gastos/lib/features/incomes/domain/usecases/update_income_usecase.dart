import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/domain/repositories/income_repository.dart';

class UpdateIncomeUseCase {
  final IncomeRepository repository;
  UpdateIncomeUseCase(this.repository);

  Future<Either<Failure, void>> call(Income income) =>
      repository.updateIncome(income);
}
