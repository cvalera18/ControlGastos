import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/auth/domain/entities/user.dart';
import 'package:control_gastos/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) {
    return repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
