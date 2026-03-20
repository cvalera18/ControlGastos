import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense_filter.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/widgets/expense_card.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/presentation/bloc/income_bloc.dart';
import 'package:control_gastos/features/incomes/presentation/widgets/income_card.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';
import 'package:control_gastos/shared/presentation/widgets/error_dialog.dart';
import 'package:control_gastos/shared/presentation/widgets/filter_drawer.dart';
import 'package:control_gastos/shared/presentation/widgets/month_navigator.dart';
import 'package:control_gastos/shared/presentation/widgets/total_card.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_state.dart';

// ─── Sealed union for merged transaction list ─────────────────────────────────

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

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  late final String _userName;
  late final String _userEmail;
  late final String _userId;
  late ExpenseFilter _filter;
  bool _speedDialOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userName = authState is AuthAuthenticated ? authState.user.name : '';
    _userEmail = authState is AuthAuthenticated ? authState.user.email : '';
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _filter = ExpenseFilter.currentMonth();
    _fetchAll();
  }

  void _fetchAll() {
    if (_userId.isEmpty) return;
    context.read<ExpenseBloc>().add(FetchExpensesEvent(_userId));
    context.read<IncomeBloc>().add(FetchIncomesEvent(_userId));
    context.read<CategoryBloc>().add(FetchCategoriesEvent(_userId));
    context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(_userId));
    context
        .read<RecurringExpenseBloc>()
        .add(GenerateDueExpensesEvent(_userId));
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    return expenses.where((e) {
      if (e.date.isBefore(_filter.startDate) ||
          e.date.isAfter(_filter.endDate)) return false;
      if (_filter.categoryIds.isNotEmpty &&
          !_filter.categoryIds.contains(e.categoryId)) return false;
      if (_filter.paymentMethodIds.isNotEmpty &&
          !_filter.paymentMethodIds.contains(e.paymentMethodId)) return false;
      return true;
    }).toList();
  }

  List<Income> _filterIncomes(List<Income> incomes) {
    return incomes.where((i) {
      if (i.date.isBefore(_filter.startDate) ||
          i.date.isAfter(_filter.endDate)) return false;
      if (_filter.paymentMethodIds.isNotEmpty &&
          !_filter.paymentMethodIds.contains(i.paymentMethodId)) return false;
      return true;
    }).toList();
  }

  void _changeMonth(int delta) {
    setState(() {
      final newMonth =
          DateTime(_filter.startDate.year, _filter.startDate.month + delta, 1);
      _filter = _filter.copyWith(
        startDate: newMonth,
        endDate: DateTime(newMonth.year, newMonth.month + 1, 0, 23, 59, 59),
      );
    });
  }

  void _clearFilters() {
    setState(() => _filter = ExpenseFilter.currentMonth());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Mis Finanzas'),
        actions: [
          FilterBadgeIcon(
            filter: _filter,
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      drawer: _AppDrawer(userName: _userName, userEmail: _userEmail),
      endDrawer: Builder(
        builder: (context) {
          final expState = context.watch<ExpenseBloc>().state;
          final entries = expState is ExpenseLoaded
              ? expState.expenses
                  .map((e) => (
                        id: e.categoryId,
                        name: e.categoryName,
                        icon: e.categoryIcon,
                        date: e.date,
                      ))
                  .toList()
              : null;
          return FilterDrawer(
            filter: _filter,
            onFilterChanged: (f) => setState(() => _filter = f),
            onClear: _clearFilters,
            expenseEntries: entries,
          );
        },
      ),
      floatingActionButton: _SpeedDialFab(
        isOpen: _speedDialOpen,
        onToggle: () => setState(() => _speedDialOpen = !_speedDialOpen),
        onExpense: () async {
          setState(() => _speedDialOpen = false);
          await context.push('/add-expense');
          _fetchAll();
        },
        onIncome: () async {
          setState(() => _speedDialOpen = false);
          await context.push('/add-income');
          _fetchAll();
        },
      ),
      body: GestureDetector(
        onTap: () {
          if (_speedDialOpen) setState(() => _speedDialOpen = false);
        },
        child: BlocListener<RecurringExpenseBloc, RecurringExpenseState>(
          listener: (context, state) {
            if (state is RecurringExpenseGenerationDone && state.count > 0) {
              context.read<ExpenseBloc>().add(FetchExpensesEvent(_userId));
            }
          },
          child: BlocConsumer<ExpenseBloc, ExpenseState>(
          listener: (context, state) {
            if (state is ExpenseOperationSuccess) {
              _fetchAll();
            } else if (state is ExpenseError) {
              ErrorDialog.show(context,
                  message: state.message, onRetry: _fetchAll);
            }
          },
          builder: (context, expenseState) {
            return BlocConsumer<IncomeBloc, IncomeState>(
              listener: (context, state) {
                if (state is IncomeOperationSuccess) _fetchAll();
              },
              builder: (context, incomeState) {
                if (expenseState is ExpenseLoading ||
                    incomeState is IncomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allExpenses = expenseState is ExpenseLoaded
                    ? expenseState.expenses
                    : <Expense>[];
                final allIncomes = incomeState is IncomeLoaded
                    ? incomeState.incomes
                    : <Income>[];

                final filteredExpenses = _filterExpenses(allExpenses);
                final filteredIncomes = _filterIncomes(allIncomes);


                final expenseTotal =
                    filteredExpenses.fold(0.0, (s, e) => s + e.amount);
                final incomeTotal =
                    filteredIncomes.fold(0.0, (s, i) => s + i.amount);

                final List<_TxItem> items = switch (_filter.transactionType) {
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
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: MediaQuery.of(context).padding.bottom + 88,
                          ),
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
        ),
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
              child: const Text('Cancelar'),
            ),
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
          context
              .read<GroupBloc>()
              .add(DeleteGroupExpenseEvent(expense.id));
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
              child: const Text('Cancelar'),
            ),
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
        context.read<IncomeBloc>().add(DeleteIncomeEvent(income.id));
      },
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
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      );
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
    final appColors = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (isOpen) ...[
          _DialOption(
            label: 'Ingreso',
            icon: Icons.trending_up,
            color: appColors.incomeColor,
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

// ─── App Drawer ───────────────────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _AppDrawer({required this.userName, required this.userEmail});

  void _nav(BuildContext context, String route) {
    Navigator.pop(context);
    GoRouter.of(context).push(route);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.onPrimary,
                  radius: 28,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Mis Finanzas'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Análisis'),
            onTap: () => _nav(context, '/analytics'),
          ),
          const Divider(height: 1),
          ExpansionTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('Organización'),
            initiallyExpanded: false,
            children: [
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('Grupos'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                onTap: () => _nav(context, '/groups'),
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Suscripciones'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                onTap: () => _nav(context, '/recurring-expenses'),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Configuración'),
            initiallyExpanded: false,
            children: [
              ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Categorías'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                onTap: () => _nav(context, '/categories'),
              ),
              ListTile(
                leading: const Icon(Icons.credit_card_outlined),
                title: const Text('Métodos de pago'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                onTap: () => _nav(context, '/payment-methods'),
              ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.credit_score_outlined),
            title: const Text('Tarjetas de Crédito'),
            initiallyExpanded: false,
            children: [
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Ver tarjetas'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                onTap: () => _nav(context, '/credit-cards'),
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Gastos recurrentes'),
                contentPadding: const EdgeInsets.only(left: 32, right: 16),
                onTap: () => _nav(context, '/credit-card-expenses'),
              ),
            ],
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutEvent());
            },
          ),
        ],
      ),
    );
  }
}
