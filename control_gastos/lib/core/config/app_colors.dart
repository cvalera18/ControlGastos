import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color incomeColor;
  final Color expenseColor;

  const AppColors({
    required this.incomeColor,
    required this.expenseColor,
  });

  static const light = AppColors(
    incomeColor: Color(0xFF43A047),
    expenseColor: Color(0xFFE53935),
  );

  static const dark = AppColors(
    incomeColor: Color(0xFF66BB6A),
    expenseColor: Color(0xFFEF5350),
  );

  @override
  AppColors copyWith({Color? incomeColor, Color? expenseColor}) {
    return AppColors(
      incomeColor: incomeColor ?? this.incomeColor,
      expenseColor: expenseColor ?? this.expenseColor,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      incomeColor: Color.lerp(incomeColor, other.incomeColor, t)!,
      expenseColor: Color.lerp(expenseColor, other.expenseColor, t)!,
    );
  }
}
