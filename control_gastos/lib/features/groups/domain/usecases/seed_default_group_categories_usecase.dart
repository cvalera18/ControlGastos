import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_category_repository.dart';

class SeedDefaultGroupCategoriesUseCase {
  final GroupCategoryRepository repository;
  const SeedDefaultGroupCategoriesUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId, String createdBy) =>
      repository.seedDefaultGroupCategories(groupId, createdBy);
}
