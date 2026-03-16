import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class GetGroupExpensesUseCase {
  final GroupRepository repository;

  const GetGroupExpensesUseCase(this.repository);

  Future<Either<Failure, List<GroupExpense>>> call(String groupId) {
    return repository.getGroupExpenses(groupId);
  }
}
