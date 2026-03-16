import 'package:equatable/equatable.dart';

class GroupExpense extends Equatable {
  final String id;
  final String groupId;
  final String userId;
  final String userName;
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
  final DateTime createdAt;

  const GroupExpense({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
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
    required this.createdAt,
  });

  GroupExpense copyWith({
    String? id,
    String? groupId,
    String? userId,
    String? userName,
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
    DateTime? createdAt,
  }) {
    return GroupExpense(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
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
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        userId,
        userName,
        amount,
        description,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColor,
        paymentMethodId,
        paymentMethodName,
        date,
        notes,
        createdAt,
      ];
}
