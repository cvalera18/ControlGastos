import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/validators.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/presentation/bloc/expense_bloc.dart';
import 'package:control_gastos/features/expenses/presentation/widgets/category_selector.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

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

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(FetchCategoriesEvent(authState.user.id));
      context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(authState.user.id));
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
    if (_formKey.currentState?.validate() ?? false) {
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
      final expense = Expense(
        id: const Uuid().v4(),
        userId: authState.user.id,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );

      context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
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
        title: const Text('Nuevo Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocListener<ExpenseBloc, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseOperationSuccess) {
            context.showSnackBar(state.message);
            context.go('/home');
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
                          : const Text('Guardar gasto'),
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
