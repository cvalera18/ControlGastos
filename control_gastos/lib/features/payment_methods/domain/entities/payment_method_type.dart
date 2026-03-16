enum PaymentMethodType {
  cash,
  creditCard,
  checkingAccount,
  savingsAccount,
  vistaAccount,
  digitalWallet,
  other;

  String get displayName {
    switch (this) {
      case cash:
        return 'Efectivo';
      case creditCard:
        return 'Tarjeta de crédito';
      case checkingAccount:
        return 'Cuenta corriente';
      case savingsAccount:
        return 'Cuenta ahorro';
      case vistaAccount:
        return 'Cuenta vista';
      case digitalWallet:
        return 'Billetera digital';
      case other:
        return 'Otro';
    }
  }

  String get defaultIcon {
    switch (this) {
      case cash:
        return '💵';
      case creditCard:
        return '💳';
      case checkingAccount:
        return '🏦';
      case savingsAccount:
        return '🐖';
      case vistaAccount:
        return '🏧';
      case digitalWallet:
        return '📱';
      case other:
        return '💰';
    }
  }

  static PaymentMethodType fromString(String? value) {
    return PaymentMethodType.values.firstWhere(
      (t) => t.name == value,
      orElse: () => PaymentMethodType.other,
    );
  }
}
