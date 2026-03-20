import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_state.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';

class CreditCardRecurringExpensesPage extends StatefulWidget {
  final PaymentMethod? initialCard;

  const CreditCardRecurringExpensesPage({super.key, this.initialCard});

  @override
  State<CreditCardRecurringExpensesPage> createState() =>
      _CreditCardRecurringExpensesPageState();
}

class _CreditCardRecurringExpensesPageState
    extends State<CreditCardRecurringExpensesPage> {
  late final String _userId;
  PaymentMethod? _selectedCard;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _selectedCard = widget.initialCard;

    context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(_userId));

    if (_selectedCard != null) {
      _fetchForCard(_selectedCard!);
    }
  }

  void _fetchForCard(PaymentMethod card) {
    context.read<RecurringExpenseBloc>().add(
          FetchRecurringExpensesByMethodEvent(_userId, card.id),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos de tarjeta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      floatingActionButton: _selectedCard == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                await context.push(
                  '/add-recurring-expense',
                  extra: {'prefillPaymentMethod': _selectedCard},
                );
                if (context.mounted && _selectedCard != null) {
                  _fetchForCard(_selectedCard!);
                }
              },
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          // ── Selector de tarjeta ──────────────────────────────────────────
          BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
            builder: (context, state) {
              if (state is! PaymentMethodLoaded) {
                return const SizedBox(
                  height: 56,
                  child: Center(child: LinearProgressIndicator()),
                );
              }
              final cards = state.paymentMethods
                  .where((m) => m.type == PaymentMethodType.creditCard)
                  .toList();

              if (cards.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No tienes tarjetas de crédito registradas',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                );
              }

              return SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: cards.map((card) {
                    final isSelected = _selectedCard?.id == card.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Text(card.icon),
                        label: Text(card.name),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _selectedCard = card);
                          _fetchForCard(card);
                        },
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // ── Lista de gastos recurrentes ──────────────────────────────────
          Expanded(
            child: _selectedCard == null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.credit_card_outlined,
                          size: 56,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Selecciona una tarjeta',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                        ),
                      ],
                    ),
                  )
                : BlocConsumer<RecurringExpenseBloc, RecurringExpenseState>(
                    listener: (context, state) {
                      if (state is RecurringExpenseOperationSuccess) {
                        context.showSnackBar(state.message);
                        if (_selectedCard != null) _fetchForCard(_selectedCard!);
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
                                Icon(
                                  Icons.repeat,
                                  size: 56,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Sin gastos operacionales',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
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
                            return _CardExpenseCard(
                              key: ValueKey(expense.id),
                              expense: expense,
                              onEdit: () async {
                                await context.push(
                                  '/add-recurring-expense',
                                  extra: {
                                    'prefillPaymentMethod': _selectedCard,
                                    'existing': expense,
                                  },
                                );
                                if (context.mounted && _selectedCard != null) {
                                  _fetchForCard(_selectedCard!);
                                }
                              },
                              onDelete: () => context
                                  .read<RecurringExpenseBloc>()
                                  .add(DeleteRecurringExpenseEvent(expense.id)),
                              onToggleActive: () => context
                                  .read<RecurringExpenseBloc>()
                                  .add(UpdateRecurringExpenseEvent(
                                    expense.copyWith(isActive: !expense.isActive),
                                  )),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Card expense card ────────────────────────────────────────────────────────

class _CardExpenseCard extends StatelessWidget {
  final RecurringExpense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _CardExpenseCard({
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
        title: const Text('Eliminar gasto operacional'),
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
                        expense.frequency.displayName,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (expense.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: dueBadgeColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${nextDue.day}/${nextDue.month}/${nextDue.year} · $dueLabel',
                            style:
                                TextStyle(fontSize: 11, color: dueBadgeTextColor),
                          ),
                        )
                      else
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
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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
