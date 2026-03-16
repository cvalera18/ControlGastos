class AppConstants {
  AppConstants._();

  // Collections Firestore
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String categoriesCollection = 'categories';
  static const String paymentMethodsCollection = 'payment_methods';
  static const String groupsCollection = 'groups';
  static const String groupExpensesCollection = 'group_expenses';

  // SharedPreferences keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Isar DB
  static const String isarDbName = 'control_gastos_db';

  // Default personal categories (3 básicas)
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Comida', 'icon': '🍔', 'color': 0xFFE53935},
    {'name': 'Transporte', 'icon': '🚗', 'color': 0xFF1E88E5},
    {'name': 'Entretenimiento', 'icon': '🎬', 'color': 0xFF8E24AA},
  ];

  // Default group categories (mismas 3)
  static const List<Map<String, dynamic>> defaultGroupCategories = [
    {'name': 'Comida', 'icon': '🍔', 'color': 0xFFE53935},
    {'name': 'Transporte', 'icon': '🚗', 'color': 0xFF1E88E5},
    {'name': 'Entretenimiento', 'icon': '🎬', 'color': 0xFF8E24AA},
  ];

  // Default payment methods
  static const List<Map<String, dynamic>> defaultPaymentMethods = [
    {'name': 'Efectivo', 'icon': '💵', 'type': 'cash'},
    {'name': 'Tarjeta de crédito', 'icon': '💳', 'type': 'creditCard'},
    {'name': 'Cuenta corriente', 'icon': '🏦', 'type': 'checkingAccount'},
    {'name': 'Cuenta ahorro', 'icon': '🐖', 'type': 'savingsAccount'},
    {'name': 'Cuenta vista', 'icon': '🏧', 'type': 'vistaAccount'},
    {'name': 'Billetera digital', 'icon': '📱', 'type': 'digitalWallet'},
  ];
}
