import 'package:control_gastos/features/groups/data/models/group_expense_model.dart';
import 'package:control_gastos/features/groups/domain/entities/group_expense.dart';

class GroupExpenseMapper {
  GroupExpenseMapper._();

  static GroupExpense toDomain(GroupExpenseModel model) => GroupExpense(
        id: model.id,
        groupId: model.groupId,
        userId: model.userId,
        userName: model.userName,
        amount: model.amount,
        description: model.description,
        categoryId: model.categoryId,
        categoryName: model.categoryName,
        categoryIcon: model.categoryIcon,
        categoryColor: model.categoryColor,
        paymentMethodId: model.paymentMethodId,
        paymentMethodName: model.paymentMethodName,
        date: model.date,
        notes: model.notes,
        createdAt: model.createdAt,
      );

  static GroupExpenseModel toModel(GroupExpense entity) => GroupExpenseModel(
        id: entity.id,
        groupId: entity.groupId,
        userId: entity.userId,
        userName: entity.userName,
        amount: entity.amount,
        description: entity.description,
        categoryId: entity.categoryId,
        categoryName: entity.categoryName,
        categoryIcon: entity.categoryIcon,
        categoryColor: entity.categoryColor,
        paymentMethodId: entity.paymentMethodId,
        paymentMethodName: entity.paymentMethodName,
        date: entity.date,
        notes: entity.notes,
        createdAt: entity.createdAt,
      );
}
