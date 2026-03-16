import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/core/utils/date_formatter.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';

class GroupExpenseCard extends StatelessWidget {
  final GroupExpense expense;
  final VoidCallback? onTap;

  const GroupExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Color(expense.categoryColor),
          child: Text(expense.categoryIcon, style: const TextStyle(fontSize: 18)),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${expense.userName} · ${expense.categoryName} · ${DateFormatter.formatRelative(expense.date)}',
        ),
        trailing: Text(
          CurrencyFormatter.format(expense.amount),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.error,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
