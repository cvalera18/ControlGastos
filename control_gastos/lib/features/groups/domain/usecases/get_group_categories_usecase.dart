import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_category_repository.dart';

class GetGroupCategoriesUseCase {
  final GroupCategoryRepository repository;
  const GetGroupCategoriesUseCase(this.repository);

  Future<Either<Failure, List<GroupCategory>>> call(String groupId) =>
      repository.getGroupCategories(groupId);
}
