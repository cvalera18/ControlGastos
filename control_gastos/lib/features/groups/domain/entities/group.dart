import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members;
  final String inviteCode;
  final DateTime createdAt;

  const Group({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.inviteCode,
    required this.createdAt,
  });

  Group copyWith({
    String? id,
    String? name,
    String? createdBy,
    List<String>? members,
    String? inviteCode,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      inviteCode: inviteCode ?? this.inviteCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object> get props => [id, name, createdBy, members, inviteCode, createdAt];
}
