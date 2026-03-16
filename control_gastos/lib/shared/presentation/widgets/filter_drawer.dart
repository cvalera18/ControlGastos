import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense_filter.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

// ─── Filter Badge Icon ───────────────────────────────────────────────────────

class FilterBadgeIcon extends StatelessWidget {
  final ExpenseFilter filter;
  final VoidCallback onPressed;

  const FilterBadgeIcon({
    super.key,
    required this.filter,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          tooltip: 'Filtros',
          onPressed: onPressed,
        ),
        if (!filter.isDefaultMonthFilter)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '${filter.activeFilterCount}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Active Filter Chips ─────────────────────────────────────────────────────

class ActiveFilterChips extends StatelessWidget {
  final ExpenseFilter filter;
  final ValueChanged<ExpenseFilter> onFilterChanged;

  const ActiveFilterChips({
    super.key,
    required this.filter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          if (filter.categoryIds.isNotEmpty)
            Chip(
              label: Text(
                '${filter.categoryIds.length} categoria${filter.categoryIds.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onFilterChanged(filter.copyWith(categoryIds: {})),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          if (filter.paymentMethodIds.isNotEmpty)
            Chip(
              label: Text(
                '${filter.paymentMethodIds.length} metodo${filter.paymentMethodIds.length > 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onFilterChanged(filter.copyWith(paymentMethodIds: {})),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
        ],
      ),
    );
  }
}

// ─── Filter Drawer ───────────────────────────────────────────────────────────

class FilterDrawer extends StatefulWidget {
  final ExpenseFilter filter;
  final ValueChanged<ExpenseFilter> onFilterChanged;
  final VoidCallback onClear;

  const FilterDrawer({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onClear,
  });

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  late ExpenseFilter _localFilter;

  @override
  void initState() {
    super.initState();
    _localFilter = widget.filter;
  }

  @override
  void didUpdateWidget(covariant FilterDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _localFilter = widget.filter;
  }

  void _apply() {
    widget.onFilterChanged(_localFilter);
    Navigator.pop(context);
  }

  void _clear() {
    widget.onClear();
    Navigator.pop(context);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _localFilter.startDate, end: _localFilter.endDate),
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        _localFilter = _localFilter.copyWith(
          startDate: picked.start,
          endDate: DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
        );
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: colorScheme.surfaceContainerHighest,
              child: Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Rango de fechas', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDateRange,
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      '${_formatDate(_localFilter.startDate)} - ${_formatDate(_localFilter.endDate)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Categorias', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.categories.map((cat) {
                            final selected = _localFilter.categoryIds.contains(cat.id);
                            return FilterChip(
                              selected: selected,
                              label: Text('${cat.icon} ${cat.name}', style: const TextStyle(fontSize: 13)),
                              onSelected: (val) {
                                setState(() {
                                  final ids = Set<String>.from(_localFilter.categoryIds);
                                  val ? ids.add(cat.id) : ids.remove(cat.id);
                                  _localFilter = _localFilter.copyWith(categoryIds: ids);
                                });
                              },
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Metodos de pago', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                    builder: (context, state) {
                      if (state is PaymentMethodLoaded) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.paymentMethods.map((method) {
                            final selected = _localFilter.paymentMethodIds.contains(method.id);
                            return FilterChip(
                              selected: selected,
                              label: Text('${method.icon} ${method.name}', style: const TextStyle(fontSize: 13)),
                              onSelected: (val) {
                                setState(() {
                                  final ids = Set<String>.from(_localFilter.paymentMethodIds);
                                  val ? ids.add(method.id) : ids.remove(method.id);
                                  _localFilter = _localFilter.copyWith(paymentMethodIds: ids);
                                });
                              },
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: const Text('Limpiar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
