import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:control_gastos/features/groups/data/mappers/group_expense_mapper.dart';
import 'package:control_gastos/features/groups/data/mappers/group_mapper.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource remote;

  GroupRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<Group>>> getGroups(String userId) async {
    try {
      final models = await remote.getGroups(userId);
      return Right(models.map(GroupMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> createGroup(Group group) async {
    try {
      final model = GroupMapper.toModel(group);
      await remote.createGroup(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Group?>> getGroupByInviteCode(String code) async {
    try {
      final model = await remote.getGroupByInviteCode(code);
      return Right(model != null ? GroupMapper.toDomain(model) : null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> joinGroup(String groupId, String userId) async {
    try {
      await remote.joinGroup(groupId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<GroupExpense>>> getGroupExpenses(String groupId) async {
    try {
      final models = await remote.getGroupExpenses(groupId);
      return Right(models.map(GroupExpenseMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addGroupExpense(GroupExpense expense) async {
    try {
      final model = GroupExpenseMapper.toModel(expense);
      await remote.addGroupExpense(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
