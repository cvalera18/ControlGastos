import 'package:flutter/material.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense_filter.dart';

class MonthNavigator extends StatelessWidget {
  final ExpenseFilter filter;
  final ValueChanged<int> onChangeMonth;

  const MonthNavigator({
    super.key,
    required this.filter,
    required this.onChangeMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => onChangeMonth(-1),
          ),
          Text(
            filter.monthLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => onChangeMonth(1),
          ),
        ],
      ),
    );
  }
}
