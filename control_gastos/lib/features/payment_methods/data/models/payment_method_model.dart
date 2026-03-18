import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';

class PaymentMethodModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final PaymentMethodType type;
  final bool isDefault;
  final double? initialBalance;
  final DateTime? balanceStartDate;
  final double? creditLimit;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    this.type = PaymentMethodType.other,
    this.isDefault = false,
    this.initialBalance,
    this.balanceStartDate,
    this.creditLimit,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return PaymentMethodModel(
      id: id ?? json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      type: PaymentMethodType.fromString(json['type'] as String?),
      isDefault: json['isDefault'] as bool? ?? false,
      initialBalance: (json['initialBalance'] as num?)?.toDouble(),
      balanceStartDate: parseDate(json['balanceStartDate']),
      creditLimit: (json['creditLimit'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'type': type.name,
        'isDefault': isDefault,
        'initialBalance': initialBalance,
        // ISO string: compatible con jsonEncode (local cache) y con Firestore
        'balanceStartDate': balanceStartDate?.toIso8601String(),
        'creditLimit': creditLimit,
      };
}
