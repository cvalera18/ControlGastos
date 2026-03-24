import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense_filter.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/widgets/expense_card.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/presentation/bloc/income_bloc.dart';
import 'package:control_gastos/features/incomes/presentation/widgets/income_card.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';
import 'package:control_gastos/shared/presentation/widgets/filter_drawer.dart';
import 'package:control_gastos/shared/presentation/widgets/month_navigator.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';

// ─── Sealed union ─────────────────────────────────────────────────────────────

sealed class _TxItem {
  DateTime get date;
}

class _ExpenseTx extends _TxItem {
  final Expense expense;
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

class PaymentMethodDetailPage extends StatefulWidget {
  final PaymentMethod method;

  const PaymentMethodDetailPage({required this.method, super.key});

  @override
  State<PaymentMethodDetailPage> createState() => _PaymentMethodDetailPageState();
}

class _PaymentMethodDetailPageState extends State<PaymentMethodDetailPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String _userId;
  late ExpenseFilter _filter;
  List<ExpenseCategoryEntry> _expenseEntries = [];
  bool _speedDialOpen = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _filter = ExpenseFilter.currentMonth();
    _fetchAll();
  }

  void _fetchAll() {
    if (_userId.isEmpty) return;
    context.read<ExpenseBloc>().add(FetchExpensesEvent(_userId));
    context.read<IncomeBloc>().add(FetchIncomesEvent(_userId));
  }

  void _changeMonth(int delta) {
    setState(() {
      final newMonth =
          DateTime(_filter.startDate.year, _filter.startDate.month + delta, 1);
      _filter = _filter.copyWith(
        startDate: newMonth,
        endDate: DateTime(newMonth.year, newMonth.month + 1, 0, 23, 59, 59),
        categoryIds: {},
      );
    });
  }

  bool _inPeriod(DateTime date) =>
      !date.isBefore(_filter.startDate) && !date.isAfter(_filter.endDate);

  bool _afterStart(DateTime date) =>
      widget.method.balanceStartDate == null ||
      !date.isBefore(widget.method.balanceStartDate!);

  void _applyDrawerFilter(ExpenseFilter f) {
    setState(() => _filter = _filter.copyWith(
          transactionType: f.transactionType,
          categoryIds: f.categoryIds,
          startDate: f.startDate,
          endDate: f.endDate,
        ));
  }

  void _clearDrawerFilter() {
    final defaultMonth = ExpenseFilter.currentMonth();
    setState(() => _filter = _filter.copyWith(
          transactionType: TransactionType.all,
          categoryIds: {},
          startDate: defaultMonth.startDate,
          endDate: defaultMonth.endDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final method = widget.method;
    final showBalance = method.type.hasBalance && method.initialBalance != null;
    final showCreditLimit =
        method.type == PaymentMethodType.creditCard && method.creditLimit != null;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(method.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                method.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (method.type == PaymentMethodType.creditCard)
            IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: 'Gastos operacionales',
              onPressed: () => GoRouter.of(context)
                  .push('/credit-card-expenses', extra: method),
            ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: _filter.hasExtraFilters
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: 'Filtros',
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      floatingActionButton: _DetailSpeedDial(
        isOpen: _speedDialOpen,
        onToggle: () => setState(() => _speedDialOpen = !_speedDialOpen),
        onExpense: () async {
          setState(() => _speedDialOpen = false);
          await context.push('/add-expense', extra: widget.method.id);
          _fetchAll();
        },
        onIncome: () async {
          setState(() => _speedDialOpen = false);
          await context.push('/add-income', extra: widget.method.id);
          _fetchAll();
        },
      ),
      endDrawer: FilterDrawer(
        filter: _filter,
        expenseEntries: _expenseEntries,
        showPaymentMethodFilter: false,
        onFilterChanged: _applyDrawerFilter,
        onClear: _clearDrawerFilter,
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, expenseState) {
          if (expenseState is ExpenseOperationSuccess) _fetchAll();
          if (expenseState is ExpenseLoaded) {
            setState(() {
              _expenseEntries = expenseState.expenses
                  .where((e) => e.paymentMethodId == method.id)
                  .map((e) => (
                        id: e.categoryId,
                        name: e.categoryName,
                        icon: e.categoryIcon,
                        date: e.date,
                      ))
                  .toList();
            });
          }
        },
        builder: (context, expenseState) {
          return BlocConsumer<IncomeBloc, IncomeState>(
            listener: (context, state) {
              if (state is IncomeOperationSuccess) _fetchAll();
            },
            builder: (context, incomeState) {
              if (expenseState is ExpenseLoading || incomeState is IncomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // Todas las transacciones de este método
              final allExpenses = expenseState is ExpenseLoaded
                  ? expenseState.expenses
                      .where((e) => e.paymentMethodId == method.id)
                      .toList()
                  : <Expense>[];
              final allIncomes = incomeState is IncomeLoaded
                  ? incomeState.incomes
                      .where((i) => i.paymentMethodId == method.id)
                      .toList()
                  : <Income>[];

              // Saldo actual: initialBalance + incomes - expenses (desde balanceStartDate)
              double? currentBalance;
              if (showBalance) {
                final spent = allExpenses
                    .where((e) => _afterStart(e.date))
                    .fold(0.0, (s, e) => s + e.amount);
                final earned = allIncomes
                    .where((i) => _afterStart(i.date))
                    .fold(0.0, (s, i) => s + i.amount);
                currentBalance = method.initialBalance! + earned - spent;
              }

              // Cupo disponible: creditLimit - gastos + pagos (desde balanceStartDate)
              double? availableCredit;
              if (showCreditLimit) {
                final totalSpent = allExpenses
                    .where((e) => _afterStart(e.date))
                    .fold(0.0, (s, e) => s + e.amount);
                final totalPaid = allIncomes
                    .where((i) => _afterStart(i.date))
                    .fold(0.0, (s, i) => s + i.amount);
                availableCredit = method.creditLimit! - totalSpent + totalPaid;
              }

              // Totales por ciclo de facturación (solo TDC con fecha de corte)
              double? currentCycleTotal;
              double? prevCycleTotal;
              if (method.cutOffDay != null) {
                final now = DateTime.now();
                final DateTime lastCut;
                final DateTime prevCut;
                if (now.day < method.cutOffDay!) {
                  lastCut = DateTime(now.year, now.month - 1, method.cutOffDay!);
                } else {
                  lastCut = DateTime(now.year, now.month, method.cutOffDay!);
                }
                prevCut = DateTime(lastCut.year, lastCut.month - 1, method.cutOffDay!);
                currentCycleTotal = allExpenses
                    .where((e) => !e.date.isBefore(lastCut))
                    .fold<double>(0.0, (s, e) => s + e.amount);
                prevCycleTotal = allExpenses
                    .where((e) => !e.date.isBefore(prevCut) && e.date.isBefore(lastCut))
                    .fold<double>(0.0, (s, e) => s + e.amount);
              }

              // Filtrar por período
              var periodExpenses = allExpenses.where((e) => _inPeriod(e.date)).toList();
              final periodIncomes = allIncomes.where((i) => _inPeriod(i.date)).toList();

              // Filtrar por categoría
              if (_filter.categoryIds.isNotEmpty) {
                periodExpenses = periodExpenses
                    .where((e) => _filter.categoryIds.contains(e.categoryId))
                    .toList();
              }

              // Totales del período
              final expenseTotal = periodExpenses.fold(0.0, (s, e) => s + e.amount);
              final incomeTotal = periodIncomes.fold(0.0, (s, i) => s + i.amount);

              // Lista según tipo seleccionado
              final txType = _filter.transactionType;
              final List<_TxItem> items = switch (txType) {
                TransactionType.expense =>
                  periodExpenses.map(_ExpenseTx.new).toList(),
                TransactionType.income =>
                  periodIncomes.map(_IncomeTx.new).toList(),
                TransactionType.all => [
                    ...periodExpenses.map(_ExpenseTx.new),
                    ...periodIncomes.map(_IncomeTx.new),
                  ]..sort((a, b) => b.date.compareTo(a.date)),
              };

              return Column(
                children: [
                  // Header de saldo actual / cupo (incluye resumen del período)
                  if (showBalance && currentBalance != null)
                    _CurrentBalanceCard(
                      currentBalance: currentBalance,
                      expenseTotal: expenseTotal,
                      incomeTotal: incomeTotal,
                      txType: txType,
                    ),
                  if (showCreditLimit && availableCredit != null)
                    _CreditLimitCard(
                      creditLimit: method.creditLimit!,
                      availableCredit: availableCredit,
                      expenseTotal: expenseTotal,
                      incomeTotal: incomeTotal,
                      txType: txType,
                    ),
                  if (method.cutOffDay != null)
                    _CycleIndicatorBar(cutOffDay: method.cutOffDay!),
                  if (method.cutOffDay != null && currentCycleTotal != null)
                    _CycleSummaryCard(
                      cutOffDay: method.cutOffDay!,
                      currentCycleTotal: currentCycleTotal,
                      prevCycleTotal: prevCycleTotal,
                    ),

                  MonthNavigator(filter: _filter, onChangeMonth: _changeMonth),

                  // Chips de filtros activos (categorías / tipo de transacción)
                  if (_filter.hasExtraFilters)
                    ActiveFilterChips(
                      filter: _filter,
                      onFilterChanged: (f) => setState(() => _filter = _filter.copyWith(
                            transactionType: f.transactionType,
                            categoryIds: f.categoryIds,
                          )),
                    ),

                  // Resumen del período solo cuando no hay card de encabezado
                  if (!showBalance && !showCreditLimit)
                    _PeriodSummaryRow(
                      expenseTotal: expenseTotal,
                      incomeTotal: incomeTotal,
                      txType: txType,
                    ),

                  // Lista de transacciones
                  if (items.isEmpty)
                    const Expanded(
                      child: EmptyState(
                        icon: Icons.search_off,
                        message: 'Sin transacciones',
                        subtitle: 'No hay registros para este período',
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return switch (item) {
                            _ExpenseTx(:final expense) =>
                              _buildExpenseDismissible(context, expense),
                            _IncomeTx(:final income) =>
                              _buildIncomeDismissible(context, income),
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
    );
  }

  Widget _buildExpenseDismissible(BuildContext context, Expense expense) {
    return Dismissible(
      key: ValueKey('exp_${expense.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar gasto'),
          content: Text('¿Eliminar "${expense.description}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
        if (expense.groupId != null) {
          context.read<GroupBloc>().add(DeleteGroupExpenseEvent(expense.id));
        }
      },
      background: _deleteBackground(context),
      child: ExpenseCard(
        expense: expense,
        onTap: () async {
          await context.push('/add-expense', extra: expense);
          _fetchAll();
        },
      ),
    );
  }

  Widget _buildIncomeDismissible(BuildContext context, Income income) {
    return Dismissible(
      key: ValueKey('inc_${income.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar ingreso'),
          content: Text('¿Eliminar "${income.description}"?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      ),
      onDismissed: (_) =>
          context.read<IncomeBloc>().add(DeleteIncomeEvent(income.id)),
      background: _deleteBackground(context),
      child: IncomeCard(
        income: income,
        onTap: () async {
          await context.push('/add-income', extra: income);
          _fetchAll();
        },
      ),
    );
  }

  Widget _deleteBackground(BuildContext context) => Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline,
            color: Theme.of(context).colorScheme.onError),
      );
}

// ─── Period summary row ───────────────────────────────────────────────────────

class _PeriodSummaryRow extends StatelessWidget {
  final double expenseTotal;
  final double incomeTotal;
  final TransactionType txType;

  const _PeriodSummaryRow({
    required this.expenseTotal,
    required this.incomeTotal,
    required this.txType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          if (txType != TransactionType.income) ...[
            Icon(Icons.trending_down, size: 13, color: colorScheme.error),
            const SizedBox(width: 3),
            Text(
              CurrencyFormatter.format(expenseTotal),
              style: textStyle?.copyWith(color: colorScheme.error),
            ),
          ],
          if (txType == TransactionType.all) const SizedBox(width: 14),
          if (txType != TransactionType.expense) ...[
            Icon(Icons.trending_up, size: 13, color: colorScheme.tertiary),
            const SizedBox(width: 3),
            Text(
              CurrencyFormatter.format(incomeTotal),
              style: textStyle?.copyWith(color: colorScheme.tertiary),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Balance card ──────────────────────────────────────────────────────────────

class _CurrentBalanceCard extends StatelessWidget {
  final double currentBalance;
  final double expenseTotal;
  final double incomeTotal;
  final TransactionType txType;

  const _CurrentBalanceCard({
    required this.currentBalance,
    required this.expenseTotal,
    required this.incomeTotal,
    required this.txType,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = currentBalance < 0;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isNegative ? colorScheme.errorContainer : colorScheme.primaryContainer;
    final textColor =
        isNegative ? colorScheme.onErrorContainer : colorScheme.onPrimaryContainer;
    final appColors = context.appColors;
    final expenseColor = appColors.expenseColor;
    final incomeColor = appColors.incomeColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo actual',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: textColor.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(currentBalance),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (txType != TransactionType.income) ...[
                Icon(Icons.trending_down, size: 13, color: expenseColor),
                const SizedBox(width: 3),
                Text(
                  CurrencyFormatter.format(expenseTotal),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: expenseColor),
                ),
              ],
              if (txType == TransactionType.all) const SizedBox(width: 14),
              if (txType != TransactionType.expense) ...[
                Icon(Icons.trending_up, size: 13, color: incomeColor),
                const SizedBox(width: 3),
                Text(
                  CurrencyFormatter.format(incomeTotal),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: incomeColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Credit limit card ────────────────────────────────────────────────────────

class _CreditLimitCard extends StatelessWidget {
  final double creditLimit;
  final double availableCredit;
  final double expenseTotal;
  final double incomeTotal;
  final TransactionType txType;

  const _CreditLimitCard({
    required this.creditLimit,
    required this.availableCredit,
    required this.expenseTotal,
    required this.incomeTotal,
    required this.txType,
  });

  @override
  Widget build(BuildContext context) {
    final isExceeded = availableCredit < 0;
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor =
        isExceeded ? colorScheme.errorContainer : colorScheme.secondaryContainer;
    final textColor =
        isExceeded ? colorScheme.onErrorContainer : colorScheme.onSecondaryContainer;
    final appColors = context.appColors;
    final expenseColor = appColors.expenseColor;
    final incomeColor = appColors.incomeColor;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cupo disponible',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(color: textColor.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(availableCredit),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Cupo total: ${CurrencyFormatter.format(creditLimit)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: textColor.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (txType != TransactionType.income) ...[
                Icon(Icons.trending_down, size: 13, color: expenseColor),
                const SizedBox(width: 3),
                Text(
                  CurrencyFormatter.format(expenseTotal),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: expenseColor),
                ),
              ],
              if (txType == TransactionType.all) const SizedBox(width: 14),
              if (txType != TransactionType.expense) ...[
                Icon(Icons.trending_up, size: 13, color: incomeColor),
                const SizedBox(width: 3),
                Text(
                  CurrencyFormatter.format(incomeTotal),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: incomeColor),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Speed dial FAB ───────────────────────────────────────────────────────────

class _DetailSpeedDial extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onToggle;
  final Future<void> Function() onExpense;
  final Future<void> Function() onIncome;

  const _DetailSpeedDial({
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
            color: context.appColors.incomeColor,
            onColor: Colors.white,
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

// ─── Dial option ──────────────────────────────────────────────────────────────

class _DialOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color onColor;
  final Future<void> Function() onTap;

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
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

// ─── Cycle summary card ───────────────────────────────────────────────────────

class _CycleSummaryCard extends StatelessWidget {
  final int cutOffDay;
  final double currentCycleTotal;
  final double? prevCycleTotal;

  const _CycleSummaryCard({
    required this.cutOffDay,
    required this.currentCycleTotal,
    this.prevCycleTotal,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final DateTime lastCut;
    final DateTime nextCut;
    if (now.day < cutOffDay) {
      lastCut = DateTime(now.year, now.month - 1, cutOffDay);
      nextCut = DateTime(now.year, now.month, cutOffDay);
    } else {
      lastCut = DateTime(now.year, now.month, cutOffDay);
      nextCut = DateTime(now.year, now.month + 1, cutOffDay);
    }
    final daysLeft = nextCut.difference(DateTime(now.year, now.month, now.day)).inDays;
    final isUrgent = daysLeft <= 5;
    final colorScheme = Theme.of(context).colorScheme;

    double? diffPct;
    if (prevCycleTotal != null && prevCycleTotal! > 0) {
      diffPct = ((currentCycleTotal - prevCycleTotal!) / prevCycleTotal!) * 100;
    }

    final onBg = isUrgent ? colorScheme.onErrorContainer : colorScheme.onSurface;
    final onBgMuted = onBg.withValues(alpha: 0.6);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent ? colorScheme.errorContainer : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alerta urgente
          if (isUrgent) ...[
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 15, color: colorScheme.error),
                const SizedBox(width: 6),
                Text(
                  daysLeft == 0
                      ? '¡Corta hoy!'
                      : daysLeft == 1
                          ? 'Corta mañana'
                          : 'Corta en $daysLeft días',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
          ],

          // Totales ciclo actual vs anterior
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ciclo actual',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: onBgMuted)),
                    Text(
                      CurrencyFormatter.format(currentCycleTotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: onBg,
                          ),
                    ),
                    Text(
                      'Desde ${lastCut.day}/${lastCut.month}',
                      style: TextStyle(fontSize: 11, color: onBgMuted),
                    ),
                  ],
                ),
              ),
              if (prevCycleTotal != null) ...[
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Ciclo anterior',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: onBgMuted)),
                    Text(
                      CurrencyFormatter.format(prevCycleTotal!),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: onBgMuted),
                    ),
                    if (diffPct != null)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: diffPct > 0
                              ? colorScheme.error.withValues(alpha: 0.15)
                              : colorScheme.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${diffPct > 0 ? '+' : ''}${diffPct.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: diffPct > 0
                                ? colorScheme.error
                                : colorScheme.tertiary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Cycle indicator bar ──────────────────────────────────────────────────────

class _CycleIndicatorBar extends StatelessWidget {
  final int cutOffDay;

  const _CycleIndicatorBar({required this.cutOffDay});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Fecha del último corte y del próximo
    final DateTime lastCut;
    final DateTime nextCut;
    if (now.day < cutOffDay) {
      nextCut = DateTime(now.year, now.month, cutOffDay);
      lastCut = DateTime(now.year, now.month - 1, cutOffDay);
    } else {
      lastCut = DateTime(now.year, now.month, cutOffDay);
      nextCut = DateTime(now.year, now.month + 1, cutOffDay);
    }

    final totalDays = nextCut.difference(lastCut).inDays;
    final elapsed = today.difference(lastCut).inDays;
    final daysLeft = nextCut.difference(today).inDays;
    final progress = (elapsed / totalDays).clamp(0.0, 1.0);

    final colorScheme = Theme.of(context).colorScheme;
    final isUrgent = daysLeft <= 3;
    final barColor = isUrgent ? colorScheme.error : colorScheme.primary;

    final cutLabel = daysLeft == 0
        ? 'Corta hoy'
        : daysLeft == 1
            ? 'Corta mañana'
            : 'Corta en $daysLeft días (día $cutOffDay)';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ciclo: $elapsed/$totalDays días',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                cutLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isUrgent ? barColor : colorScheme.onSurfaceVariant,
                      fontWeight: isUrgent ? FontWeight.w600 : null,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
