import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/validators.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_category_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_expense.dart';
import 'package:control_gastos/features/recurring_expenses/domain/entities/recurring_frequency.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_state.dart';

class AddRecurringExpensePage extends StatefulWidget {
  final RecurringExpense? existing;
  final PaymentMethod? prefillPaymentMethod;

  const AddRecurringExpensePage({super.key, this.existing, this.prefillPaymentMethod});

  @override
  State<AddRecurringExpensePage> createState() =>
      _AddRecurringExpensePageState();
}

class _AddRecurringExpensePageState extends State<AddRecurringExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  RecurringFrequency _frequency = RecurringFrequency.monthly;
  int _dayOfMonth = DateTime.now().day;
  DateTime _startDate = DateTime.now();

  PaymentMethod? _selectedMethod;
  Category? _selectedCategory;
  GroupCategory? _selectedGroupCategory;
  Group? _selectedGroup;

  String? _prefillMethodId;
  String? _prefillCategoryId;
  String? _prefillGroupCategoryId;
  bool _methodLocked = false;

  bool get _isEdit => widget.existing != null;
  bool get _groupMode => _selectedGroup != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _nameController.text = e.name;
      _amountController.text = e.amount.toStringAsFixed(2);
      _notesController.text = e.notes ?? '';
      _frequency = e.frequency;
      _dayOfMonth = e.dayOfMonth;
      _startDate = e.startDate;
      _prefillMethodId = e.paymentMethodId;
      if (e.groupId != null) {
        _prefillGroupCategoryId = e.categoryId;
        context.read<GroupCategoryBloc>().add(FetchGroupCategoriesEvent(e.groupId!));
      } else {
        _prefillCategoryId = e.categoryId;
      }
    } else if (widget.prefillPaymentMethod != null) {
      _selectedMethod = widget.prefillPaymentMethod;
      _methodLocked = true;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(FetchCategoriesEvent(authState.user.id));
      context
          .read<PaymentMethodBloc>()
          .add(FetchPaymentMethodsEvent(authState.user.id));
      context.read<GroupBloc>().add(FetchGroupsEvent(authState.user.id));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedMethod == null) {
      context.showSnackBar('Selecciona un método de pago', isError: true);
      return;
    }
    if (_groupMode && _selectedGroupCategory == null) {
      context.showSnackBar('Selecciona una categoría', isError: true);
      return;
    }
    if (!_groupMode && _selectedCategory == null) {
      context.showSnackBar('Selecciona una categoría', isError: true);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final amount = double.parse(_amountController.text.replaceAll(',', '.'));

    final categoryId = _groupMode ? _selectedGroupCategory!.id : _selectedCategory!.id;
    final categoryName = _groupMode ? _selectedGroupCategory!.name : _selectedCategory!.name;
    final categoryIcon = _groupMode ? _selectedGroupCategory!.icon : _selectedCategory!.icon;
    final categoryColor = _groupMode ? _selectedGroupCategory!.color : _selectedCategory!.color;

    // Calculate initial nextDueDate
    DateTime nextDue = _firstDueDate();

    if (_isEdit) {
      final updated = widget.existing!.copyWith(
        name: _nameController.text.trim(),
        amount: amount,
        paymentMethodId: _selectedMethod!.id,
        paymentMethodName: _selectedMethod!.name,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
        groupId: _selectedGroup?.id,
        frequency: _frequency,
        dayOfMonth: _dayOfMonth,
        startDate: _startDate,
        nextDueDate: nextDue,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      context
          .read<RecurringExpenseBloc>()
          .add(UpdateRecurringExpenseEvent(updated));
    } else {
      final expense = RecurringExpense(
        id: const Uuid().v4(),
        userId: authState.user.id,
        name: _nameController.text.trim(),
        amount: amount,
        paymentMethodId: _selectedMethod!.id,
        paymentMethodName: _selectedMethod!.name,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
        groupId: _selectedGroup?.id,
        frequency: _frequency,
        dayOfMonth: _dayOfMonth,
        startDate: _startDate,
        nextDueDate: nextDue,
        isActive: true,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );
      context
          .read<RecurringExpenseBloc>()
          .add(AddRecurringExpenseEvent(expense));
    }
  }

  /// Calculates the first due date based on frequency and selected day/start.
  DateTime _firstDueDate() {
    final today = DateTime.now();
    switch (_frequency) {
      case RecurringFrequency.weekly:
      case RecurringFrequency.biweekly:
        return _startDate.isBefore(today) ? today : _startDate;
      case RecurringFrequency.monthly:
        final candidate = DateTime(today.year, today.month, _dayOfMonth);
        return candidate.isBefore(today)
            ? DateTime(today.year, today.month + 1, _dayOfMonth)
            : candidate;
      case RecurringFrequency.annual:
        final candidate =
            DateTime(today.year, _startDate.month, _startDate.day);
        return candidate.isBefore(today)
            ? DateTime(today.year + 1, _startDate.month, _startDate.day)
            : candidate;
    }
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _startDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Editar recurrente' : 'Nuevo recurrente'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: BlocListener<RecurringExpenseBloc, RecurringExpenseState>(
        listener: (context, state) {
          if (state is RecurringExpenseOperationSuccess) {
            context.showSnackBar(state.message);
            GoRouter.of(context).pop();
          } else if (state is RecurringExpenseError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Nombre ───────────────────────────────────────────────────
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Nombre'),
                ),
                const SizedBox(height: 16),

                // ── Monto ────────────────────────────────────────────────────
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: '\$ ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),

                // ── Frecuencia ───────────────────────────────────────────────
                const Text('Frecuencia',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                DropdownButtonFormField<RecurringFrequency>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: RecurringFrequency.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(f.displayName),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _frequency = v);
                  },
                ),
                const SizedBox(height: 16),

                // ── Día del mes (solo para mensual) ──────────────────────────
                if (_frequency == RecurringFrequency.monthly) ...[
                  const Text('Día de cobro',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _dayOfMonth,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(
                      28,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text('Día ${i + 1}'),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _dayOfMonth = v);
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Fecha de inicio ──────────────────────────────────────────
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 8),
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                      'Inicio: ${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _pickStartDate,
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),

                // ── Método de pago ───────────────────────────────────────────
                const Text('Cuenta / Método de pago',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                if (_methodLocked && _selectedMethod != null)
                  Chip(
                    avatar: Text(_selectedMethod!.icon),
                    label: Text(_selectedMethod!.name),
                  )
                else
                  BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                    builder: (context, state) {
                      if (state is PaymentMethodLoaded) {
                        if (_selectedMethod == null &&
                            _prefillMethodId != null) {
                          final match = state.paymentMethods
                              .where((m) => m.id == _prefillMethodId)
                              .firstOrNull;
                          if (match != null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedMethod = match),
                            );
                          }
                        }
                        return SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.paymentMethods.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final method = state.paymentMethods[index];
                              final isSelected =
                                  _selectedMethod?.id == method.id;
                              return FilterChip(
                                label: Text('${method.icon} ${method.name}'),
                                selected: isSelected,
                                onSelected: (_) =>
                                    setState(() => _selectedMethod = method),
                              );
                            },
                          ),
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                const SizedBox(height: 16),

                // ── Grupo (opcional) ─────────────────────────────────────────
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, groupState) {
                    if (groupState is GroupsLoaded &&
                        groupState.groups.isNotEmpty) {
                      if (_isEdit && _selectedGroup == null) {
                        final existingGroupId = widget.existing?.groupId;
                        if (existingGroupId != null) {
                          final match = groupState.groups
                              .where((g) => g.id == existingGroupId)
                              .firstOrNull;
                          if (match != null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedGroup = match),
                            );
                          }
                        }
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Grupo (opcional)',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: groupState.groups.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final group = groupState.groups[index];
                                final isSelected =
                                    _selectedGroup?.id == group.id;
                                return FilterChip(
                                  avatar:
                                      const Icon(Icons.group, size: 16),
                                  label: Text(group.name),
                                  selected: isSelected,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedGroup =
                                          isSelected ? null : group;
                                      _selectedCategory = null;
                                      _selectedGroupCategory = null;
                                    });
                                    if (!isSelected) {
                                      context
                                          .read<GroupCategoryBloc>()
                                          .add(FetchGroupCategoriesEvent(
                                              group.id));
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // ── Categoría ────────────────────────────────────────────────
                const Text('Categoría',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                if (_groupMode)
                  BlocBuilder<GroupCategoryBloc, GroupCategoryState>(
                    builder: (context, state) {
                      if (state is GroupCategoryLoading) {
                        return const LinearProgressIndicator();
                      }
                      if (state is GroupCategoryLoaded) {
                        if (_selectedGroupCategory == null &&
                            _prefillGroupCategoryId != null) {
                          final match = state.categories
                              .where((c) => c.id == _prefillGroupCategoryId)
                              .firstOrNull;
                          if (match != null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(
                                  () => _selectedGroupCategory = match),
                            );
                          }
                        }
                        return SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = state.categories[index];
                              final isSelected =
                                  _selectedGroupCategory?.id == cat.id;
                              return FilterChip(
                                avatar: Text(cat.icon),
                                label: Text(cat.name),
                                selected: isSelected,
                                onSelected: (_) => setState(
                                    () => _selectedGroupCategory = cat),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )
                else
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        if (_selectedCategory == null &&
                            _prefillCategoryId != null) {
                          final match = state.categories
                              .where((c) => c.id == _prefillCategoryId)
                              .firstOrNull;
                          if (match != null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedCategory = match),
                            );
                          }
                        }
                        return SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.categories.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = state.categories[index];
                              final isSelected =
                                  _selectedCategory?.id == cat.id;
                              return FilterChip(
                                avatar: Text(cat.icon),
                                label: Text(cat.name),
                                selected: isSelected,
                                onSelected: (_) =>
                                    setState(() => _selectedCategory = cat),
                              );
                            },
                          ),
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),

                // ── Notas ────────────────────────────────────────────────────
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas (opcional)',
                    prefixIcon: Icon(Icons.notes),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Guardar ──────────────────────────────────────────────────
                BlocBuilder<RecurringExpenseBloc, RecurringExpenseState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed:
                          state is RecurringExpenseLoading ? null : _submit,
                      child: state is RecurringExpenseLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEdit ? 'Guardar cambios' : 'Guardar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
