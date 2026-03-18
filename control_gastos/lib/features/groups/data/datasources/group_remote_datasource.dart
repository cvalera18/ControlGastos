import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/groups/data/models/group_category_model.dart';
import 'package:control_gastos/features/groups/data/models/group_expense_model.dart';
import 'package:control_gastos/features/groups/data/models/group_model.dart';

abstract class GroupRemoteDataSource {
  Future<List<GroupModel>> getGroups(String userId);
  Future<void> createGroup(GroupModel group);
  Future<GroupModel?> getGroupByInviteCode(String code);
  Future<void> joinGroup(String groupId, String userId);
  Future<List<GroupExpenseModel>> getGroupExpenses(String groupId);
  Future<void> addGroupExpense(GroupExpenseModel expense);
  Future<void> updateGroupExpense(GroupExpenseModel expense);
  Future<void> deleteGroupExpense(String expenseId);
  Future<void> deleteGroup(String groupId);
  // Group categories
  Future<List<GroupCategoryModel>> getGroupCategories(String groupId);
  Future<void> addGroupCategory(GroupCategoryModel category);
  Future<void> updateGroupCategory(GroupCategoryModel category);
  Future<void> deleteGroupCategory(String groupId, String categoryId);
}

class GroupRemoteDataSourceImpl implements GroupRemoteDataSource {
  final FirebaseFirestore _firestore;

  GroupRemoteDataSourceImpl(this._firestore);

  CollectionReference get _groups => _firestore.collection('groups');
  CollectionReference get _groupExpenses => _firestore.collection('group_expenses');

  CollectionReference _groupCategories(String groupId) =>
      _groups.doc(groupId).collection('categories');

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

  @override
  Future<void> updateGroupExpense(GroupExpenseModel expense) async {
    try {
      await _groupExpenses.doc(expense.id).update(expense.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteGroupExpense(String expenseId) async {
    try {
      await _groupExpenses.doc(expenseId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteGroup(String groupId) async {
    try {
      await _groups.doc(groupId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<GroupCategoryModel>> getGroupCategories(String groupId) async {
    try {
      final snap = await _groupCategories(groupId).orderBy('name').get();
      return snap.docs
          .map((d) => GroupCategoryModel.fromJson(d.data() as Map<String, dynamic>, id: d.id))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addGroupCategory(GroupCategoryModel category) async {
    try {
      await _groupCategories(category.groupId).doc(category.id).set(category.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateGroupCategory(GroupCategoryModel category) async {
    try {
      await _groupCategories(category.groupId).doc(category.id).update(category.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteGroupCategory(String groupId, String categoryId) async {
    try {
      await _groupCategories(groupId).doc(categoryId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
