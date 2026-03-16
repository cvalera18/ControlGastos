import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense_filter.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_category_bloc.dart';
import 'package:control_gastos/features/groups/presentation/pages/add_group_expense_page.dart';
import 'package:control_gastos/features/groups/presentation/pages/group_categories_page.dart';
import 'package:control_gastos/features/groups/presentation/widgets/group_expense_card.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/presentation/bloc/income_bloc.dart';
import 'package:control_gastos/features/incomes/presentation/pages/add_income_page.dart';
import 'package:control_gastos/features/incomes/presentation/widgets/income_card.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';
import 'package:control_gastos/shared/presentation/widgets/filter_drawer.dart';
import 'package:control_gastos/shared/presentation/widgets/month_navigator.dart';
import 'package:control_gastos/shared/presentation/widgets/total_card.dart';
import 'package:control_gastos/injection_container.dart';

// ─── Merged transaction union ─────────────────────────────────────────────────

sealed class _TxItem {
  DateTime get date;
}

class _ExpenseTx extends _TxItem {
  final GroupExpense expense;
  _ExpenseTx(this.expense);
  @override
  DateTime get date => expense.date;
}

class _IncomeTx extends _TxItem {
  final Income income;
  _IncomeTx(this.income);
  @override
  DateTime get date => income.date;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class GroupDetailPage extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupDetailPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late final String _userId;
  late final String _userName;
  late ExpenseFilter _filter;
  bool _speedDialOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _userName = authState is AuthAuthenticated ? authState.user.name : '';
    _filter = ExpenseFilter.currentMonth();
    _fetchAll();
    _fetchFilterData();
  }

  void _fetchAll() {
    context.read<GroupBloc>().add(FetchGroupExpensesEvent(widget.groupId));
    context.read<IncomeBloc>().add(FetchGroupIncomesEvent(widget.groupId));
  }

  void _fetchFilterData() {
    if (_userId.isEmpty) return;
    context
        .read<GroupCategoryBloc>()
        .add(FetchGroupCategoriesEvent(widget.groupId));
    context
        .read<PaymentMethodBloc>()
        .add(FetchPaymentMethodsEvent(_userId));
  }

  List<GroupExpense> _filterExpenses(List<GroupExpense> expenses) {
    return expenses.where((e) {
      if (e.date.isBefore(_filter.startDate) ||
          e.date.isAfter(_filter.endDate)) { return false; }
      if (_filter.categoryIds.isNotEmpty &&
          !_filter.categoryIds.contains(e.categoryId)) { return false; }
      if (_filter.paymentMethodIds.isNotEmpty &&
          !_filter.paymentMethodIds.contains(e.paymentMethodId)) { return false; }
      return true;
    }).toList();
  }

  List<Income> _filterIncomes(List<Income> incomes) {
    return incomes.where((i) {
      if (i.date.isBefore(_filter.startDate) ||
          i.date.isAfter(_filter.endDate)) { return false; }
      if (_filter.paymentMethodIds.isNotEmpty &&
          !_filter.paymentMethodIds.contains(i.paymentMethodId)) { return false; }
      return true;
    }).toList();
  }

  void _changeMonth(int delta) {
    setState(() {
      final newMonth =
          DateTime(_filter.startDate.year, _filter.startDate.month + delta, 1);
      _filter = _filter.copyWith(
        startDate: newMonth,
        endDate:
            DateTime(newMonth.year, newMonth.month + 1, 0, 23, 59, 59),
      );
    });
  }

  void _clearFilters() {
    setState(() => _filter = ExpenseFilter.currentMonth());
  }

  void _navigateToAddExpense() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<GroupBloc>()),
                BlocProvider.value(value: context.read<GroupCategoryBloc>()),
                BlocProvider.value(value: context.read<PaymentMethodBloc>()),
              ],
              child: AddGroupExpensePage(
                groupId: widget.groupId,
                groupName: widget.groupName,
                userId: _userId,
                userName: _userName,
              ),
            ),
          ),
        )
        .then((_) => _fetchAll());
  }

  void _navigateToAddIncome() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider.value(value: context.read<IncomeBloc>()),
                BlocProvider.value(value: context.read<GroupBloc>()),
                BlocProvider.value(value: context.read<PaymentMethodBloc>()),
              ],
              child: AddIncomePage(preselectedGroupId: widget.groupId),
            ),
          ),
        )
        .then((_) => _fetchAll());
  }

  void _navigateToCategories() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<GroupCategoryBloc>(),
              child: GroupCategoriesPage(
                groupId: widget.groupId,
                userId: _userId,
              ),
            ),
          ),
        )
        .then((_) => _fetchFilterData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.groupName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorías del grupo',
            onPressed: _navigateToCategories,
          ),
          FilterBadgeIcon(
            filter: _filter,
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: BlocBuilder<GroupCategoryBloc, GroupCategoryState>(
        builder: (context, catState) {
          return _GroupFilterDrawer(
            filter: _filter,
            groupCategories:
                catState is GroupCategoryLoaded ? catState.categories : [],
            onFilterChanged: (f) => setState(() => _filter = f),
            onClear: _clearFilters,
          );
        },
      ),
      floatingActionButton: _SpeedDialFab(
        isOpen: _speedDialOpen,
        onToggle: () => setState(() => _speedDialOpen = !_speedDialOpen),
        onExpense: () {
          setState(() => _speedDialOpen = false);
          _navigateToAddExpense();
        },
        onIncome: () {
          setState(() => _speedDialOpen = false);
          _navigateToAddIncome();
        },
      ),
      body: GestureDetector(
        onTap: () {
          if (_speedDialOpen) setState(() => _speedDialOpen = false);
        },
        child: BlocConsumer<GroupBloc, GroupState>(
          listener: (context, state) {
            if (state is GroupOperationSuccess) {
              context.showSnackBar(state.message);
              _fetchAll();
            } else if (state is GroupError) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, groupState) {
            return BlocConsumer<IncomeBloc, IncomeState>(
              listener: (context, state) {
                if (state is IncomeOperationSuccess) {
                  context.showSnackBar(state.message);
                  _fetchAll();
                } else if (state is IncomeError) {
                  context.showSnackBar(state.message, isError: true);
                }
              },
              builder: (context, incomeState) {
                if (groupState is GroupLoading ||
                    incomeState is IncomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allExpenses = groupState is GroupExpensesLoaded
                    ? groupState.expenses
                    : <GroupExpense>[];
                final allIncomes = incomeState is IncomeLoaded
                    ? incomeState.incomes
                    : <Income>[];

                final filteredExpenses = _filterExpenses(allExpenses);
                final filteredIncomes = _filterIncomes(allIncomes);

                final expenseTotal =
                    filteredExpenses.fold(0.0, (s, e) => s + e.amount);
                final incomeTotal =
                    filteredIncomes.fold(0.0, (s, i) => s + i.amount);

                final List<_TxItem> items =
                    switch (_filter.transactionType) {
                  TransactionType.expense =>
                    filteredExpenses.map(_ExpenseTx.new).toList(),
                  TransactionType.income =>
                    filteredIncomes.map(_IncomeTx.new).toList(),
                  TransactionType.all => [
                      ...filteredExpenses.map(_ExpenseTx.new),
                      ...filteredIncomes.map(_IncomeTx.new),
                    ]..sort((a, b) => b.date.compareTo(a.date)),
                };

                return Column(
                  children: [
                    MonthNavigator(
                        filter: _filter, onChangeMonth: _changeMonth),
                    if (_filter.hasExtraFilters)
                      ActiveFilterChips(
                        filter: _filter,
                        onFilterChanged: (f) => setState(() => _filter = f),
                      ),
                    TotalCard(
                      expenseTotal: expenseTotal,
                      incomeTotal: incomeTotal,
                      transactionType: _filter.transactionType,
                    ),
                    if (items.isEmpty)
                      const Expanded(
                        child: EmptyState(
                          icon: Icons.search_off,
                          message: 'Sin transacciones',
                          subtitle: 'No hay registros para este periodo',
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return switch (items[index]) {
                              _ExpenseTx(:final expense) =>
                                GroupExpenseCard(expense: expense),
                              _IncomeTx(:final income) => Dismissible(
                                  key: ValueKey('inc_${income.id}'),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) => showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title:
                                          const Text('Eliminar ingreso'),
                                      content: Text(
                                          '¿Eliminar "${income.description}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancelar'),
                                        ),
                                        ElevatedButton(
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                            foregroundColor:
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onError,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child:
                                              const Text('Eliminar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    context.read<IncomeBloc>().add(
                                        DeleteIncomeEvent(income.id));
                                  },
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding:
                                        const EdgeInsets.only(right: 20),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onError,
                                    ),
                                  ),
                                  child: IncomeCard(income: income),
                                ),
                            };
                          },
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Speed Dial FAB ───────────────────────────────────────────────────────────

class _SpeedDialFab extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onExpense;
  final VoidCallback onIncome;

  const _SpeedDialFab({
    required this.isOpen,
    required this.onToggle,
    required this.onExpense,
    required this.onIncome,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen) ...[
          _DialOption(
            label: 'Ingreso',
            icon: Icons.trending_up,
            color: colorScheme.tertiary,
            onColor: colorScheme.onTertiary,
            onTap: onIncome,
          ),
          const SizedBox(height: 12),
          _DialOption(
            label: 'Gasto',
            icon: Icons.trending_down,
            color: colorScheme.error,
            onColor: colorScheme.onError,
            onTap: onExpense,
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          onPressed: onToggle,
          child: AnimatedRotation(
            turns: isOpen ? 0.125 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _DialOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color onColor;
  final VoidCallback onTap;

  const _DialOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          elevation: 2,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label,
                style: Theme.of(context).textTheme.labelLarge),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: onColor,
          child: Icon(icon),
        ),
      ],
    );
  }
}

// ─── Filter drawer personalizado para grupos (usa GroupCategory) ─────────────

class _GroupFilterDrawer extends StatefulWidget {
  final ExpenseFilter filter;
  final List<dynamic> groupCategories;
  final ValueChanged<ExpenseFilter> onFilterChanged;
  final VoidCallback onClear;

  const _GroupFilterDrawer({
    required this.filter,
    required this.groupCategories,
    required this.onFilterChanged,
    required this.onClear,
  });

  @override
  State<_GroupFilterDrawer> createState() => _GroupFilterDrawerState();
}

class _GroupFilterDrawerState extends State<_GroupFilterDrawer> {
  late ExpenseFilter _localFilter;

  @override
  void initState() {
    super.initState();
    _localFilter = widget.filter;
  }

  @override
  void didUpdateWidget(covariant _GroupFilterDrawer oldWidget) {
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
      initialDateRange: DateTimeRange(
          start: _localFilter.startDate, end: _localFilter.endDate),
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        _localFilter = _localFilter.copyWith(
          startDate: picked.start,
          endDate: DateTime(
              picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
        );
      });
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

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
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Rango de fechas',
                      style: Theme.of(context).textTheme.titleSmall),
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
                      _localFilter = _localFilter.copyWith(
                          transactionType: val.first);
                    }),
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Categorías del grupo',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  if (widget.groupCategories.isEmpty)
                    const Text('Sin categorías',
                        style: TextStyle(color: Colors.grey, fontSize: 13))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.groupCategories.map((cat) {
                        final selected =
                            _localFilter.categoryIds.contains(cat.id);
                        return FilterChip(
                          selected: selected,
                          label: Text('${cat.icon} ${cat.name}',
                              style: const TextStyle(fontSize: 13)),
                          onSelected: (val) {
                            setState(() {
                              final ids = Set<String>.from(
                                  _localFilter.categoryIds);
                              val
                                  ? ids.add(cat.id)
                                  : ids.remove(cat.id);
                              _localFilter =
                                  _localFilter.copyWith(categoryIds: ids);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 24),
                  Text('Métodos de pago',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                    builder: (context, state) {
                      if (state is PaymentMethodLoaded) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.paymentMethods.map((method) {
                            final selected = _localFilter.paymentMethodIds
                                .contains(method.id);
                            return FilterChip(
                              selected: selected,
                              label: Text('${method.icon} ${method.name}',
                                  style: const TextStyle(fontSize: 13)),
                              onSelected: (val) {
                                setState(() {
                                  final ids = Set<String>.from(
                                      _localFilter.paymentMethodIds);
                                  val
                                      ? ids.add(method.id)
                                      : ids.remove(method.id);
                                  _localFilter = _localFilter.copyWith(
                                      paymentMethodIds: ids);
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
