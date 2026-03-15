import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/auth/domain/entities/user.dart';
import 'package:control_gastos/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(RegisterParams params) {
    return repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
    );
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String password;
  final String name;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}
