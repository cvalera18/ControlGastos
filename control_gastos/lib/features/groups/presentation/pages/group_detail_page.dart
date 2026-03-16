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
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/shared/presentation/widgets/empty_state.dart';
import 'package:control_gastos/shared/presentation/widgets/filter_drawer.dart';
import 'package:control_gastos/shared/presentation/widgets/month_navigator.dart';
import 'package:control_gastos/shared/presentation/widgets/total_card.dart';
import 'package:control_gastos/injection_container.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _userName = authState is AuthAuthenticated ? authState.user.name : '';
    _filter = ExpenseFilter.currentMonth();
    _fetch();
    _fetchFilterData();
  }

  void _fetch() {
    context.read<GroupBloc>().add(FetchGroupExpensesEvent(widget.groupId));
  }

  void _fetchFilterData() {
    if (_userId.isEmpty) return;
    context.read<GroupCategoryBloc>().add(FetchGroupCategoriesEvent(widget.groupId));
    context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(_userId));
  }

  List<GroupExpense> _applyFilter(List<GroupExpense> expenses) {
    return expenses.where((e) {
      if (e.date.isBefore(_filter.startDate) || e.date.isAfter(_filter.endDate)) return false;
      if (_filter.categoryIds.isNotEmpty && !_filter.categoryIds.contains(e.categoryId)) {
        return false;
      }
      if (_filter.paymentMethodIds.isNotEmpty &&
          !_filter.paymentMethodIds.contains(e.paymentMethodId)) {
        return false;
      }
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
    setState(() => _filter = ExpenseFilter.currentMonth());
  }

  void _navigateToAddExpense() {
    Navigator.of(context).push(
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
    ).then((_) => _fetch());
  }

  void _navigateToCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<GroupCategoryBloc>(),
          child: GroupCategoriesPage(
            groupId: widget.groupId,
            userId: _userId,
          ),
        ),
      ),
    ).then((_) => _fetchFilterData());
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
          // Construimos un FilterDrawer que muestra categorías de grupo en lugar de personales
          return _GroupFilterDrawer(
            filter: _filter,
            groupCategories:
                catState is GroupCategoryLoaded ? catState.categories : [],
            onFilterChanged: (f) => setState(() => _filter = f),
            onClear: _clearFilters,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            context.showSnackBar(state.message);
            _fetch();
          } else if (state is GroupError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupExpensesLoaded) {
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
                        return GroupExpenseCard(expense: filtered[index]);
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
      initialDateRange:
          DateTimeRange(start: _localFilter.startDate, end: _localFilter.endDate),
      locale: const Locale('es'),
    );
    if (picked != null) {
      setState(() {
        _localFilter = _localFilter.copyWith(
          startDate: picked.start,
          endDate:
              DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59),
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
                        final selected = _localFilter.categoryIds.contains(cat.id);
                        return FilterChip(
                          selected: selected,
                          label: Text('${cat.icon} ${cat.name}',
                              style: const TextStyle(fontSize: 13)),
                          onSelected: (val) {
                            setState(() {
                              final ids = Set<String>.from(_localFilter.categoryIds);
                              val ? ids.add(cat.id) : ids.remove(cat.id);
                              _localFilter = _localFilter.copyWith(categoryIds: ids);
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
                            final selected =
                                _localFilter.paymentMethodIds.contains(method.id);
                            return FilterChip(
                              selected: selected,
                              label: Text('${method.icon} ${method.name}',
                                  style: const TextStyle(fontSize: 13)),
                              onSelected: (val) {
                                setState(() {
                                  final ids =
                                      Set<String>.from(_localFilter.paymentMethodIds);
                                  val ? ids.add(method.id) : ids.remove(method.id);
                                  _localFilter =
                                      _localFilter.copyWith(paymentMethodIds: ids);
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
