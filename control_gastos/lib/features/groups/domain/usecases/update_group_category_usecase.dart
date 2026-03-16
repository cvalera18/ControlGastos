import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_category_repository.dart';

class UpdateGroupCategoryUseCase {
  final GroupCategoryRepository repository;
  const UpdateGroupCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(GroupCategory category) =>
      repository.updateGroupCategory(category);
}
