part of 'income_bloc.dart';

abstract class IncomeState extends Equatable {
  const IncomeState();
  @override
  List<Object?> get props => [];
}

class IncomeInitial extends IncomeState {
  const IncomeInitial();
}

class IncomeLoading extends IncomeState {
  const IncomeLoading();
}

class IncomeLoaded extends IncomeState {
  final List<Income> incomes;
  const IncomeLoaded(this.incomes);
  @override
  List<Object?> get props => [incomes];
}

class IncomeOperationSuccess extends IncomeState {
  final String message;
  const IncomeOperationSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class IncomeError extends IncomeState {
  final String message;
  const IncomeError(this.message);
  @override
  List<Object?> get props => [message];
}
