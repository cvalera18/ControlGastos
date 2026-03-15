import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';

class GetPaymentMethodsUseCase {
  final PaymentMethodRepository repository;

  const GetPaymentMethodsUseCase(this.repository);

  Future<Either<Failure, List<PaymentMethod>>> call(String userId) {
    return repository.getPaymentMethods(userId);
  }
}
