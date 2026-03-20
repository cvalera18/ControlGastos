enum RecurringFrequency {
  weekly,
  biweekly,
  monthly,
  annual;

  String get displayName {
    switch (this) {
      case RecurringFrequency.weekly:
        return 'Semanal';
      case RecurringFrequency.biweekly:
        return 'Quincenal';
      case RecurringFrequency.monthly:
        return 'Mensual';
      case RecurringFrequency.annual:
        return 'Anual';
    }
  }

  String get toJson => name;

  static RecurringFrequency fromJson(String value) =>
      RecurringFrequency.values.firstWhere(
        (e) => e.name == value,
        orElse: () => RecurringFrequency.monthly,
      );
}
