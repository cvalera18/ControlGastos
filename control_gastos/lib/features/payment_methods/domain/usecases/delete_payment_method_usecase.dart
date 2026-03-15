import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';

class DeletePaymentMethodUseCase {
  final PaymentMethodRepository repository;

  const DeletePaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(String paymentMethodId) {
    return repository.deletePaymentMethod(paymentMethodId);
  }
}
