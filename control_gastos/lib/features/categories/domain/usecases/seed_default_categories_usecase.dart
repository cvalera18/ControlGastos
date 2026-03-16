import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/domain/repositories/category_repository.dart';

class SeedDefaultCategoriesUseCase {
  final CategoryRepository repository;

  const SeedDefaultCategoriesUseCase(this.repository);

  Future<void> call(String userId) async {
    for (final cat in AppConstants.defaultCategories) {
      final category = Category(
        id: const Uuid().v4(),
        userId: userId,
        name: cat['name'] as String,
        icon: cat['icon'] as String,
        color: cat['color'] as int,
        isDefault: true,
      );
      await repository.addCategory(category);
    }
  }
}
