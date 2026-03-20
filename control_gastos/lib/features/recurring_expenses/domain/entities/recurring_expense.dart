import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_frequency.dart';

class RecurringExpense extends Equatable {
  final String id;
  final String userId;
  final String name;
  final double amount;
  final String paymentMethodId;
  final String paymentMethodName;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final String? groupId;
  final RecurringFrequency frequency;

  /// Day of month (1–31) used for monthly frequency.
  /// For annual, the day/month are derived from [startDate].
  /// For weekly/biweekly, this field is ignored.
  final int dayOfMonth;

  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextDueDate;
  final DateTime? lastGeneratedDate;
  final bool isActive;
  final String? notes;

  const RecurringExpense({
    required this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.paymentMethodId,
    required this.paymentMethodName,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    this.groupId,
    required this.frequency,
    required this.dayOfMonth,
    required this.startDate,
    this.endDate,
    required this.nextDueDate,
    this.lastGeneratedDate,
    this.isActive = true,
    this.notes,
  });

  RecurringExpense copyWith({
    String? id,
    String? userId,
    String? name,
    double? amount,
    String? paymentMethodId,
    String? paymentMethodName,
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    int? categoryColor,
    String? groupId,
    RecurringFrequency? frequency,
    int? dayOfMonth,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDueDate,
    DateTime? lastGeneratedDate,
    bool? isActive,
    String? notes,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      groupId: groupId ?? this.groupId,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  /// Calculates the next due date after [from].
  DateTime computeNextDueDate(DateTime from) {
    switch (frequency) {
      case RecurringFrequency.weekly:
        return from.add(const Duration(days: 7));
      case RecurringFrequency.biweekly:
        return from.add(const Duration(days: 14));
      case RecurringFrequency.monthly:
        int month = from.month + 1;
        int year = from.year;
        if (month > 12) {
          month = 1;
          year++;
        }
        final lastDay = DateTime(year, month + 1, 0).day;
        final day = dayOfMonth.clamp(1, lastDay);
        return DateTime(year, month, day);
      case RecurringFrequency.annual:
        final lastDay = DateTime(from.year + 1, from.month + 1, 0).day;
        final day = from.day.clamp(1, lastDay);
        return DateTime(from.year + 1, from.month, day);
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        amount,
        paymentMethodId,
        categoryId,
        groupId,
        frequency,
        dayOfMonth,
        startDate,
        endDate,
        nextDueDate,
        lastGeneratedDate,
        isActive,
        notes,
      ];
}
