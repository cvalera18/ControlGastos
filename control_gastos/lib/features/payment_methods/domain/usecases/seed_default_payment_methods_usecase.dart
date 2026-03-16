import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';
import 'package:control_gastos/features/payment_methods/domain/repositories/payment_method_repository.dart';

class SeedDefaultPaymentMethodsUseCase {
  final PaymentMethodRepository repository;

  const SeedDefaultPaymentMethodsUseCase(this.repository);

  Future<void> call(String userId) async {
    for (final method in AppConstants.defaultPaymentMethods) {
      final paymentMethod = PaymentMethod(
        id: const Uuid().v4(),
        userId: userId,
        name: method['name'] as String,
        icon: method['icon'] as String,
        type: PaymentMethodType.fromString(method['type'] as String?),
        isDefault: true,
      );
      await repository.addPaymentMethod(paymentMethod);
    }
  }
}
