import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/widgets/expense_card.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';
import 'package:control_gastos/shared/presentation/widgets/error_dialog.dart';

class ExpenseListPage extends StatefulWidget {
  const ExpenseListPage({super.key});

  @override
  State<ExpenseListPage> createState() => _ExpenseListPageState();
}

class _ExpenseListPageState extends State<ExpenseListPage> {
  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  void _fetchExpenses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ExpenseBloc>().add(FetchExpensesEvent(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.go('/analytics'),
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Categorías',
            onPressed: () => context.go('/categories'),
          ),
          IconButton(
            icon: const Icon(Icons.credit_card_outlined),
            tooltip: 'Métodos de pago',
            onPressed: () => context.go('/payment-methods'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutEvent()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-expense'),
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
            if (state.expenses.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                message: 'Sin gastos aún',
                subtitle: 'Toca + para agregar tu primer gasto',
              );
            }
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: Theme.of(context).textTheme.titleMedium),
                      Text(
                        CurrencyFormatter.format(state.totalAmount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = state.expenses[index];
                      return ExpenseCard(
                        expense: expense,
                        onDelete: () {
                          context.read<ExpenseBloc>().add(DeleteExpenseEvent(expense.id));
                        },
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
