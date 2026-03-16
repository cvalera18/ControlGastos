import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
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

  const IncomeModel({
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

  factory IncomeModel.fromJson(Map<String, dynamic> json, {String? id}) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      return DateTime.now();
    }

    return IncomeModel(
      id: id ?? json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String,
      paymentMethodId: json['paymentMethodId'] as String,
      paymentMethodName: json['paymentMethodName'] as String,
      date: parseDate(json['date']),
      notes: json['notes'] as String?,
      groupId: json['groupId'] as String?,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'amount': amount,
        'description': description,
        'paymentMethodId': paymentMethodId,
        'paymentMethodName': paymentMethodName,
        'date': Timestamp.fromDate(date),
        'notes': notes,
        'groupId': groupId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
