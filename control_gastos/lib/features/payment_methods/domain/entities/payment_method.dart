import 'package:equatable/equatable.dart';

class PaymentMethod extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  PaymentMethod copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object> get props => [id, userId, name, icon, isDefault];
}
