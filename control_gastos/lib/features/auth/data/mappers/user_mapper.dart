import 'package:control_gastos/features/auth/data/models/user_model.dart';
import 'package:control_gastos/features/auth/domain/entities/user.dart';

class UserMapper {
  UserMapper._();

  static User toDomain(UserModel model) {
    return User(
      id: model.id,
      email: model.email,
      name: model.name,
      photoUrl: model.photoUrl,
      createdAt: model.createdAt,
    );
  }

  static UserModel toModel(User entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }
}
