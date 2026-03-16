import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final PaymentMethodType type;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    this.type = PaymentMethodType.other,
    this.isDefault = false,
  });

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    PaymentMethodType? type,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object> get props => [id, userId, name, icon, type, isDefault];
}
