import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/expenses/data/models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<List<ExpenseModel>> getExpensesByCategory({required String userId, required String categoryId});
  Future<List<ExpenseModel>> getExpensesByDateRange({required String userId, required DateTime start, required DateTime end});
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Stream<List<ExpenseModel>> watchExpenses(String userId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseFirestore _firestore;

  ExpenseRemoteDataSourceImpl(this._firestore);

  CollectionReference get _col => _firestore.collection(AppConstants.expensesCollection);

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      final snap = await _col.where('userId', isEqualTo: userId).orderBy('date', descending: true).get();
      return snap.docs.map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByCategory({required String userId, required String categoryId}) async {
    try {
      final snap = await _col.where('userId', isEqualTo: userId).where('categoryId', isEqualTo: categoryId).orderBy('date', descending: true).get();
      return snap.docs.map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ExpenseModel>> getExpensesByDateRange({required String userId, required DateTime start, required DateTime end}) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .orderBy('date', descending: true)
          .get();
      return snap.docs.map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try { await _col.doc(expense.id).set(expense.toJson()); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try { await _col.doc(expense.id).update(expense.toJson()); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try { await _col.doc(expenseId).delete(); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses(String userId) {
    return _col.where('userId', isEqualTo: userId).orderBy('date', descending: true).snapshots().map(
          (s) => s.docs.map((d) => ExpenseModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList(),
        );
  }
}
