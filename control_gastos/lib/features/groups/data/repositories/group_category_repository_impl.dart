import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/data/datasources/group_remote_datasource.dart';
import 'package:control_gastos/features/groups/data/mappers/group_category_mapper.dart';
import 'package:control_gastos/features/groups/data/models/group_category_model.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_category_repository.dart';

class GroupCategoryRepositoryImpl implements GroupCategoryRepository {
  final GroupRemoteDataSource remote;

  GroupCategoryRepositoryImpl(this.remote);

  @override
  Future<Either<Failure, List<GroupCategory>>> getGroupCategories(String groupId) async {
    try {
      final models = await remote.getGroupCategories(groupId);
      return Right(models.map(GroupCategoryMapper.toDomain).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> addGroupCategory(GroupCategory category) async {
    try {
      await remote.addGroupCategory(GroupCategoryMapper.toModel(category));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateGroupCategory(GroupCategory category) async {
    try {
      await remote.updateGroupCategory(GroupCategoryMapper.toModel(category));
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteGroupCategory(String groupId, String categoryId) async {
    try {
      await remote.deleteGroupCategory(groupId, categoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> seedDefaultGroupCategories(
      String groupId, String createdBy) async {
    try {
      const uuid = Uuid();
      for (final data in AppConstants.defaultGroupCategories) {
        final model = GroupCategoryModel(
          id: uuid.v4(),
          groupId: groupId,
          name: data['name'] as String,
          icon: data['icon'] as String,
          color: data['color'] as int,
          createdBy: createdBy,
        );
        await remote.addGroupCategory(model);
      }
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
