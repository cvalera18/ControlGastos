class ExpenseFilter {
  final DateTime startDate;
  final DateTime endDate;
  final Set<String> categoryIds;
  final Set<String> paymentMethodIds;

  ExpenseFilter({
    required this.startDate,
    required this.endDate,
    this.categoryIds = const {},
    this.paymentMethodIds = const {},
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
  }) {
    return ExpenseFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      paymentMethodIds: paymentMethodIds ?? this.paymentMethodIds,
    );
  }

  bool get hasExtraFilters => categoryIds.isNotEmpty || paymentMethodIds.isNotEmpty;

  int get activeFilterCount {
    int count = 1; // date range always counts
    if (categoryIds.isNotEmpty) count++;
    if (paymentMethodIds.isNotEmpty) count++;
    return count;
  }

  String get monthLabel {
    const months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${months[startDate.month - 1]} ${startDate.year}';
  }

  bool get isDefaultMonthFilter {
    final def = ExpenseFilter.currentMonth();
    return startDate == def.startDate &&
        endDate.year == def.endDate.year &&
        endDate.month == def.endDate.month &&
        endDate.day == def.endDate.day &&
        categoryIds.isEmpty &&
        paymentMethodIds.isEmpty;
  }
}
