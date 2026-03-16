import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/extensions/context_extensions.dart';
import 'package:control_gastos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';
import 'package:control_gastos/features/groups/presentation/bloc/group_bloc.dart';

class GroupListPage extends StatefulWidget {
  const GroupListPage({super.key});

  @override
  State<GroupListPage> createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
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
    context.read<GroupBloc>().add(FetchGroupsEvent(_userId));
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  void _showOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Crear grupo'),
              onTap: () {
                Navigator.pop(ctx);
                _showCreateGroupDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Unirse a grupo'),
              onTap: () {
                Navigator.pop(ctx);
                _showJoinGroupDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGroupDialog() {
    if (_userId.isEmpty) return;
    final userId = _userId;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Crear grupo'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nombre del grupo'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              final group = Group(
                id: const Uuid().v4(),
                name: nameController.text.trim(),
                createdBy: userId,
                members: [userId],
                inviteCode: _generateInviteCode(),
                createdAt: DateTime.now(),
              );
              context.read<GroupBloc>().add(CreateGroupEvent(group));
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showJoinGroupDialog() {
    if (_userId.isEmpty) return;
    final userId = _userId;
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unirse a grupo'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(labelText: 'Código de invitación'),
          textCapitalization: TextCapitalization.characters,
          onChanged: (v) {
            final upper = v.toUpperCase();
            if (v != upper) {
              codeController.value = codeController.value.copyWith(
                text: upper,
                selection: TextSelection.collapsed(offset: upper.length),
              );
            }
          },
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.trim().isEmpty) return;
              context.read<GroupBloc>().add(JoinGroupEvent(
                    inviteCode: codeController.text.trim().toUpperCase(),
                    userId: userId,
                  ));
              Navigator.pop(ctx);
            },
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grupos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOptions,
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<GroupBloc, GroupState>(
        listener: (context, state) {
          if (state is GroupOperationSuccess) {
            context.showSnackBar(state.message);
            _fetch();
          } else if (state is GroupError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is GroupLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GroupsLoaded) {
            if (state.groups.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Sin grupos aún', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text(
                      'Toca + para crear o unirte a un grupo',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                final isCreator = group.createdBy == _userId;
                final card = Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.group)),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${group.members.length} miembro${group.members.length == 1 ? '' : 's'} · Código: ${group.inviteCode}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Copiar código',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: group.inviteCode));
                            context.showSnackBar('Código ${group.inviteCode} copiado');
                          },
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
                      ],
                    ),
                    onTap: () async {
                      await GoRouter.of(context).push('/groups/${group.id}', extra: group.name);
                      _fetch();
                    },
                  ),
                );

                if (!isCreator) return card;

                return Dismissible(
                  key: ValueKey(group.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Eliminar grupo'),
                      content: Text(
                        '¿Eliminar el grupo "${group.name}"? Se eliminarán todos sus datos.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.error,
                            foregroundColor: Theme.of(context).colorScheme.onError,
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) {
                    context.read<GroupBloc>().add(DeleteGroupEvent(group.id));
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  child: card,
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
