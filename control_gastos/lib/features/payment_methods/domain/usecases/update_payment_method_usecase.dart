import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';

class UpdatePaymentMethodUseCase {
  final PaymentMethodRepository repository;

  const UpdatePaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(PaymentMethod paymentMethod) {
    return repository.updatePaymentMethod(paymentMethod);
  }
}
