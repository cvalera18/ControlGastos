import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/categories/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String userId);
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Stream<List<CategoryModel>> watchCategories(String userId);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  CategoryRemoteDataSourceImpl(this._firestore);

  CollectionReference get _col => _firestore.collection(AppConstants.categoriesCollection);

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final snap = await _col.where('userId', isEqualTo: userId).get();
      return snap.docs.map((d) => CategoryModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    try { await _col.doc(category.id).set(category.toJson()); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    try { await _col.doc(category.id).update(category.toJson()); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try { await _col.doc(categoryId).delete(); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Stream<List<CategoryModel>> watchCategories(String userId) {
    return _col.where('userId', isEqualTo: userId).snapshots().map(
          (s) => s.docs.map((d) => CategoryModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList(),
        );
  }
}
