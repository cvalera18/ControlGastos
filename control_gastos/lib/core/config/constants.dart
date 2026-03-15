class AppConstants {
  AppConstants._();

  // Collections Firestore
  static const String usersCollection = 'users';
  static const String expensesCollection = 'expenses';
  static const String categoriesCollection = 'categories';
  static const String paymentMethodsCollection = 'payment_methods';

  // SharedPreferences keys
  static const String keyUserId = 'user_id';
  static const String keyUserEmail = 'user_email';
  static const String keyUserName = 'user_name';
  static const String keyIsLoggedIn = 'is_logged_in';

  // Isar DB
  static const String isarDbName = 'control_gastos_db';

  // Default categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'Alimentación', 'icon': '🍔', 'color': 0xFFE53935},
    {'name': 'Transporte', 'icon': '🚗', 'color': 0xFF1E88E5},
    {'name': 'Entretenimiento', 'icon': '🎬', 'color': 0xFF8E24AA},
    {'name': 'Salud', 'icon': '🏥', 'color': 0xFF43A047},
    {'name': 'Hogar', 'icon': '🏠', 'color': 0xFFFF8F00},
    {'name': 'Ropa', 'icon': '👕', 'color': 0xFF00ACC1},
    {'name': 'Educación', 'icon': '📚', 'color': 0xFF3949AB},
    {'name': 'Otros', 'icon': '📦', 'color': 0xFF757575},
  ];

  // Default payment methods
  static const List<Map<String, dynamic>> defaultPaymentMethods = [
    {'name': 'Efectivo', 'icon': '💵'},
    {'name': 'Tarjeta de crédito', 'icon': '💳'},
    {'name': 'Tarjeta de débito', 'icon': '💳'},
    {'name': 'Transferencia', 'icon': '🏦'},
  ];
}
