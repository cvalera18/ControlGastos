import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/presentation/bloc/category_bloc.dart';

class CategoryManagePage extends StatefulWidget {
  const CategoryManagePage({super.key});

  @override
  State<CategoryManagePage> createState() => _CategoryManagePageState();
}

class _CategoryManagePageState extends State<CategoryManagePage> {
  late final String _userId;

  static const _icons = ['🍔', '🚗', '🏠', '💊', '🎮', '👗', '📚', '✈️', '💡', '📦'];

  List<int> get _colors => [
        Colors.blue.toARGB32(),
        Colors.red.toARGB32(),
        Colors.green.toARGB32(),
        Colors.orange.toARGB32(),
        Colors.purple.toARGB32(),
        Colors.teal.toARGB32(),
        Colors.pink.toARGB32(),
        Colors.amber.toARGB32(),
      ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _userId = authState is AuthAuthenticated ? authState.user.id : '';
    _fetch();
  }

  void _fetch() {
    if (_userId.isEmpty) return;
    context.read<CategoryBloc>().add(FetchCategoriesEvent(_userId));
  }

  void _showAddDialog() => _showCategoryDialog(null);

  void _showEditDialog(Category category) => _showCategoryDialog(category);

  void _showCategoryDialog(Category? existing) {
    if (_userId.isEmpty) return;
    final userId = _userId;

    final nameController = TextEditingController(text: existing?.name ?? '');
    String selectedIcon = existing?.icon ?? '📦';
    int selectedColor = existing?.color ?? Colors.blue.toARGB32();
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(isEdit ? 'Editar categoría' : 'Nueva categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 12),
              const Text('Ícono:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _icons.map((icon) {
                  return GestureDetector(
                    onTap: () => setStateDialog(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIcon == icon ? Colors.blue : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 20)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Color:', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((color) {
                  return GestureDetector(
                    onTap: () => setStateDialog(() => selectedColor = color),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
                    color: selectedColor,
                  );
                  context.read<CategoryBloc>().add(UpdateCategoryEvent(updated));
                } else {
                  final category = Category(
                    id: const Uuid().v4(),
                    userId: userId,
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                  );
                  context.read<CategoryBloc>().add(AddCategoryEvent(category));
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
        title: const Text('Categorías'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
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
          if (state is CategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Sin categorías aún', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text('Toca + para agregar tu primera categoría',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(category.color),
                    child: Text(category.icon),
                  ),
                  title: Text(category.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showEditDialog(category),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => context
                            .read<CategoryBloc>()
                            .add(DeleteCategoryEvent(category.id)),
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
