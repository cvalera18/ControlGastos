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
          if (filter.transactionType != TransactionType.all)
            Chip(
              label: Text(
                filter.transactionType == TransactionType.expense
                    ? 'Solo gastos'
                    : 'Solo ingresos',
                style: const TextStyle(fontSize: 12),
              ),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => onFilterChanged(
                  filter.copyWith(transactionType: TransactionType.all)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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

typedef CategoryOption = ({String id, String name, String icon});
typedef ExpenseCategoryEntry = ({String id, String name, String icon, DateTime date});

class FilterDrawer extends StatefulWidget {
  final ExpenseFilter filter;
  final ValueChanged<ExpenseFilter> onFilterChanged;
  final VoidCallback onClear;
  /// Cuando se pasa, las categorías se derivan de estas entradas filtrando
  /// por el rango de fechas local (en tiempo real al cambiar la fecha).
  final List<ExpenseCategoryEntry>? expenseEntries;

  const FilterDrawer({
    super.key,
    required this.filter,
    required this.onFilterChanged,
    required this.onClear,
    this.expenseEntries,
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

  Widget _buildCategoryChips(List<CategoryOption> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
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
      final newStart = picked.start;
      final newEnd = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      setState(() {
        // Calcula las categorías válidas en el nuevo rango para limpiar selecciones inválidas
        final validIds = widget.expenseEntries
            ?.where((e) => !e.date.isBefore(newStart) && !e.date.isAfter(newEnd))
            .map((e) => e.id)
            .toSet();
        final cleanedCategoryIds = validIds != null
            ? _localFilter.categoryIds.intersection(validIds)
            : _localFilter.categoryIds;
        _localFilter = _localFilter.copyWith(
          startDate: newStart,
          endDate: newEnd,
          categoryIds: cleanedCategoryIds,
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
                  Text('Tipo de transacción',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SegmentedButton<TransactionType>(
                    segments: const [
                      ButtonSegment(
                        value: TransactionType.all,
                        label: Text('Todos'),
                      ),
                      ButtonSegment(
                        value: TransactionType.expense,
                        label: Text('Gastos'),
                      ),
                      ButtonSegment(
                        value: TransactionType.income,
                        label: Text('Ingresos'),
                      ),
                    ],
                    selected: {_localFilter.transactionType},
                    showSelectedIcon: false,
                    onSelectionChanged: (val) => setState(() {
                      _localFilter =
                          _localFilter.copyWith(transactionType: val.first);
                    }),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Categorias', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (widget.expenseEntries != null)
                    _buildCategoryChips(
                      widget.expenseEntries!
                          .where((e) =>
                              !e.date.isBefore(_localFilter.startDate) &&
                              !e.date.isAfter(_localFilter.endDate))
                          .map((e) => (id: e.id, name: e.name, icon: e.icon))
                          .toSet()
                          .toList(),
                    )
                  else
                    BlocBuilder<CategoryBloc, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoaded) {
                          return _buildCategoryChips(state.categories
                              .map((cat) => (id: cat.id, name: cat.name, icon: cat.icon))
                              .toList());
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
