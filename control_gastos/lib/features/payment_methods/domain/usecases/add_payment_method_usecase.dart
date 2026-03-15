import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';

class AddPaymentMethodUseCase {
  final PaymentMethodRepository repository;

  const AddPaymentMethodUseCase(this.repository);

  Future<Either<Failure, void>> call(PaymentMethod paymentMethod) {
    return repository.addPaymentMethod(paymentMethod);
  }
}
