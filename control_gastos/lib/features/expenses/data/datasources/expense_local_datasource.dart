import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/expenses/data/models/expense_model.dart';

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<void> saveExpenses(List<ExpenseModel> expenses);
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Future<void> clearExpenses(String userId);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  final SharedPreferences _prefs;

  ExpenseLocalDataSourceImpl(this._prefs);

  String _key(String userId) => 'expenses_$userId';

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      final jsonStr = _prefs.getString(_key(userId));
      if (jsonStr == null) return [];
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveExpenses(List<ExpenseModel> expenses) async {
    if (expenses.isEmpty) return;
    try {
      final userId = expenses.first.userId;
      final existing = await getExpenses(userId);
      final Map<String, ExpenseModel> map = {for (final e in existing) e.id: e};
      for (final e in expenses) {
        map[e.id] = e;
      }
      await _prefs.setString(
        _key(userId),
        jsonEncode(map.values.map(_toStorableJson).toList()),
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    await saveExpenses([expense]);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      final allKeys = _prefs.getKeys().where((k) => k.startsWith('expenses_'));
      for (final key in allKeys) {
        final jsonStr = _prefs.getString(key);
        if (jsonStr == null) continue;
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        final filtered = list.where((e) => (e as Map<String, dynamic>)['id'] != expenseId).toList();
        if (filtered.length != list.length) {
          await _prefs.setString(key, jsonEncode(filtered));
          return;
        }
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> clearExpenses(String userId) async {
    try {
      await _prefs.remove(_key(userId));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  Map<String, dynamic> _toStorableJson(ExpenseModel model) => {
        'id': model.id,
        'userId': model.userId,
        'amount': model.amount,
        'description': model.description,
        'categoryId': model.categoryId,
        'categoryName': model.categoryName,
        'paymentMethodId': model.paymentMethodId,
        'paymentMethodName': model.paymentMethodName,
        'date': model.date.toIso8601String(),
        'notes': model.notes,
        'createdAt': model.createdAt.toIso8601String(),
        'updatedAt': model.updatedAt.toIso8601String(),
      };
}
