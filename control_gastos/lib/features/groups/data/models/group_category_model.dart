class GroupCategoryModel {
  final String id;
  final String groupId;
  final String name;
  final String icon;
  final int color;
  final String createdBy;

  const GroupCategoryModel({
    required this.id,
    required this.groupId,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdBy,
  });

  factory GroupCategoryModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return GroupCategoryModel(
      id: id,
      groupId: json['groupId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'name': name,
        'icon': icon,
        'color': color,
        'createdBy': createdBy,
      };
}
