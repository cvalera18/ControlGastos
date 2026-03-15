import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
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

  void _showAddDialog() {
    if (_userId.isEmpty) return;
    final nameController = TextEditingController();
    String selectedIcon = '💳';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nuevo método de pago'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final method = PaymentMethod(
                id: const Uuid().v4(),
                userId: _userId,
                name: nameController.text.trim(),
                icon: selectedIcon,
              );
              context.read<PaymentMethodBloc>().add(AddPaymentMethodEvent(method));
              Navigator.pop(ctx);
            },
            child: const Text('Agregar'),
          ),
        ],
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
          onPressed: () => GoRouter.of(context).go('/home'),
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
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => context
                        .read<PaymentMethodBloc>()
                        .add(DeletePaymentMethodEvent(method.id)),
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
