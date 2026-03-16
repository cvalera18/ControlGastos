import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense_filter.dart';

class TotalCard extends StatelessWidget {
  final double expenseTotal;
  final double incomeTotal;
  final TransactionType transactionType;

  const TotalCard({
    super.key,
    required this.expenseTotal,
    this.incomeTotal = 0,
    this.transactionType = TransactionType.all,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (transactionType == TransactionType.expense) {
      return _SimpleCard(
        label: 'Total gastos',
        amount: expenseTotal,
        color: colorScheme.errorContainer,
        textColor: colorScheme.onErrorContainer,
      );
    }

    if (transactionType == TransactionType.income) {
      return _SimpleCard(
        label: 'Total ingresos',
        amount: incomeTotal,
        color: colorScheme.tertiaryContainer,
        textColor: colorScheme.onTertiaryContainer,
      );
    }

    // TransactionType.all → balance con desglose
    final balance = incomeTotal - expenseTotal;
    final isPositive = balance >= 0;

    final bgColor = isPositive ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2);
    final textColor = isPositive ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance del mes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor),
              ),
              Text(
                '${isPositive ? '+' : ''}${CurrencyFormatter.format(balance)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _MiniStat(
                icon: Icons.trending_up,
                label: CurrencyFormatter.format(incomeTotal),
                color: textColor,
              ),
              const SizedBox(width: 16),
              _MiniStat(
                icon: Icons.trending_down,
                label: CurrencyFormatter.format(expenseTotal),
                color: textColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final Color textColor;

  const _SimpleCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: textColor)),
          Text(
            CurrencyFormatter.format(amount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color)),
      ],
    );
  }
}
