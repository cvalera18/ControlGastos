import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/currency_formatter.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';
import 'package:control_gastos/features/payment_methods/presentation/bloc/payment_method_bloc.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
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
    context.read<PaymentMethodBloc>().add(FetchPaymentMethodsEvent(_userId));
  }

  void _showPaymentMethodDialog(PaymentMethod? existing) {
    if (_userId.isEmpty) return;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final balanceController = TextEditingController(
      text: existing?.initialBalance != null
          ? existing!.initialBalance!.toStringAsFixed(2)
          : '0.00',
    );
    final creditLimitController = TextEditingController(
      text: existing?.creditLimit != null
          ? existing!.creditLimit!.toStringAsFixed(2)
          : '',
    );
    String selectedIcon = existing?.icon ?? PaymentMethodType.other.defaultIcon;
    PaymentMethodType selectedType = existing?.type ?? PaymentMethodType.other;
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) {
          final showBalance =
              selectedType.hasBalance; // checking, savings, vista, digital, cash
          final showCreditLimit = selectedType == PaymentMethodType.creditCard;

          return AlertDialog(
            title: Text(isEdit ? 'Editar método de pago' : 'Nuevo método de pago'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PaymentMethodType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: PaymentMethodType.values
                        .where((type) => type != PaymentMethodType.cash || isEdit) // Efectivo no se puede crear, solo editar
                        .map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(type.defaultIcon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(type.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (type) {
                      if (type == null) return;
                      setStateDialog(() {
                        selectedIcon = type.defaultIcon;
                        selectedType = type;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  // Campo de saldo para cuentas (no tarjetas) — solo al crear
                  if (showBalance && !isEdit) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 4),
                    TextField(
                      controller: balanceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Saldo actual',
                        hintText: '0.00',
                        helperText: 'Los gastos e ingresos futuros ajustarán este saldo',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                  ],
                  // Campo de cupo para tarjetas de crédito
                  if (showCreditLimit) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 4),
                    TextField(
                      controller: creditLimitController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cupo de la tarjeta',
                        hintText: '0.00',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('El nombre es obligatorio')),
                    );
                    return;
                  }

                  // Validar campos obligatorios según tipo
                  if (showBalance && !isEdit && balanceController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('El saldo inicial es obligatorio')),
                    );
                    return;
                  }

                  if (showCreditLimit && creditLimitController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('El cupo de la tarjeta es obligatorio')),
                    );
                    return;
                  }

                  // En edición, el saldo inicial se preserva siempre
                  final newBalance = isEdit
                      ? existing.initialBalance
                      : (showBalance
                          ? double.tryParse(balanceController.text.replaceAll(',', '.')) ?? 0
                          : null);
                  final newCreditLimit = showCreditLimit
                      ? double.tryParse(
                          creditLimitController.text.replaceAll(',', '.'))
                      : null;

                  // balanceStartDate: se preserva en edición, se asigna al crear
                  DateTime? newStartDate;
                  if (isEdit) {
                    newStartDate = existing.balanceStartDate;
                  } else if (newBalance != null && newBalance != 0) {
                    newStartDate = DateTime.now();
                  }

                  if (isEdit) {
                    final updated = PaymentMethod(
                      id: existing.id,
                      userId: existing.userId,
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      type: selectedType,
                      isDefault: existing.isDefault,
                      initialBalance: newBalance,
                      balanceStartDate: newStartDate,
                      creditLimit: newCreditLimit,
                    );
                    context
                        .read<PaymentMethodBloc>()
                        .add(UpdatePaymentMethodEvent(updated));
                  } else {
                    final method = PaymentMethod(
                      id: const Uuid().v4(),
                      userId: _userId,
                      name: nameController.text.trim(),
                      icon: selectedIcon,
                      type: selectedType,
                      initialBalance: newBalance,
                      balanceStartDate: newStartDate,
                      creditLimit: newCreditLimit,
                    );
                    context
                        .read<PaymentMethodBloc>()
                        .add(AddPaymentMethodEvent(method));
                  }
                  Navigator.pop(ctx);
                },
                child: Text(isEdit ? 'Guardar' : 'Agregar'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Métodos de pago'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPaymentMethodDialog(null),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<PaymentMethodBloc, PaymentMethodState>(
        listener: (context, state) {
          if (state is PaymentMethodOperationSuccess) {
            context.showSnackBar(state.message);
            _fetch();
          } else if (state is PaymentMethodError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is PaymentMethodLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PaymentMethodLoaded) {
            if (state.paymentMethods.isEmpty) {
              return const Center(child: Text('No hay métodos de pago registrados'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              itemCount: state.paymentMethods.length,
              itemBuilder: (context, index) {
                final method = state.paymentMethods[index];
                return _PaymentMethodCard(
                  method: method,
                  currentBalance: state.balances[method.id],
                  availableCredit: state.availableCredits[method.id],
                  onTap: () async {
                    await context.push('/payment-method-detail', extra: method);
                    if (context.mounted) _fetch();
                  },
                  onEdit: () => _showPaymentMethodDialog(method),
                  onDelete: () => context
                      .read<PaymentMethodBloc>()
                      .add(DeletePaymentMethodEvent(method.id)),
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

class _PaymentMethodCard extends StatelessWidget {
  final PaymentMethod method;
  final double? currentBalance;
  final double? availableCredit;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PaymentMethodCard({
    required this.method,
    required this.currentBalance,
    required this.availableCredit,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasBalance = method.type.hasBalance && method.initialBalance != null;
    final hasCreditLimit =
        method.type == PaymentMethodType.creditCard && method.creditLimit != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
          children: [
            Text(method.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.type.displayName,
                    style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                  ),
                  // Saldo para cuentas
                  if (hasBalance && currentBalance != null) ...[
                    const SizedBox(height: 8),
                    _BalanceRow(currentBalance: currentBalance!),
                  ],
                  // Cupo para tarjetas de crédito
                  if (hasCreditLimit && availableCredit != null) ...[
                    const SizedBox(height: 6),
                    _CreditRow(availableCredit: availableCredit!),
                  ],
                ],
              ),
            ),
            // No mostrar botones para la cuenta Efectivo
            if (method.type != PaymentMethodType.cash)
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ],
              ),
          ],
          ),
        ),
      ),
    );
  }
}

class _CreditRow extends StatelessWidget {
  final double availableCredit;

  const _CreditRow({required this.availableCredit});

  @override
  Widget build(BuildContext context) {
    final isExceeded = availableCredit < 0;
    final color = isExceeded
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(Icons.credit_card_outlined, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          CurrencyFormatter.format(availableCredit),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final double currentBalance;

  const _BalanceRow({required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    final isNegative = currentBalance < 0;
    final balanceColor = isNegative
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Icon(
          isNegative ? Icons.trending_down : Icons.account_balance_wallet_outlined,
          size: 13,
          color: balanceColor,
        ),
        const SizedBox(width: 4),
        Text(
          CurrencyFormatter.format(currentBalance),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: balanceColor,
          ),
        ),
      ],
    );
  }
}
