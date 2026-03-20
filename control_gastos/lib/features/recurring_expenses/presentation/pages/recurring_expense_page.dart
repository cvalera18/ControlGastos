import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_state.dart';

class RecurringExpensePage extends StatefulWidget {
  const RecurringExpensePage({super.key});

  @override
  State<RecurringExpensePage> createState() => _RecurringExpensePageState();
}

class _RecurringExpensePageState extends State<RecurringExpensePage> {
  late final String _userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _fetch();
  }

  void _fetch() {
    if (_userId.isEmpty) return;
    context.read<RecurringExpenseBloc>().add(FetchRecurringExpensesEvent(_userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suscripciones y recurrentes'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/add-recurring-expense');
          if (context.mounted) _fetch();
        },
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<RecurringExpenseBloc, RecurringExpenseState>(
        listener: (context, state) {
          if (state is RecurringExpenseOperationSuccess) {
            context.showSnackBar(state.message);
            _fetch();
          } else if (state is RecurringExpenseError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is RecurringExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RecurringExpenseLoaded) {
            if (state.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat,
                        size: 56,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3)),
                    const SizedBox(height: 12),
                    Text(
                      'Sin suscripciones registradas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  12, 8, 12, 80 + MediaQuery.of(context).padding.bottom),
              itemCount: state.expenses.length,
              itemBuilder: (context, index) {
                final expense = state.expenses[index];
                return _RecurringCard(
                  key: ValueKey(expense.id),
                  expense: expense,
                  onEdit: () async {
                    await context.push('/add-recurring-expense', extra: expense);
                    if (context.mounted) _fetch();
                  },
                  onDelete: () => context
                      .read<RecurringExpenseBloc>()
                      .add(DeleteRecurringExpenseEvent(expense.id)),
                  onToggleActive: () {
                    context.read<RecurringExpenseBloc>().add(
                          UpdateRecurringExpenseEvent(
                            expense.copyWith(isActive: !expense.isActive),
                          ),
                        );
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _RecurringCard extends StatelessWidget {
  final RecurringExpense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _RecurringCard({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar suscripción'),
        content: Text(
            '¿Eliminar "${expense.name}"? Los gastos ya generados no se verán afectados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final nextDue = expense.nextDueDate;
    final daysUntil =
        nextDue.difference(DateTime(today.year, today.month, today.day)).inDays;

    final isOverdue = daysUntil < 0;
    final isUrgent = daysUntil <= 3;
    final catColor = Color(expense.categoryColor);

    final dueBadgeColor = isOverdue
        ? colorScheme.error
        : isUrgent
            ? colorScheme.errorContainer
            : colorScheme.surfaceContainerHighest;
    final dueBadgeTextColor = isOverdue
        ? colorScheme.onError
        : isUrgent
            ? colorScheme.onErrorContainer
            : colorScheme.onSurfaceVariant;
    final dueLabel = isOverdue
        ? 'Vencido'
        : daysUntil == 0
            ? 'Vence hoy'
            : daysUntil == 1
                ? 'Mañana'
                : 'En $daysUntil días';

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Icon(Icons.delete_outline, color: colorScheme.onErrorContainer),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Icono categoría ──────────────────────────────────────────
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(expense.categoryIcon,
                      style: const TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),

                // ── Contenido ────────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              expense.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: expense.isActive
                                    ? null
                                    : colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(expense.amount),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: context.appColors.expenseColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          expense.frequency.displayName,
                          expense.paymentMethodName,
                          if (expense.groupId != null) expense.categoryName,
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (expense.isActive) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: dueBadgeColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${nextDue.day}/${nextDue.month}/${nextDue.year} · $dueLabel',
                                style: TextStyle(
                                    fontSize: 11, color: dueBadgeTextColor),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Pausado',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Toggle pausa ─────────────────────────────────────────────
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    expense.isActive
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline,
                    color: expense.isActive
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  visualDensity: VisualDensity.compact,
                  onPressed: onToggleActive,
                  tooltip: expense.isActive ? 'Pausar' : 'Reanudar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
