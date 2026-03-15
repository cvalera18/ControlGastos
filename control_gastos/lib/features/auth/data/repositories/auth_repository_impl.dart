import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:control_gastos/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:control_gastos/features/auth/data/mappers/user_mapper.dart';
import 'package:control_gastos/features/auth/domain/entities/user.dart';
import 'package:control_gastos/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, User>> login({required String email, required String password}) async {
    try {
      final model = await remote.login(email: email, password: password);
      await local.saveUserId(model.id);
      return Right(UserMapper.toDomain(model));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> register({required String email, required String password, required String name}) async {
    try {
      final model = await remote.register(email: email, password: password, name: name);
      await local.saveUserId(model.id);
      return Right(UserMapper.toDomain(model));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remote.logout();
      await local.clearUser();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final model = await remote.getCurrentUser();
      if (model == null) return const Right(null);
      return Right(UserMapper.toDomain(model));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remote.authStateChanges.map(
      (model) => model != null ? UserMapper.toDomain(model) : null,
    );
  }
}
