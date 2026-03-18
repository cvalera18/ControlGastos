import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/payment_methods/data/datasources/payment_method_local_datasource.dart';
import 'package:control_gastos/features/payment_methods/data/datasources/payment_method_remote_datasource.dart';
import 'package:control_gastos/features/payment_methods/data/mappers/payment_method_mapper.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';

class PaymentMethodRepositoryImpl implements PaymentMethodRepository {
  final PaymentMethodRemoteDataSource remote;
  final PaymentMethodLocalDataSource local;

  PaymentMethodRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods(String userId) async {
    try {
      final models = await remote.getPaymentMethods(userId);
      try {
        await local.savePaymentMethods(models); // best-effort: no bloqueamos si falla caché
      } catch (_) {}
      return Right(models.map(PaymentMethodMapper.toDomain).toList());
    } on ServerException {
      try {
        final cached = await local.getPaymentMethods(userId);
        return Right(cached.map(PaymentMethodMapper.toDomain).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> addPaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final model = PaymentMethodMapper.toModel(paymentMethod);
      await remote.addPaymentMethod(model);
      await local.savePaymentMethods([model]);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updatePaymentMethod(PaymentMethod paymentMethod) async {
    try {
      final model = PaymentMethodMapper.toModel(paymentMethod);
      await remote.updatePaymentMethod(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePaymentMethod(String paymentMethodId) async {
    try {
      await remote.deletePaymentMethod(paymentMethodId);
      await local.deletePaymentMethod(paymentMethodId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
