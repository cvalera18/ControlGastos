import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/categories/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories(String userId);
  Future<void> saveCategories(List<CategoryModel> categories);
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final SharedPreferences _prefs;

  CategoryLocalDataSourceImpl(this._prefs);

  String _key(String userId) => 'categories_$userId';

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final jsonStr = _prefs.getString(_key(userId));
      if (jsonStr == null) return [];
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async {
    if (categories.isEmpty) return;
    try {
      final userId = categories.first.userId;
      final existing = await getCategories(userId);
      final Map<String, CategoryModel> map = {for (final c in existing) c.id: c};
      for (final c in categories) {
        map[c.id] = c;
      }
      await _prefs.setString(_key(userId), jsonEncode(map.values.map((c) => c.toJson()).toList()));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    await saveCategories([category]);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      final allKeys = _prefs.getKeys().where((k) => k.startsWith('categories_'));
      for (final key in allKeys) {
        final jsonStr = _prefs.getString(key);
        if (jsonStr == null) continue;
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        final filtered = list.where((e) => (e as Map<String, dynamic>)['id'] != categoryId).toList();
        if (filtered.length != list.length) {
          await _prefs.setString(key, jsonEncode(filtered));
          return;
        }
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
