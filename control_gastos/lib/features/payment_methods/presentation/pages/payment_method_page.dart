import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
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

  static const _icons = ['💳', '💵', '🏦', '📱', '💰', '🪙', '🏧', '💴', '🪪'];

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

  void _showAddDialog() => _showPaymentMethodDialog(null);

  void _showEditDialog(PaymentMethod method) => _showPaymentMethodDialog(method);

  void _showPaymentMethodDialog(PaymentMethod? existing) {
    if (_userId.isEmpty) return;
    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.icon ?? PaymentMethodType.other.defaultIcon;
    PaymentMethodType selectedType = existing?.type ?? PaymentMethodType.other;
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
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
                  items: PaymentMethodType.values.map((type) {
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
                const SizedBox(height: 16),
                const Text('Ícono:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _icons.map((icon) {
                    return GestureDetector(
                      onTap: () => setStateDialog(() => selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedIcon == icon
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(icon, style: const TextStyle(fontSize: 20)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                if (isEdit) {
                  final updated = existing.copyWith(
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    type: selectedType,
                  );
                  context.read<PaymentMethodBloc>().add(UpdatePaymentMethodEvent(updated));
                } else {
                  final method = PaymentMethod(
                    id: const Uuid().v4(),
                    userId: _userId,
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    type: selectedType,
                  );
                  context.read<PaymentMethodBloc>().add(AddPaymentMethodEvent(method));
                }
                Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Guardar' : 'Agregar'),
            ),
          ],
        ),
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
        onPressed: _showAddDialog,
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
            return ListView.builder(
              itemCount: state.paymentMethods.length,
              itemBuilder: (context, index) {
                final method = state.paymentMethods[index];
                return ListTile(
                  leading: Text(method.icon, style: const TextStyle(fontSize: 24)),
                  title: Text(method.name),
                  subtitle: Text(
                    method.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditDialog(method),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => context
                            .read<PaymentMethodBloc>()
                            .add(DeletePaymentMethodEvent(method.id)),
                      ),
                    ],
                  ),
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
