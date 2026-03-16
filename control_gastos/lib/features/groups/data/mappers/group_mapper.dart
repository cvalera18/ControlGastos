import 'package:control_gastos/features/groups/data/models/group_model.dart';
import 'package:control_gastos/features/groups/domain/entities/group.dart';

class GroupMapper {
  GroupMapper._();

  static Group toDomain(GroupModel model) => Group(
        id: model.id,
        name: model.name,
        createdBy: model.createdBy,
        members: model.members,
        inviteCode: model.inviteCode,
        createdAt: model.createdAt,
      );

  static GroupModel toModel(Group entity) => GroupModel(
        id: entity.id,
        name: entity.name,
        createdBy: entity.createdBy,
        members: entity.members,
        inviteCode: entity.inviteCode,
        createdAt: entity.createdAt,
      );
}
