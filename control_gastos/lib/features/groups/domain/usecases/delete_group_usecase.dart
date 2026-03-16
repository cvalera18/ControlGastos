import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class DeleteGroupUseCase {
  final GroupRepository repository;
  const DeleteGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(String groupId) =>
      repository.deleteGroup(groupId);
}
