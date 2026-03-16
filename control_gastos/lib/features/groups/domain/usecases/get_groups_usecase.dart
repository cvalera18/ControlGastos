import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class GetGroupsUseCase {
  final GroupRepository repository;

  const GetGroupsUseCase(this.repository);

  Future<Either<Failure, List<Group>>> call(String userId) {
    return repository.getGroups(userId);
  }
}
