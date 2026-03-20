import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ExpenseModel {
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

  const ExpenseModel({
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

  factory ExpenseModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return ExpenseModel(
      id: id ?? json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryIcon: json['categoryIcon'] as String? ?? '📦',
      categoryColor: json['categoryColor'] as int? ?? Colors.blue.toARGB32(),
      paymentMethodId: json['paymentMethodId'] as String,
      paymentMethodName: json['paymentMethodName'] as String,
      date: parseDate(json['date']),
      notes: json['notes'] as String?,
      groupId: json['groupId'] as String?,
      isWithdrawal: json['isWithdrawal'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'description': description,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categoryIcon': categoryIcon,
        'categoryColor': categoryColor,
        'paymentMethodId': paymentMethodId,
        'paymentMethodName': paymentMethodName,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'groupId': groupId,
        'isWithdrawal': isWithdrawal,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
