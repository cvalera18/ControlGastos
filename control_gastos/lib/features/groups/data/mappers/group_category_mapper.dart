import 'package:control_gastos/features/groups/data/models/group_category_model.dart';
import 'package:control_gastos/features/groups/domain/entities/group_category.dart';

class GroupCategoryMapper {
  GroupCategoryMapper._();

  static GroupCategory toDomain(GroupCategoryModel model) => GroupCategory(
        id: model.id,
        groupId: model.groupId,
        name: model.name,
        icon: model.icon,
        color: model.color,
        createdBy: model.createdBy,
      );

  static GroupCategoryModel toModel(GroupCategory entity) => GroupCategoryModel(
        id: entity.id,
        groupId: entity.groupId,
        name: entity.name,
        icon: entity.icon,
        color: entity.color,
        createdBy: entity.createdBy,
      );
}
