import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/incomes/domain/entities/income.dart';
import 'package:control_gastos/features/incomes/domain/usecases/add_income_usecase.dart';
import 'package:control_gastos/features/incomes/domain/usecases/delete_income_usecase.dart';
import 'package:control_gastos/features/incomes/domain/usecases/get_group_incomes_usecase.dart';
import 'package:control_gastos/features/incomes/domain/usecases/get_incomes_usecase.dart';
import 'package:control_gastos/features/incomes/domain/usecases/update_income_usecase.dart';

part 'income_event.dart';
part 'income_state.dart';

class IncomeBloc extends Bloc<IncomeEvent, IncomeState> {
  final GetIncomesUseCase getIncomesUseCase;
  final GetGroupIncomesUseCase getGroupIncomesUseCase;
  final AddIncomeUseCase addIncomeUseCase;
  final UpdateIncomeUseCase updateIncomeUseCase;
  final DeleteIncomeUseCase deleteIncomeUseCase;

  IncomeBloc({
    required this.getIncomesUseCase,
    required this.getGroupIncomesUseCase,
    required this.addIncomeUseCase,
    required this.updateIncomeUseCase,
    required this.deleteIncomeUseCase,
  }) : super(const IncomeInitial()) {
    on<FetchIncomesEvent>(_onFetchIncomes);
    on<FetchGroupIncomesEvent>(_onFetchGroupIncomes);
    on<AddIncomeEvent>(_onAddIncome);
    on<UpdateIncomeEvent>(_onUpdateIncome);
    on<DeleteIncomeEvent>(_onDeleteIncome);
  }

  Future<void> _onFetchIncomes(
    FetchIncomesEvent event,
    Emitter<IncomeState> emit,
  ) async {
    emit(const IncomeLoading());
    final result = await getIncomesUseCase(event.userId);
    result.fold(
      (failure) => emit(IncomeError(failure.message)),
      (incomes) => emit(IncomeLoaded(incomes)),
    );
  }

  Future<void> _onFetchGroupIncomes(
    FetchGroupIncomesEvent event,
    Emitter<IncomeState> emit,
  ) async {
    emit(const IncomeLoading());
    final result = await getGroupIncomesUseCase(event.groupId);
    result.fold(
      (failure) => emit(IncomeError(failure.message)),
      (incomes) => emit(IncomeLoaded(incomes)),
    );
  }

  Future<void> _onAddIncome(
    AddIncomeEvent event,
    Emitter<IncomeState> emit,
  ) async {
    emit(const IncomeLoading());
    final result = await addIncomeUseCase(event.income);
    result.fold(
      (failure) => emit(IncomeError(failure.message)),
      (_) => emit(const IncomeOperationSuccess('Ingreso agregado correctamente')),
    );
  }

  Future<void> _onUpdateIncome(
    UpdateIncomeEvent event,
    Emitter<IncomeState> emit,
  ) async {
    emit(const IncomeLoading());
    final result = await updateIncomeUseCase(event.income);
    result.fold(
      (failure) => emit(IncomeError(failure.message)),
      (_) => emit(const IncomeOperationSuccess('Ingreso actualizado correctamente')),
    );
  }

  Future<void> _onDeleteIncome(
    DeleteIncomeEvent event,
    Emitter<IncomeState> emit,
  ) async {
    emit(const IncomeLoading());
    final result = await deleteIncomeUseCase(event.incomeId);
    result.fold(
      (failure) => emit(IncomeError(failure.message)),
      (_) => emit(const IncomeOperationSuccess('Ingreso eliminado correctamente')),
    );
  }
}
