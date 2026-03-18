import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final PaymentMethodType type;
  final bool isDefault;
  /// Saldo inicial para cuentas (checking, savings, vista, digital, cash).
  final double? initialBalance;
  /// Fecha interna: cuándo se registró el initialBalance. Gestionada automáticamente.
  final DateTime? balanceStartDate;
  /// Cupo disponible para tarjetas de crédito.
  final double? creditLimit;

  const PaymentMethod({
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

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    PaymentMethodType? type,
    bool? isDefault,
    double? initialBalance,
    DateTime? balanceStartDate,
    double? creditLimit,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      initialBalance: initialBalance ?? this.initialBalance,
      balanceStartDate: balanceStartDate ?? this.balanceStartDate,
      creditLimit: creditLimit ?? this.creditLimit,
    );
  }

  @override
  List<Object?> get props => [id, userId, name, icon, type, isDefault, initialBalance, balanceStartDate, creditLimit];
}
