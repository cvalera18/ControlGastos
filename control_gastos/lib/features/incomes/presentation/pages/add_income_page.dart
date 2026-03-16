import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/validators.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/presentation/bloc/income_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

class AddIncomePage extends StatefulWidget {
  final Income? existingIncome;
  final String? preselectedGroupId;

  const AddIncomePage({
    super.key,
    this.existingIncome,
    this.preselectedGroupId,
  });

  @override
  State<AddIncomePage> createState() => _AddIncomePageState();
}

class _AddIncomePageState extends State<AddIncomePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  PaymentMethod? _selectedPaymentMethod;
  Group? _selectedGroup;

  String? _prefillMethodId;

  bool get _isEditMode => widget.existingIncome != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final i = widget.existingIncome!;
      _descriptionController.text = i.description;
      _amountController.text = i.amount.toStringAsFixed(2);
      _notesController.text = i.notes ?? '';
      _selectedDate = i.date;
      _prefillMethodId = i.paymentMethodId;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(authState.user.id));
      if (!_isEditMode) {
        context.read<GroupBloc>().add(FetchGroupsEvent(authState.user.id));
      }
    }

    // Pre-select group if navigating from group detail
    if (widget.preselectedGroupId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = context.read<GroupBloc>().state;
        if (state is GroupsLoaded) {
          final match = state.groups
              .where((g) => g.id == widget.preselectedGroupId)
              .firstOrNull;
          if (match != null) setState(() => _selectedGroup = match);
        }
      });
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
    if (_selectedPaymentMethod == null) {
      context.showSnackBar('Selecciona un método de pago', isError: true);
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final now = DateTime.now();
    final amount = double.parse(_amountController.text.replaceAll(',', '.'));
    final description = _descriptionController.text.trim();
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    if (_isEditMode) {
      final updated = widget.existingIncome!.copyWith(
        amount: amount,
        description: description,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: notes,
        updatedAt: now,
      );
      context.read<IncomeBloc>().add(UpdateIncomeEvent(updated));
    } else {
      final income = Income(
        id: const Uuid().v4(),
        userId: authState.user.id,
        amount: amount,
        description: description,
        paymentMethodId: _selectedPaymentMethod!.id,
        paymentMethodName: _selectedPaymentMethod!.name,
        date: _selectedDate,
        notes: notes,
        groupId: _selectedGroup?.id,
        createdAt: now,
        updatedAt: now,
      );
      context.read<IncomeBloc>().add(AddIncomeEvent(income));
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
        title: Text(_isEditMode ? 'Editar Ingreso' : 'Nuevo Ingreso'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: BlocListener<IncomeBloc, IncomeState>(
        listener: (context, state) {
          if (state is IncomeOperationSuccess) {
            context.showSnackBar(state.message);
            GoRouter.of(context).pop();
          } else if (state is IncomeError) {
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
                // ── Grupo (opcional, solo en creación) ──────────────────────
                if (!_isEditMode)
                  BlocBuilder<GroupBloc, GroupState>(
                    builder: (context, state) {
                      if (state is GroupsLoaded && state.groups.isNotEmpty) {
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
                                itemCount: state.groups.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final group = state.groups[index];
                                  final isSelected =
                                      _selectedGroup?.id == group.id;
                                  return FilterChip(
                                    avatar:
                                        const Icon(Icons.group, size: 16),
                                    label: Text(group.name),
                                    selected: isSelected,
                                    onSelected: (_) => setState(() {
                                      _selectedGroup =
                                          isSelected ? null : group;
                                    }),
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

                // ── Descripción ──────────────────────────────────────────────
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (v) =>
                      Validators.required(v, fieldName: 'Descripción'),
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
                  shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                const SizedBox(height: 16),

                // ── Método de pago ───────────────────────────────────────────
                const Text('Cuenta / Método de pago',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
                  builder: (context, state) {
                    if (state is PaymentMethodLoaded) {
                      if (_selectedPaymentMethod == null &&
                          _prefillMethodId != null) {
                        final match = state.paymentMethods
                            .where((m) => m.id == _prefillMethodId)
                            .firstOrNull;
                        if (match != null) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => setState(
                                () => _selectedPaymentMethod = match),
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
                                _selectedPaymentMethod?.id == method.id;
                            return FilterChip(
                              label: Text('${method.icon} ${method.name}'),
                              selected: isSelected,
                              onSelected: (_) => setState(
                                  () => _selectedPaymentMethod = method),
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
                BlocBuilder<IncomeBloc, IncomeState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is IncomeLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.tertiary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onTertiary,
                      ),
                      child: state is IncomeLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isEditMode
                              ? 'Guardar cambios'
                              : 'Guardar ingreso'),
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
