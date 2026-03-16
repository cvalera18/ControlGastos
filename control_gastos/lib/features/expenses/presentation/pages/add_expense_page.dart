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
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? existingExpense;

  const AddExpensePage({super.key, this.existingExpense});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;
  Group? _selectedGroup;

  // Used to pre-select category/method in edit mode once lists load
  String? _prefillCategoryId;
  String? _prefillMethodId;

  bool get _isEditMode => widget.existingExpense != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final e = widget.existingExpense!;
      _descriptionController.text = e.description;
      _amountController.text = e.amount.toStringAsFixed(2);
      _notesController.text = e.notes ?? '';
      _selectedDate = e.date;
      _prefillCategoryId = e.categoryId;
      _prefillMethodId = e.paymentMethodId;
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

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedCategory == null) {
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

    if (_isEditMode) {
      final updated = widget.existingExpense!.copyWith(
        amount: amount,
        description: description,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        categoryIcon: _selectedCategory!.icon,
        categoryColor: _selectedCategory!.color,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: notes,
        updatedAt: now,
      );
      context.read<ExpenseBloc>().add(UpdateExpenseEvent(updated));
    } else {
      final expense = Expense(
        id: const Uuid().v4(),
        userId: authState.user.id,
        amount: amount,
        description: description,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        categoryIcon: _selectedCategory!.icon,
        categoryColor: _selectedCategory!.color,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );
      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));

      // Si hay grupo seleccionado, también guardar en group_expenses
      if (_selectedGroup != null) {
        final groupExpense = GroupExpense(
          id: const Uuid().v4(),
          groupId: _selectedGroup!.id,
          userId: authState.user.id,
          userName: authState.user.name,
          amount: amount,
          description: description,
          categoryId: _selectedCategory!.id,
          categoryName: _selectedCategory!.name,
          categoryIcon: _selectedCategory!.icon,
          categoryColor: _selectedCategory!.color,
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
          onPressed: () => GoRouter.of(context).go('/home'),
        ),
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            context.showSnackBar(state.message);
            GoRouter.of(context).go('/home');
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
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (v) => Validators.required(v, fieldName: 'Descripción'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text('Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _pickDate,
                  shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),
                const Text('Categoría', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    if (state is CategoryLoaded) {
                      // Pre-seleccionar en modo edición
                      if (_selectedCategory == null && _prefillCategoryId != null) {
                        final match = state.categories.where((c) => c.id == _prefillCategoryId).firstOrNull;
                        if (match != null) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => setState(() => _selectedCategory = match),
                          );
                        }
                      }
                      return CategorySelector(
                        categories: state.categories,
                        selected: _selectedCategory,
                        onSelected: (cat) => setState(() => _selectedCategory = cat),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),
                const Text('Método de pago', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                  builder: (context, state) {
                    if (state is PaymentMethodLoaded) {
                      // Pre-seleccionar en modo edición
                      if (_selectedPaymentMethod == null && _prefillMethodId != null) {
                        final match = state.paymentMethods.where((m) => m.id == _prefillMethodId).firstOrNull;
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
                              onSelected: (_) => setState(() => _selectedPaymentMethod = method),
                            );
                          },
                        ),
                      );
                    }
                    return const LinearProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),
                // Selector de grupo (solo en modo creación)
                if (!_isEditMode) ...[
                  const Text('Grupo (opcional)', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) {
                      if (state is GroupsLoaded && state.groups.isNotEmpty) {
                        return SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.groups.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final group = state.groups[index];
                              final isSelected = _selectedGroup?.id == group.id;
                              return FilterChip(
                                avatar: const Icon(Icons.group, size: 16),
                                label: Text(group.name),
                                selected: isSelected,
                                onSelected: (_) => setState(
                                  () => _selectedGroup = isSelected ? null : group,
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
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
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is ExpenseLoading ? null : _submit,
                      child: state is ExpenseLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
