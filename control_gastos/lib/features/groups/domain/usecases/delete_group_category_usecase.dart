import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_category_repository.dart';

class DeleteGroupCategoryUseCase {
  final GroupCategoryRepository repository;
  const DeleteGroupCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId, String categoryId) =>
      repository.deleteGroupCategory(groupId, categoryId);
}
