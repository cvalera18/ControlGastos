import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final int color;
  final bool isDefault;

  const Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    String? icon,
    int? color,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object> get props => [id, userId, name, icon, color, isDefault];
}
