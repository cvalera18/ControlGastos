import 'package:control_gastos/features/incomes/data/models/income_model.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';

class IncomeMapper {
  static Income toDomain(IncomeModel model) => Income(
        id: model.id,
        userId: model.userId,
        amount: model.amount,
        description: model.description,
        paymentMethodId: model.paymentMethodId,
        paymentMethodName: model.paymentMethodName,
        date: model.date,
        notes: model.notes,
        groupId: model.groupId,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
      );

  static IncomeModel toModel(Income income) => IncomeModel(
        id: income.id,
        userId: income.userId,
        amount: income.amount,
        description: income.description,
        paymentMethodId: income.paymentMethodId,
        paymentMethodName: income.paymentMethodName,
        date: income.date,
        notes: income.notes,
        groupId: income.groupId,
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
      );
}
