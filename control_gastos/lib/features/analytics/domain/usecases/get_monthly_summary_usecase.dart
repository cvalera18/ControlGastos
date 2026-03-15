import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/analytics/domain/entities/expense_summary.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';

class GetMonthlySummaryUseCase {
  final ExpenseRepository repository;

  const GetMonthlySummaryUseCase(this.repository);

  Future<Either<Failure, MonthlySummary>> call(MonthlySummaryParams params) async {
    final result = await repository.getExpensesByDateRange(
      userId: params.userId,
      start: DateTime(params.month.year, params.month.month, 1),
      end: DateTime(params.month.year, params.month.month + 1, 0, 23, 59, 59),
    );

    return result.fold(
      (failure) => Left(failure),
      (expenses) {
        final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
        final count = expenses.length;
        final average = count > 0 ? total / count : 0.0;

        final Map<String, CategorySummary> categoryMap = {};
        for (final expense in expenses) {
          final existing = categoryMap[expense.categoryId];
          if (existing != null) {
            categoryMap[expense.categoryId] = CategorySummary(
              categoryId: expense.categoryId,
              categoryName: expense.categoryName,
              categoryIcon: existing.categoryIcon,
              categoryColor: existing.categoryColor,
              total: existing.total + expense.amount,
              count: existing.count + 1,
              percentage: 0,
            );
          } else {
            categoryMap[expense.categoryId] = CategorySummary(
              categoryId: expense.categoryId,
              categoryName: expense.categoryName,
              categoryIcon: '',
              categoryColor: 0xFF2196F3,
              total: expense.amount,
              count: 1,
              percentage: 0,
            );
          }
        }

        final byCategory = categoryMap.values.map((c) {
          return CategorySummary(
            categoryId: c.categoryId,
            categoryName: c.categoryName,
            categoryIcon: c.categoryIcon,
            categoryColor: c.categoryColor,
            total: c.total,
            count: c.count,
            percentage: total > 0 ? (c.total / total) * 100 : 0,
          );
        }).toList()
          ..sort((a, b) => b.total.compareTo(a.total));

        return Right(MonthlySummary(
          month: params.month,
          total: total,
          count: count,
          byCategory: byCategory,
          average: average,
        ));
      },
    );
  }
}

class MonthlySummaryParams extends Equatable {
  final String userId;
  final DateTime month;

  const MonthlySummaryParams({required this.userId, required this.month});

  @override
  List<Object> get props => [userId, month];
}
