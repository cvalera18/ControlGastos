import 'package:control_gastos/features/payment_methods/data/models/payment_method_model.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';

class PaymentMethodMapper {
  PaymentMethodMapper._();

  static PaymentMethod toDomain(PaymentMethodModel model) => PaymentMethod(
        id: model.id,
        userId: model.userId,
        name: model.name,
        icon: model.icon,
        isDefault: model.isDefault,
      );

  static PaymentMethodModel toModel(PaymentMethod entity) => PaymentMethodModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        icon: entity.icon,
        isDefault: entity.isDefault,
      );
}
