import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/expenses/domain/entities/expense.dart';
import 'package:control_gastos/features/expenses/domain/usecases/add_expense_usecase.dart';
import 'package:control_gastos/features/expenses/domain/usecases/delete_expense_usecase.dart';
import 'package:control_gastos/features/expenses/domain/usecases/get_expenses_usecase.dart';

part 'expense_event.dart';
part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final AddExpenseUseCase addExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  StreamSubscription<List<Expense>>? _expenseSubscription;

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(const ExpenseInitial()) {
    on<FetchExpensesEvent>(_onFetchExpenses);
    on<AddExpenseEvent>(_onAddExpense);
    on<UpdateExpenseEvent>(_onUpdateExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
  }

  Future<void> _onFetchExpenses(
    FetchExpensesEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await getExpensesUseCase(event.userId);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  Future<void> _onAddExpense(
    AddExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await addExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(const ExpenseOperationSuccess('Gasto agregado correctamente')),
    );
  }

  Future<void> _onUpdateExpense(
    UpdateExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await addExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(const ExpenseOperationSuccess('Gasto actualizado correctamente')),
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ExpenseState> emit,
  ) async {
    emit(const ExpenseLoading());
    final result = await deleteExpenseUseCase(event.expenseId);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (_) => emit(const ExpenseOperationSuccess('Gasto eliminado correctamente')),
    );
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
