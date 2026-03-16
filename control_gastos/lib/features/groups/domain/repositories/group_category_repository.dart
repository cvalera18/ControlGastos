import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';

abstract class GroupCategoryRepository {
  Future<Either<Failure, List<GroupCategory>>> getGroupCategories(String groupId);
  Future<Either<Failure, void>> addGroupCategory(GroupCategory category);
  Future<Either<Failure, void>> updateGroupCategory(GroupCategory category);
  Future<Either<Failure, void>> deleteGroupCategory(String groupId, String categoryId);
  Future<Either<Failure, void>> seedDefaultGroupCategories(String groupId, String createdBy);
}
