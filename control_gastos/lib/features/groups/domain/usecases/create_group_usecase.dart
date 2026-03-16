import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class CreateGroupUseCase {
  final GroupRepository repository;

  const CreateGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(Group group) {
    return repository.createGroup(group);
  }
}
