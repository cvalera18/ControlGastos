import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_category_bloc.dart';

class GroupCategoriesPage extends StatefulWidget {
  final String groupId;
  final String userId;

  const GroupCategoriesPage({
    super.key,
    required this.groupId,
    required this.userId,
  });

  @override
  State<GroupCategoriesPage> createState() => _GroupCategoriesPageState();
}

class _GroupCategoriesPageState extends State<GroupCategoriesPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    context.read<GroupCategoryBloc>().add(FetchGroupCategoriesEvent(widget.groupId));
  }

  void _showDialog({GroupCategory? editing}) {
    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    String icon = editing?.icon ?? '📦';
    int color = editing?.color ?? 0xFF757575;

    final colorOptions = [
      0xFFE53935, 0xFF1E88E5, 0xFF8E24AA, 0xFF43A047,
      0xFFFF8F00, 0xFF00ACC1, 0xFF3949AB, 0xFF757575,
      0xFFE91E63, 0xFF00BCD4, 0xFF4CAF50, 0xFFFF5722,
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(editing == null ? 'Nueva categoría' : 'Editar categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Text('Ícono', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ej: 🍔',
                    prefixText: '$icon  ',
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty) setStateDialog(() => icon = v.trim());
                  },
                ),
                const SizedBox(height: 16),
                Text('Color', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colorOptions.map((c) {
                    final selected = color == c;
                    return GestureDetector(
                      onTap: () => setStateDialog(() => color = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                if (editing == null) {
                  context.read<GroupCategoryBloc>().add(
                        AddGroupCategoryEvent(
                          GroupCategory(
                            id: const Uuid().v4(),
                            groupId: widget.groupId,
                            name: name,
                            icon: icon,
                            color: color,
                            createdBy: widget.userId,
                          ),
                        ),
                      );
                } else {
                  context.read<GroupCategoryBloc>().add(
                        UpdateGroupCategoryEvent(
                          editing.copyWith(name: name, icon: icon, color: color),
                        ),
                      );
                }
                Navigator.pop(ctx);
              },
              child: const Text('Guardar'),
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
        title: const Text('Categorías del grupo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDialog(),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<GroupCategoryBloc, GroupCategoryState>(
        listener: (context, state) {
          if (state is GroupCategoryOperationSuccess) {
            context.showSnackBar(state.message);
            _fetch();
          } else if (state is GroupCategoryError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is GroupCategoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupCategoryLoaded) {
            if (state.categories.isEmpty) {
              return const Center(
                child: Text('Sin categorías. Toca + para crear una.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final cat = state.categories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(cat.color),
                    child: Text(cat.icon, style: const TextStyle(fontSize: 18)),
                  ),
                  title: Text(cat.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showDialog(editing: cat),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () => showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Eliminar categoría'),
                            content: Text('¿Eliminar "${cat.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  foregroundColor: Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  context.read<GroupCategoryBloc>().add(
                                        DeleteGroupCategoryEvent(
                                          groupId: cat.groupId,
                                          categoryId: cat.id,
                                        ),
                                      );
                                },
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
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
