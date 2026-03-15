class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'El email es requerido';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) return 'Email inválido';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName es requerido';
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.isEmpty) return 'El monto es requerido';
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) return 'Monto inválido';
    if (amount <= 0) return 'El monto debe ser mayor a 0';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'El nombre es requerido';
    if (value.trim().length < 2) return 'Mínimo 2 caracteres';
    return null;
  }
}
