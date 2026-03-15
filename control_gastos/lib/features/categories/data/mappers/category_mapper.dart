import 'package:control_gastos/features/categories/data/models/category_model.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';

class CategoryMapper {
  CategoryMapper._();

  static Category toDomain(CategoryModel model) => Category(
        id: model.id,
        userId: model.userId,
        name: model.name,
        icon: model.icon,
        color: model.color,
        isDefault: model.isDefault,
      );

  static CategoryModel toModel(Category entity) => CategoryModel(
        id: entity.id,
        userId: entity.userId,
        name: entity.name,
        icon: entity.icon,
        color: entity.color,
        isDefault: entity.isDefault,
      );
}
