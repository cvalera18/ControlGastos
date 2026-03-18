import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/validators.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/widgets/category_selector.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_category_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? existingExpense;
  final String? prefillPaymentMethodId;

  const AddExpensePage({super.key, this.existingExpense, this.prefillPaymentMethodId});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  // Personal category (used when no group selected)
  Category? _selectedPersonalCategory;
  // Group category (used when group is selected)
  GroupCategory? _selectedGroupCategory;

  PaymentMethod? _selectedPaymentMethod;
  Group? _selectedGroup;

  // Pre-fill IDs for edit mode
  String? _prefillCategoryId;       // solo para gastos personales
  String? _prefillGroupId;          // si el gasto es grupal
  String? _prefillGroupCategoryId;  // categoría del grupo a pre-seleccionar
  String? _prefillMethodId;

  bool get _isEditMode => widget.existingExpense != null;
  bool get _groupMode => _selectedGroup != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final e = widget.existingExpense!;
      _descriptionController.text = e.description;
      _amountController.text = e.amount.toStringAsFixed(2);
      _notesController.text = e.notes ?? '';
      _selectedDate = e.date;
      _prefillMethodId = e.paymentMethodId;
      if (e.groupId != null) {
        _prefillGroupId = e.groupId;
        _prefillGroupCategoryId = e.categoryId;
      } else {
        _prefillCategoryId = e.categoryId;
      }
    }

    if (!_isEditMode && widget.prefillPaymentMethodId != null) {
      _prefillMethodId = widget.prefillPaymentMethodId;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(FetchCategoriesEvent(authState.user.id));
      context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(authState.user.id));
      context.read<GroupBloc>().add(FetchGroupsEvent(authState.user.id));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onGroupSelected(Group? group) {
    setState(() {
      _selectedGroup = group;
      // Limpiar categoría al cambiar de modo
      _selectedPersonalCategory = null;
      _selectedGroupCategory = null;
    });
    if (group != null) {
      context.read<GroupCategoryBloc>().add(FetchGroupCategoriesEvent(group.id));
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validar categoría según modo
    if (_groupMode && _selectedGroupCategory == null) {
      context.showSnackBar('Selecciona una categoría del grupo', isError: true);
      return;
    }
    if (!_groupMode && _selectedPersonalCategory == null) {
      context.showSnackBar('Selecciona una categoría', isError: true);
      return;
    }
    if (_selectedPaymentMethod == null) {
      context.showSnackBar('Selecciona un método de pago', isError: true);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final now = DateTime.now();
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final description = _descriptionController.text.trim();
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    // Extraer datos de categoría según modo
    final String categoryId;
    final String categoryName;
    final String categoryIcon;
    final int categoryColor;

    if (_groupMode) {
      categoryId = _selectedGroupCategory!.id;
      categoryName = _selectedGroupCategory!.name;
      categoryIcon = _selectedGroupCategory!.icon;
      categoryColor = _selectedGroupCategory!.color;
    } else {
      categoryId = _selectedPersonalCategory!.id;
      categoryName = _selectedPersonalCategory!.name;
      categoryIcon = _selectedPersonalCategory!.icon;
      categoryColor = _selectedPersonalCategory!.color;
    }

    if (_isEditMode) {
      final existing = widget.existingExpense!;
      final updated = existing.copyWith(
        amount: amount,
        description: description,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: notes,
        updatedAt: now,
      );
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(updated));

      // Si es un gasto grupal, sincronizar el documento de grupo con el mismo ID
      if (existing.groupId != null) {
        final updatedGroupExpense = GroupExpense(
          id: existing.id,
          groupId: existing.groupId!,
          userId: authState.user.id,
          userName: authState.user.name,
          amount: amount,
          description: description,
          categoryId: categoryId,
          categoryName: categoryName,
          categoryIcon: categoryIcon,
          categoryColor: categoryColor,
          paymentMethodId: _selectedPaymentMethod!.id,
          paymentMethodName: _selectedPaymentMethod!.name,
          date: _selectedDate,
          notes: notes,
          createdAt: existing.createdAt,
        );
        context.read<GroupBloc>().add(UpdateGroupExpenseEvent(updatedGroupExpense));
      }
    } else {
      // Usar mismo ID para personal y grupo (facilita el borrado en cascada)
      final sharedId = const Uuid().v4();

      // Siempre guardar como gasto personal
      final expense = Expense(
        id: sharedId,
        userId: authState.user.id,
        amount: amount,
        description: description,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIcon: categoryIcon,
        categoryColor: categoryColor,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: notes,
        groupId: _groupMode ? _selectedGroup!.id : null,
        createdAt: now,
        updatedAt: now,
      );
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));

      // Si hay grupo, también guardar como gasto de grupo con el mismo ID
      if (_groupMode) {
        final groupExpense = GroupExpense(
          id: sharedId,
          groupId: _selectedGroup!.id,
          userId: authState.user.id,
          userName: authState.user.name,
          amount: amount,
          description: description,
          categoryId: categoryId,
          categoryName: categoryName,
          categoryIcon: categoryIcon,
          categoryColor: categoryColor,
          paymentMethodId: _selectedPaymentMethod!.id,
          paymentMethodName: _selectedPaymentMethod!.name,
          date: _selectedDate,
          notes: notes,
          createdAt: now,
        );
        context.read<GroupBloc>().add(AddGroupExpenseEvent(groupExpense));
      }
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Gasto' : 'Nuevo Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            context.showSnackBar(state.message);
            GoRouter.of(context).pop();
          } else if (state is ExpenseError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Grupo (opcional en creación; solo lectura en edición grupal) ──
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    if (state is GroupsLoaded && state.groups.isNotEmpty) {
                      // Auto-seleccionar el grupo al editar un gasto grupal
                      if (_prefillGroupId != null && _selectedGroup == null) {
                        final match = state.groups
                            .where((g) => g.id == _prefillGroupId)
                            .firstOrNull;
                        if (match != null) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _onGroupSelected(match),
                          );
                        }
                      }

                      final isGroupLocked = _isEditMode && _prefillGroupId != null;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGroupLocked ? 'Grupo' : 'Grupo (opcional)',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: state.groups.length,
                              separatorBuilder: (_, i) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final group = state.groups[index];
                                final isSelected = _selectedGroup?.id == group.id;
                                return FilterChip(
                                  avatar: const Icon(Icons.group, size: 16),
                                  label: Text(group.name),
                                  selected: isSelected,
                                  // En edición grupal los chips son solo lectura
                                  onSelected: isGroupLocked
                                      ? null
                                      : (_) => _onGroupSelected(
                                            isSelected ? null : group,
                                          ),
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

                // ── Monto ────────────────────────────────────────────────────
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(Icons.attach_money),
                    prefixText: '\$ ',
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 16),

                // ── Descripción ──────────────────────────────────────────────
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (v) => Validators.required(v, fieldName: 'Descripción'),
                ),
                const SizedBox(height: 16),

                // ── Fecha ────────────────────────────────────────────────────
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(
                      'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _pickDate,
                  shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),

                // ── Categoría ────────────────────────────────────────────────
                Text(
                  _groupMode ? 'Categoría del grupo' : 'Categoría',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                if (_groupMode)
                  BlocBuilder<GroupCategoryBloc, GroupCategoryState>(
                    builder: (context, state) {
                      if (state is GroupCategoryLoading) {
                        return const LinearProgressIndicator();
                      }
                      if (state is GroupCategoryLoaded) {
                        // Auto-seleccionar categoría al editar gasto grupal
                        if (_selectedGroupCategory == null &&
                            _prefillGroupCategoryId != null) {
                          final match = state.categories
                              .where((c) => c.id == _prefillGroupCategoryId)
                              .firstOrNull;
                          if (match != null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedGroupCategory = match),
                            );
                          }
                        }

                        if (state.categories.isEmpty) {
                          return const Text(
                            'Este grupo no tiene categorías. Crea una desde el detalle del grupo.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          );
                        }
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: state.categories.map((cat) {
                            final isSelected = _selectedGroupCategory?.id == cat.id;
                            return FilterChip(
                              selected: isSelected,
                              avatar: CircleAvatar(
                                backgroundColor: Color(cat.color),
                                child: Text(cat.icon,
                                    style: const TextStyle(fontSize: 12)),
                              ),
                              label: Text(cat.name),
                              onSelected: (_) =>
                                  setState(() => _selectedGroupCategory = cat),
                            );
                          }).toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  )
                else
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        if (_selectedPersonalCategory == null &&
                            _prefillCategoryId != null) {
                          final match = state.categories
                              .where((c) => c.id == _prefillCategoryId)
                              .firstOrNull;
                          if (match != null) {
                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) => setState(() => _selectedPersonalCategory = match),
                            );
                          }
                        }
                        return CategorySelector(
                          categories: state.categories,
                          selected: _selectedPersonalCategory,
                          onSelected: (cat) =>
                              setState(() => _selectedPersonalCategory = cat),
                        );
                      }
                      return const LinearProgressIndicator();
                    },
                  ),
                const SizedBox(height: 16),

                // ── Método de pago ───────────────────────────────────────────
                const Text('Método de pago',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                  builder: (context, state) {
                    if (state is PaymentMethodLoaded) {
                      if (_selectedPaymentMethod == null && _prefillMethodId != null) {
                        final match = state.paymentMethods
                            .where((m) => m.id == _prefillMethodId)
                            .firstOrNull;
                        if (match != null) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => setState(() => _selectedPaymentMethod = match),
                          );
                        }
                      }
                      return SizedBox(
                        height: 48,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.paymentMethods.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final method = state.paymentMethods[index];
                            final isSelected = _selectedPaymentMethod?.id == method.id;
                            return FilterChip(
                              label: Text('${method.icon} ${method.name}'),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedPaymentMethod = method),
                            );
                          },
                        ),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),

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

                // ── Botón guardar ────────────────────────────────────────────
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is ExpenseLoading ? null : _submit,
                      child: state is ExpenseLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEditMode ? 'Guardar cambios' : 'Guardar gasto'),
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
