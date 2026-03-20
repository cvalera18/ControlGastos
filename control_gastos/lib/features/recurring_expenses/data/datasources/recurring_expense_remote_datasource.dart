import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/features/recurring_expenses/data/models/recurring_expense_model.dart';

abstract class RecurringExpenseRemoteDataSource {
  Future<List<RecurringExpenseModel>> getRecurringExpenses(String userId);
  Future<void> addRecurringExpense(RecurringExpenseModel model);
  Future<void> updateRecurringExpense(RecurringExpenseModel model);
  Future<void> deleteRecurringExpense(String id);
}

class RecurringExpenseRemoteDataSourceImpl
    implements RecurringExpenseRemoteDataSource {
  final FirebaseFirestore firestore;

  RecurringExpenseRemoteDataSourceImpl({required this.firestore});

  CollectionReference get _col => firestore.collection('recurring_expenses');

  @override
  Future<List<RecurringExpenseModel>> getRecurringExpenses(String userId) async {
    final snapshot =
        await _col.where('userId', isEqualTo: userId).get();
    return snapshot.docs
        .map((doc) => RecurringExpenseModel.fromJson(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }

  @override
  Future<void> addRecurringExpense(RecurringExpenseModel model) async {
    await _col.doc(model.id).set(model.toJson());
  }

  @override
  Future<void> updateRecurringExpense(RecurringExpenseModel model) async {
    await _col.doc(model.id).update(model.toJson());
  }

  @override
  Future<void> deleteRecurringExpense(String id) async {
    await _col.doc(id).delete();
  }
}
