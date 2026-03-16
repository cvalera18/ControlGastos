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
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';
import 'package:control_gastos/shared/presentation/widgets/error_dialog.dart';
import 'package:control_gastos/shared/presentation/widgets/filter_drawer.dart';
import 'package:control_gastos/shared/presentation/widgets/month_navigator.dart';
import 'package:control_gastos/shared/presentation/widgets/total_card.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userName = authState is AuthAuthenticated ? authState.user.name : '';
    _userEmail = authState is AuthAuthenticated ? authState.user.email : '';
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _filter = ExpenseFilter.currentMonth();
    _fetchExpenses();
    _fetchFilterData();
  }

  void _fetchExpenses() {
    if (_userId.isNotEmpty) {
      context.read<ExpenseBloc>().add(FetchExpensesEvent(_userId));
    }
  }

  void _fetchFilterData() {
    if (_userId.isEmpty) return;
    context.read<CategoryBloc>().add(FetchCategoriesEvent(_userId));
    context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(_userId));
  }

  List<Expense> _applyFilter(List<Expense> expenses) {
    return expenses.where((e) {
      if (e.date.isBefore(_filter.startDate) || e.date.isAfter(_filter.endDate)) return false;
      if (_filter.categoryIds.isNotEmpty && !_filter.categoryIds.contains(e.categoryId)) return false;
      if (_filter.paymentMethodIds.isNotEmpty && !_filter.paymentMethodIds.contains(e.paymentMethodId)) return false;
      return true;
    }).toList();
  }

  void _changeMonth(int delta) {
    setState(() {
      final newMonth = DateTime(_filter.startDate.year, _filter.startDate.month + delta, 1);
      _filter = _filter.copyWith(
        startDate: newMonth,
        endDate: DateTime(newMonth.year, newMonth.month + 1, 0, 23, 59, 59),
      );
    });
  }

  void _clearFilters() {
    setState(() {
      _filter = ExpenseFilter.currentMonth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        actions: [
          FilterBadgeIcon(
            filter: _filter,
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
        ],
      ),
      drawer: _AppDrawer(userName: _userName, userEmail: _userEmail),
      endDrawer: FilterDrawer(
        filter: _filter,
        onFilterChanged: (f) => setState(() => _filter = f),
        onClear: _clearFilters,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/add-expense');
          _fetchExpenses();
        },
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            _fetchExpenses();
          } else if (state is ExpenseError) {
            ErrorDialog.show(context, message: state.message, onRetry: _fetchExpenses);
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ExpenseLoaded) {
            final filtered = _applyFilter(state.expenses);
            final total = filtered.fold(0.0, (sum, e) => sum + e.amount);

            return Column(
              children: [
                MonthNavigator(filter: _filter, onChangeMonth: _changeMonth),
                if (_filter.hasExtraFilters)
                  ActiveFilterChips(
                    filter: _filter,
                    onFilterChanged: (f) => setState(() => _filter = f),
                  ),
                TotalCard(total: total, isFiltered: _filter.hasExtraFilters),
                if (filtered.isEmpty)
                  const Expanded(
                    child: EmptyState(
                      icon: Icons.search_off,
                      message: 'Sin gastos',
                      subtitle: 'No hay gastos para este periodo',
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final expense = filtered[index];
                        return Dismissible(
                          key: ValueKey(expense.id),
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
                              context.read<GroupBloc>().add(DeleteGroupExpenseEvent(expense.id));
                            }
                          },
                          background: Container(
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
                          ),
                          child: ExpenseCard(
                            expense: expense,
                            onTap: () async {
                              await context.push('/add-expense', extra: expense);
                              _fetchExpenses();
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── App Drawer (navigation) ─────────────────────────────────────────────────

class _AppDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;

  const _AppDrawer({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  radius: 28,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Mis Gastos'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Analisis'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/analytics');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group_outlined),
            title: const Text('Grupos'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/groups');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Categorias'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/categories');
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card_outlined),
            title: const Text('Metodos de pago'),
            onTap: () {
              Navigator.pop(context);
              GoRouter.of(context).push('/payment-methods');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesion'),
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
