import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members;
  final String inviteCode;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
    required this.inviteCode,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json, {String? id}) => GroupModel(
        id: id ?? json['id'] as String,
        name: json['name'] as String,
        createdBy: json['createdBy'] as String,
        members: List<String>.from(json['members'] as List),
        inviteCode: json['inviteCode'] as String,
        createdAt: (json['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdBy': createdBy,
        'members': members,
        'inviteCode': inviteCode,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
