import 'package:flutter/material.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';

class TotalCard extends StatelessWidget {
  final double total;
  final bool isFiltered;

  const TotalCard({
    super.key,
    required this.total,
    this.isFiltered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isFiltered ? 'Total filtrado' : 'Total',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            CurrencyFormatter.format(total),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
