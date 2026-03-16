import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/domain/repositories/income_repository.dart';

class AddIncomeUseCase {
  final IncomeRepository repository;
  AddIncomeUseCase(this.repository);

  Future<Either<Failure, void>> call(Income income) =>
      repository.addIncome(income);
}
