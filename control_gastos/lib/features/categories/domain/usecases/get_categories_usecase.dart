import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/domain/repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<Either<Failure, List<Category>>> call(String userId) {
    return repository.getCategories(userId);
  }
}
