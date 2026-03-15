import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/categories/domain/repositories/category_repository.dart';

class DeleteCategoryUseCase {
  final CategoryRepository repository;

  const DeleteCategoryUseCase(this.repository);

  Future<Either<Failure, void>> call(String categoryId) {
    return repository.deleteCategory(categoryId);
  }
}
