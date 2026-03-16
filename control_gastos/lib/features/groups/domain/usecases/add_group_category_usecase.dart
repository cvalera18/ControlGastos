import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_category_repository.dart';

class AddGroupCategoryUseCase {
  final GroupCategoryRepository repository;
  const AddGroupCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(GroupCategory category) =>
      repository.addGroupCategory(category);
}
