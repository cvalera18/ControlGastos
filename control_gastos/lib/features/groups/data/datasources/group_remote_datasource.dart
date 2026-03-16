import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/groups/data/models/group_expense_model.dart';
import 'package:control_gastos/features/groups/data/models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups(String userId);
  Future<void> createGroup(GroupModel group);
  Future<GroupModel?> getGroupByInviteCode(String code);
  Future<void> joinGroup(String groupId, String userId);
  Future<List<GroupExpenseModel>> getGroupExpenses(String groupId);
  Future<void> addGroupExpense(GroupExpenseModel expense);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final FirebaseFirestore _firestore;

  GroupRemoteDataSourceImpl(this._firestore);

  CollectionReference get _groups => _firestore.collection('groups');
  CollectionReference get _groupExpenses => _firestore.collection('group_expenses');

  @override
  Future<List<GroupModel>> getGroups(String userId) async {
    try {
      final snap = await _groups.where('members', arrayContains: userId).get();
      return snap.docs
          .map((d) => GroupModel.fromJson(d.data() as Map<String, dynamic>, id: d.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createGroup(GroupModel group) async {
    try {
      await _groups.doc(group.id).set(group.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<GroupModel?> getGroupByInviteCode(String code) async {
    try {
      final snap = await _groups.where('inviteCode', isEqualTo: code).get();
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return GroupModel.fromJson(doc.data() as Map<String, dynamic>, id: doc.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> joinGroup(String groupId, String userId) async {
    try {
      await _groups.doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<GroupExpenseModel>> getGroupExpenses(String groupId) async {
    try {
      final snap = await _groupExpenses
          .where('groupId', isEqualTo: groupId)
          .orderBy('date', descending: true)
          .get();
      return snap.docs
          .map((d) => GroupExpenseModel.fromJson(d.data() as Map<String, dynamic>, id: d.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addGroupExpense(GroupExpenseModel expense) async {
    try {
      await _groupExpenses.doc(expense.id).set(expense.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
