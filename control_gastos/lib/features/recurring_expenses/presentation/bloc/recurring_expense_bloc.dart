import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:control_gastos/features/recurring_expenses/domain/usecases/add_recurring_expense_usecase.dart';
import 'package:control_gastos/features/recurring_expenses/domain/usecases/delete_recurring_expense_usecase.dart';
import 'package:control_gastos/features/recurring_expenses/domain/usecases/generate_due_expenses_usecase.dart';
import 'package:control_gastos/features/recurring_expenses/domain/usecases/get_recurring_expenses_by_payment_method_usecase.dart';
import 'package:control_gastos/features/recurring_expenses/domain/usecases/get_recurring_expenses_usecase.dart';
import 'package:control_gastos/features/recurring_expenses/domain/usecases/update_recurring_expense_usecase.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_event.dart';
import 'package:control_gastos/features/recurring_expenses/presentation/bloc/recurring_expense_state.dart';

class RecurringExpenseBloc
    extends Bloc<RecurringExpenseEvent, RecurringExpenseState> {
  final GetRecurringExpensesUseCase getRecurringExpensesUseCase;
  final GetRecurringExpensesByPaymentMethodUseCase getByPaymentMethodUseCase;
  final AddRecurringExpenseUseCase addRecurringExpenseUseCase;
  final UpdateRecurringExpenseUseCase updateRecurringExpenseUseCase;
  final DeleteRecurringExpenseUseCase deleteRecurringExpenseUseCase;
  final GenerateDueExpensesUseCase generateDueExpensesUseCase;

  RecurringExpenseBloc({
    required this.getRecurringExpensesUseCase,
    required this.getByPaymentMethodUseCase,
    required this.addRecurringExpenseUseCase,
    required this.updateRecurringExpenseUseCase,
    required this.deleteRecurringExpenseUseCase,
    required this.generateDueExpensesUseCase,
  }) : super(const RecurringExpenseInitial()) {
    on<FetchRecurringExpensesEvent>(_onFetch);
    on<FetchRecurringExpensesByMethodEvent>(_onFetchByMethod);
    on<AddRecurringExpenseEvent>(_onAdd);
    on<UpdateRecurringExpenseEvent>(_onUpdate);
    on<DeleteRecurringExpenseEvent>(_onDelete);
    on<GenerateDueExpensesEvent>(_onGenerate);
  }

  Future<void> _onFetch(
    FetchRecurringExpensesEvent event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(const RecurringExpenseLoading());
    final result = await getRecurringExpensesUseCase(event.userId);
    result.fold(
      (failure) => emit(RecurringExpenseError(failure.message)),
      (expenses) => emit(RecurringExpenseLoaded(expenses)),
    );
  }

  Future<void> _onFetchByMethod(
    FetchRecurringExpensesByMethodEvent event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(const RecurringExpenseLoading());
    final result = await getByPaymentMethodUseCase(event.userId, event.paymentMethodId);
    result.fold(
      (failure) => emit(RecurringExpenseError(failure.message)),
      (expenses) => emit(RecurringExpenseLoaded(expenses)),
    );
  }

  Future<void> _onAdd(
    AddRecurringExpenseEvent event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(const RecurringExpenseLoading());
    final result = await addRecurringExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(RecurringExpenseError(failure.message)),
      (_) => emit(const RecurringExpenseOperationSuccess('Recurrente agregado')),
    );
  }

  Future<void> _onUpdate(
    UpdateRecurringExpenseEvent event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(const RecurringExpenseLoading());
    final result = await updateRecurringExpenseUseCase(event.expense);
    result.fold(
      (failure) => emit(RecurringExpenseError(failure.message)),
      (_) =>
          emit(const RecurringExpenseOperationSuccess('Recurrente actualizado')),
    );
  }

  Future<void> _onDelete(
    DeleteRecurringExpenseEvent event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    emit(const RecurringExpenseLoading());
    final result = await deleteRecurringExpenseUseCase(event.id);
    result.fold(
      (failure) => emit(RecurringExpenseError(failure.message)),
      (_) =>
          emit(const RecurringExpenseOperationSuccess('Recurrente eliminado')),
    );
  }

  Future<void> _onGenerate(
    GenerateDueExpensesEvent event,
    Emitter<RecurringExpenseState> emit,
  ) async {
    final result = await generateDueExpensesUseCase(event.userId);
    result.fold(
      (failure) => emit(RecurringExpenseError(failure.message)),
      (count) => emit(RecurringExpenseGenerationDone(count)),
    );
  }
}
