class CategoryModel {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final int color;
  final bool isDefault;

  const CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, {String? id}) => CategoryModel(
        id: id ?? json['id'] as String,
        userId: json['userId'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        color: json['color'] as int,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'color': color,
        'isDefault': isDefault,
      };
}
