import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/domain/repositories/category_repository.dart';

class UpdateCategoryUseCase {
  final CategoryRepository repository;

  const UpdateCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(Category category) {
    return repository.updateCategory(category);
  }
}
