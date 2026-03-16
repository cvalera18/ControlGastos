import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String paymentMethodId;
  final String paymentMethodName;
  final DateTime date;
  final String? notes;
  final String? groupId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Income({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.date,
    this.notes,
    this.groupId,
    required this.createdAt,
    required this.updatedAt,
  });

  Income copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? paymentMethodId,
    String? paymentMethodName,
    DateTime? date,
    String? notes,
    String? groupId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Income(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        amount,
        description,
        paymentMethodId,
        date,
        notes,
        groupId,
        createdAt,
        updatedAt,
      ];
}
