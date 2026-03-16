import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';

class PaymentMethodModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final PaymentMethodType type;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    this.type = PaymentMethodType.other,
    this.isDefault = false,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json, {String? id}) => PaymentMethodModel(
        id: id ?? json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        type: PaymentMethodType.fromString(json['type'] as String?),
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'type': type.name,
        'isDefault': isDefault,
      };
}
