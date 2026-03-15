import 'package:equatable/equatable.dart';

class CategorySummary extends Equatable {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final double total;
  final int count;
  final double percentage;

  const CategorySummary({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.total,
    required this.count,
    required this.percentage,
  });

  @override
  List<Object> get props => [categoryId, total, count, percentage];
}

class MonthlySummary extends Equatable {
  final DateTime month;
  final double total;
  final int count;
  final List<CategorySummary> byCategory;
  final double average;

  const MonthlySummary({
    required this.month,
    required this.total,
    required this.count,
    required this.byCategory,
    required this.average,
  });

  @override
  List<Object> get props => [month, total, count];
}
