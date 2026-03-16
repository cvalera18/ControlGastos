import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/groups/domain/repositories/group_repository.dart';

class JoinGroupParams {
  final String inviteCode;
  final String userId;

  const JoinGroupParams({required this.inviteCode, required this.userId});
}

class JoinGroupUseCase {
  final GroupRepository repository;

  const JoinGroupUseCase(this.repository);

  Future<Either<Failure, void>> call(JoinGroupParams params) async {
    final result = await repository.getGroupByInviteCode(params.inviteCode);
    return result.fold(
      (failure) => Left(failure),
      (group) async {
        if (group == null) {
          return const Left(ServerFailure('Código inválido'));
        }
        return repository.joinGroup(group.id, params.userId);
      },
    );
  }
}
