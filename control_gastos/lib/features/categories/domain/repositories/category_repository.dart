import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories(String userId);
  Future<Either<Failure, void>> addCategory(Category category);
  Future<Either<Failure, void>> updateCategory(Category category);
  Future<Either<Failure, void>> deleteCategory(String categoryId);
  Stream<List<Category>> watchCategories(String userId);
}
