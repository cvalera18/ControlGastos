import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';

abstract class PaymentMethodRepository {
  Future<Either<Failure, List<PaymentMethod>>> getPaymentMethods(String userId);
  Future<Either<Failure, void>> addPaymentMethod(PaymentMethod paymentMethod);
  Future<Either<Failure, void>> updatePaymentMethod(PaymentMethod paymentMethod);
  Future<Either<Failure, void>> deletePaymentMethod(String paymentMethodId);
}
