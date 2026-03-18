enum TransactionType { all, expense, income }

class ExpenseFilter {
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> categoryIds;
  final Set<String> paymentMethodIds;
  final TransactionType transactionType;

  ExpenseFilter({
    required this.startDate,
    required this.endDate,
    this.categoryIds = const {},
    this.paymentMethodIds = const {},
    this.transactionType = TransactionType.all,
  });

  factory ExpenseFilter.currentMonth() {
    final now = DateTime.now();
    return ExpenseFilter(
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  ExpenseFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? categoryIds,
    Set<String>? paymentMethodIds,
    TransactionType? transactionType,
  }) {
    return ExpenseFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      paymentMethodIds: paymentMethodIds ?? this.paymentMethodIds,
      transactionType: transactionType ?? this.transactionType,
    );
  }

  bool get hasExtraFilters =>
      categoryIds.isNotEmpty ||
      paymentMethodIds.isNotEmpty ||
      transactionType != TransactionType.all;

  int get activeFilterCount {
    int count = 1; // date range always counts
    if (categoryIds.isNotEmpty) count++;
    if (paymentMethodIds.isNotEmpty) count++;
    if (transactionType != TransactionType.all) count++;
    return count;
  }

  String get monthLabel {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[startDate.month - 1]} ${startDate.year}';
  }

  bool get isFullMonth {
    if (startDate.day != 1) return false;
    final lastDay = DateTime(startDate.year, startDate.month + 1, 0);
    return endDate.day == lastDay.day &&
        endDate.month == startDate.month &&
        endDate.year == startDate.year;
  }

  /// Muestra el mes si es un mes completo, o el rango de fechas si es personalizado.
  String get displayLabel {
    if (isFullMonth) return monthLabel;
    String fmt(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${fmt(startDate)} – ${fmt(endDate)}';
  }

  bool get isDefaultMonthFilter {
    final def = ExpenseFilter.currentMonth();
    return startDate == def.startDate &&
        endDate.year == def.endDate.year &&
        endDate.month == def.endDate.month &&
        endDate.day == def.endDate.day &&
        categoryIds.isEmpty &&
        paymentMethodIds.isEmpty &&
        transactionType == TransactionType.all;
  }
}
