import 'package:equatable/equatable.dart';

class GroupCategory extends Equatable {
  final String id;
  final String groupId;
  final String name;
  final String icon;
  final int color;
  final String createdBy;

  const GroupCategory({
    required this.id,
    required this.groupId,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdBy,
  });

  GroupCategory copyWith({
    String? id,
    String? groupId,
    String? name,
    String? icon,
    int? color,
    String? createdBy,
  }) {
    return GroupCategory(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  List<Object> get props => [id, groupId, name, icon, color, createdBy];
}
