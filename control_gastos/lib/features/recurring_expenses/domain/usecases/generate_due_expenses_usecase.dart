import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import 'package:control_gastos/core/errors/failures.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/repositories/expense_repository.dart';
import 'package:control_gastos/features/recurring_expenses/domain/repositories/recurring_expense_repository.dart';

class GenerateDueExpensesUseCase {
  final RecurringExpenseRepository recurringRepository;
  final ExpenseRepository expenseRepository;

  const GenerateDueExpensesUseCase({
    required this.recurringRepository,
    required this.expenseRepository,
  });

  /// Generates [Expense] records for every active recurring expense that is due
  /// (nextDueDate <= today). Returns the total count of expenses generated.
  Future<Either<Failure, int>> call(String userId) async {
    final result = await recurringRepository.getRecurringExpenses(userId);

    return result.fold(
      (failure) => Left(failure),
      (recurrings) async {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        int generated = 0;

        for (final recurring in recurrings) {
          if (!recurring.isActive) continue;
          if (recurring.endDate != null &&
              recurring.endDate!.isBefore(todayDate)) {
            continue;
          }

          DateTime dueDate = DateTime(
            recurring.nextDueDate.year,
            recurring.nextDueDate.month,
            recurring.nextDueDate.day,
          );

          // Generate all missed periods up to and including today
          while (!dueDate.isAfter(todayDate)) {
            final expense = Expense(
              id: const Uuid().v4(),
              userId: recurring.userId,
              amount: recurring.amount,
              description: recurring.name,
              categoryId: recurring.categoryId,
              categoryName: recurring.categoryName,
              categoryIcon: recurring.categoryIcon,
              categoryColor: recurring.categoryColor,
              paymentMethodId: recurring.paymentMethodId,
              paymentMethodName: recurring.paymentMethodName,
              date: dueDate,
              notes: recurring.notes,
              groupId: recurring.groupId,
              createdAt: today,
              updatedAt: today,
            );

            final addResult = await expenseRepository.addExpense(expense);
            if (addResult.isLeft()) break;

            generated++;
            dueDate = recurring.computeNextDueDate(dueDate);
          }

          if (generated > 0 || dueDate != recurring.nextDueDate) {
            final updated = recurring.copyWith(
              nextDueDate: dueDate,
              lastGeneratedDate: today,
            );
            await recurringRepository.updateRecurringExpense(updated);
          }
        }

        return Right(generated);
      },
    );
  }
}
