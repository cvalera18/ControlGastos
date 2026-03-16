import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/validators.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_category_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

class AddGroupExpensePage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String userId;
  final String userName;

  const AddGroupExpensePage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userId,
    required this.userName,
  });

  @override
  State<AddGroupExpensePage> createState() => _AddGroupExpensePageState();
}

class _AddGroupExpensePageState extends State<AddGroupExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  GroupCategory? _selectedCategory;
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    context.read<GroupCategoryBloc>().add(FetchGroupCategoriesEvent(widget.groupId));
    context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(widget.userId));
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

      final now = DateTime.now();
      final expense = GroupExpense(
        id: const Uuid().v4(),
        groupId: widget.groupId,
        userId: widget.userId,
        userName: widget.userName,
        amount: double.parse(_amountController.text.replaceAll(',', '.')),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        categoryIcon: _selectedCategory!.icon,
        categoryColor: _selectedCategory!.color,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        createdAt: now,
      );

      context.read<GroupBloc>().add(AddGroupExpenseEvent(expense));
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
        title: Text('Nuevo gasto en ${widget.groupName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocListener<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            context.showSnackBar(state.message);
            Navigator.of(context).pop();
          } else if (state is GroupError) {
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
                  title: Text(
                      'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _pickDate,
                  shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),
                const Text('Categoría del grupo', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                BlocBuilder<GroupCategoryBloc, GroupCategoryState>(
                  builder: (context, state) {
                    if (state is GroupCategoryLoaded) {
                      if (state.categories.isEmpty) {
                        return const Text(
                          'Sin categorías en el grupo. Crea una desde el detalle del grupo.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.categories.map((cat) {
                          final isSelected = _selectedCategory?.id == cat.id;
                          return FilterChip(
                            selected: isSelected,
                            avatar: CircleAvatar(
                              backgroundColor: Color(cat.color),
                              child: Text(cat.icon, style: const TextStyle(fontSize: 12)),
                            ),
                            label: Text(cat.name),
                            onSelected: (_) => setState(() => _selectedCategory = cat),
                          );
                        }).toList(),
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
                BlocBuilder<GroupBloc, GroupState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is GroupLoading ? null : _submit,
                      child: state is GroupLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
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
