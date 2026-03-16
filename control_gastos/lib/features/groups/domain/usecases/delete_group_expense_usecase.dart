import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class DeleteGroupExpenseUseCase {
  final GroupRepository repository;
  const DeleteGroupExpenseUseCase(this.repository);

  Future<Either<Failure, void>> call(String expenseId) =>
      repository.deleteGroupExpense(expenseId);
}
