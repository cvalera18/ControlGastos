import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_frequency.dart';

class RecurringExpenseModel extends RecurringExpense {
  const RecurringExpenseModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.amount,
    required super.paymentMethodId,
    required super.paymentMethodName,
    required super.categoryId,
    required super.categoryName,
    required super.categoryIcon,
    required super.categoryColor,
    super.groupId,
    required super.frequency,
    required super.dayOfMonth,
    required super.startDate,
    super.endDate,
    required super.nextDueDate,
    super.lastGeneratedDate,
    super.isActive,
    super.notes,
  });

  factory RecurringExpenseModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    DateTime? parseDateOrNull(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return null;
    }

    return RecurringExpenseModel(
      id: id,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethodId: json['paymentMethodId'] as String? ?? '',
      paymentMethodName: json['paymentMethodName'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      categoryIcon: json['categoryIcon'] as String? ?? '📦',
      categoryColor: json['categoryColor'] as int? ?? Colors.blue.toARGB32(),
      groupId: json['groupId'] as String?,
      frequency: RecurringFrequency.fromJson(json['frequency'] as String? ?? 'monthly'),
      dayOfMonth: json['dayOfMonth'] as int? ?? 1,
      startDate: parseDate(json['startDate']),
      endDate: parseDateOrNull(json['endDate']),
      nextDueDate: parseDate(json['nextDueDate']),
      lastGeneratedDate: parseDateOrNull(json['lastGeneratedDate']),
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'amount': amount,
      'paymentMethodId': paymentMethodId,
      'paymentMethodName': paymentMethodName,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      if (groupId != null) 'groupId': groupId,
      'frequency': frequency.toJson,
      'dayOfMonth': dayOfMonth,
      'startDate': Timestamp.fromDate(startDate),
      if (endDate != null) 'endDate': Timestamp.fromDate(endDate!),
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      if (lastGeneratedDate != null)
        'lastGeneratedDate': Timestamp.fromDate(lastGeneratedDate!),
      'isActive': isActive,
      if (notes != null) 'notes': notes,
    };
  }

  factory RecurringExpenseModel.fromEntity(RecurringExpense entity) {
    return RecurringExpenseModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      amount: entity.amount,
      paymentMethodId: entity.paymentMethodId,
      paymentMethodName: entity.paymentMethodName,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      categoryIcon: entity.categoryIcon,
      categoryColor: entity.categoryColor,
      groupId: entity.groupId,
      frequency: entity.frequency,
      dayOfMonth: entity.dayOfMonth,
      startDate: entity.startDate,
      endDate: entity.endDate,
      nextDueDate: entity.nextDueDate,
      lastGeneratedDate: entity.lastGeneratedDate,
      isActive: entity.isActive,
      notes: entity.notes,
    );
  }
}
