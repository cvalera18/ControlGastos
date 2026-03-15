import 'package:dartz/dartz.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/categories/data/datasources/category_local_datasource.dart';
import 'package:control_gastos/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:control_gastos/features/categories/data/mappers/category_mapper.dart';
import 'package:control_gastos/features/categories/domain/entities/category.dart';
import 'package:control_gastos/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remote;
  final CategoryLocalDataSource local;

  CategoryRepositoryImpl({required this.remote, required this.local});

  @override
  Future<Either<Failure, List<Category>>> getCategories(String userId) async {
    try {
      final models = await remote.getCategories(userId);
      await local.saveCategories(models);
      return Right(models.map(CategoryMapper.toDomain).toList());
    } on ServerException {
      try {
        final cached = await local.getCategories(userId);
        return Right(cached.map(CategoryMapper.toDomain).toList());
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    try {
      final model = CategoryMapper.toModel(category);
      await remote.addCategory(model);
      await local.saveCategory(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
    try {
      final model = CategoryMapper.toModel(category);
      await remote.updateCategory(model);
      await local.saveCategory(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String categoryId) async {
    try {
      await remote.deleteCategory(categoryId);
      await local.deleteCategory(categoryId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Stream<List<Category>> watchCategories(String userId) {
    return remote.watchCategories(userId).map((models) => models.map(CategoryMapper.toDomain).toList());
  }
}
