import 'package:cloud_firestore/cloud_firestore.dart';

class GroupExpenseModel {
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

  const GroupExpenseModel({
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

  factory GroupExpenseModel.fromJson(Map<String, dynamic> json, {String? id}) => GroupExpenseModel(
        id: id ?? json['id'] as String,
        groupId: json['groupId'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        amount: (json['amount'] as num).toDouble(),
        description: json['description'] as String,
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        categoryIcon: json['categoryIcon'] as String,
        categoryColor: json['categoryColor'] as int,
        paymentMethodId: json['paymentMethodId'] as String,
        paymentMethodName: json['paymentMethodName'] as String,
        date: (json['date'] as Timestamp).toDate(),
        notes: json['notes'] as String?,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'groupId': groupId,
        'userId': userId,
        'userName': userName,
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
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
