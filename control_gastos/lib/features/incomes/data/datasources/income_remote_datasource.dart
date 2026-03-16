import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/incomes/data/models/income_model.dart';

abstract class IncomeRemoteDataSource {
  Future<List<IncomeModel>> getIncomes(String userId);
  Future<List<IncomeModel>> getGroupIncomes(String groupId);
  Future<void> addIncome(IncomeModel income);
  Future<void> updateIncome(IncomeModel income);
  Future<void> deleteIncome(String incomeId);
}

class IncomeRemoteDataSourceImpl implements IncomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  IncomeRemoteDataSourceImpl(this._firestore);

  CollectionReference get _col =>
      _firestore.collection(AppConstants.incomesCollection);

  @override
  Future<List<IncomeModel>> getIncomes(String userId) async {
    try {
      final snap = await _col
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      return snap.docs
          .map((d) =>
              IncomeModel.fromJson(d.data() as Map<String, dynamic>, id: d.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<IncomeModel>> getGroupIncomes(String groupId) async {
    try {
      final snap = await _col
          .where('groupId', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();
      return snap.docs
          .map((d) =>
              IncomeModel.fromJson(d.data() as Map<String, dynamic>, id: d.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addIncome(IncomeModel income) async {
    try {
      await _col.doc(income.id).set(income.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateIncome(IncomeModel income) async {
    try {
      await _col.doc(income.id).update(income.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteIncome(String incomeId) async {
    try {
      await _col.doc(incomeId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
