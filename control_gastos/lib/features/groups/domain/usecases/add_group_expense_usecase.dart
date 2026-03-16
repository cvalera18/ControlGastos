import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class AddGroupExpenseUseCase {
  final GroupRepository repository;

  const AddGroupExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(GroupExpense expense) {
    return repository.addGroupExpense(expense);
  }
}
