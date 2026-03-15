import 'package:control_gastos/features/expenses/data/models/expense_model.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';

class ExpenseMapper {
  ExpenseMapper._();

  static Expense toDomain(ExpenseModel model) => Expense(
        id: model.id,
        userId: model.userId,
        amount: model.amount,
        description: model.description,
        categoryId: model.categoryId,
        categoryName: model.categoryName,
        paymentMethodId: model.paymentMethodId,
        paymentMethodName: model.paymentMethodName,
        date: model.date,
        notes: model.notes,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  static ExpenseModel toModel(Expense entity) => ExpenseModel(
        id: entity.id,
        userId: entity.userId,
        amount: entity.amount,
        description: entity.description,
        categoryId: entity.categoryId,
        categoryName: entity.categoryName,
        paymentMethodId: entity.paymentMethodId,
        paymentMethodName: entity.paymentMethodName,
        date: entity.date,
        notes: entity.notes,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
