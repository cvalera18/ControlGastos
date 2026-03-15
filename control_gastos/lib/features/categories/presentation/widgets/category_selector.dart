import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/core/utils/validators.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';

class CategoryManagePage extends StatefulWidget {
  const CategoryManagePage({super.key});

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<CategoryBloc>().add(FetchCategoriesEvent(authState.user.id));
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva categoría'),
        content: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre'),
          validator: Validators.name,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final authState = context.read<AuthBloc>().state;
              if (authState is! AuthAuthenticated) return;
              final category = Category(
                id: const Uuid().v4(),
                userId: authState.user.id,
                name: nameController.text.trim(),
                icon: '📦',
                color: 0xFF2196F3,
              );
              context.read<CategoryBloc>().add(AddCategoryEvent(category));
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
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<CategoryBloc, CategoryState>(
        listener: (context, state) {
          if (state is CategoryOperationSuccess) {
            context.showSnackBar(state.message);
            _fetch();
          } else if (state is CategoryError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is CategoryLoading) return const Center(child: CircularProgressIndicator());
          if (state is CategoryLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(cat.color),
                    child: Text(cat.icon),
                  ),
                  title: Text(cat.name),
                  trailing: cat.isDefault
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context.read<CategoryBloc>().add(DeleteCategoryEvent(cat.id)),
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
