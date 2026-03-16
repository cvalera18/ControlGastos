import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/core/utils/date_formatter.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';

class IncomeCard extends StatelessWidget {
  final Income income;
  final VoidCallback? onTap;

  const IncomeCard({
    super.key,
    required this.income,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.tertiaryContainer,
          child: Icon(
            Icons.trending_up,
            color: colorScheme.onTertiaryContainer,
            size: 20,
          ),
        ),
        title: Text(
          income.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${income.paymentMethodName} · ${DateFormatter.formatRelative(income.date)}',
        ),
        trailing: Text(
          '+${CurrencyFormatter.format(income.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.tertiary,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
