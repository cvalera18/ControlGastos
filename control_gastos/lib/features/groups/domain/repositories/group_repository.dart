import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';

abstract class GroupRepository {
  Future<Either<Failure, List<Group>>> getGroups(String userId);
  Future<Either<Failure, void>> createGroup(Group group);
  Future<Either<Failure, Group?>> getGroupByInviteCode(String code);
  Future<Either<Failure, void>> joinGroup(String groupId, String userId);
  Future<Either<Failure, List<GroupExpense>>> getGroupExpenses(String groupId);
  Future<Either<Failure, void>> addGroupExpense(GroupExpense expense);
  Future<Either<Failure, void>> updateGroupExpense(GroupExpense expense);
  Future<Either<Failure, void>> deleteGroupExpense(String expenseId);
  Future<Either<Failure, void>> deleteGroup(String groupId);
}
