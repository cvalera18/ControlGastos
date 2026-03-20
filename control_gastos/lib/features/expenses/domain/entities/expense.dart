import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String description;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final String paymentMethodId;
  final String paymentMethodName;
  final DateTime date;
  final String? notes;
  final String? groupId;
  final bool isWithdrawal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.date,
    this.notes,
    this.groupId,
    this.isWithdrawal = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    String? paymentMethodId,
    String? paymentMethodName,
    DateTime? date,
    String? notes,
    String? groupId,
    bool? isWithdrawal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      groupId: groupId ?? this.groupId,
      isWithdrawal: isWithdrawal ?? this.isWithdrawal,
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
        categoryId,
        paymentMethodId,
        date,
        notes,
        groupId,
        isWithdrawal,
        createdAt,
        updatedAt,
      ];
}
