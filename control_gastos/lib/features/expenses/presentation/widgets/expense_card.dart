import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/core/utils/date_formatter.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';

class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(expense.categoryName.isNotEmpty ? expense.categoryName[0] : '?'),
        ),
        title: Text(
          expense.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${expense.categoryName} · ${DateFormatter.formatRelative(expense.date)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyFormatter.format(expense.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.error,
                fontSize: 15,
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: colorScheme.error,
                iconSize: 20,
              ),
          ],
        ),
      ),
    );
  }
}
