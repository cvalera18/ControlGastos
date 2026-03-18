import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/expenses/domain/usecases/get_expenses_usecase.dart';
import 'package:control_gastos/features/incomes/domain/usecases/get_incomes_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method_type.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/add_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/delete_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/get_payment_methods_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/update_payment_method_usecase.dart';

part 'payment_method_event.dart';
part 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final AddPaymentMethodUseCase addPaymentMethodUseCase;
  final UpdatePaymentMethodUseCase updatePaymentMethodUseCase;
  final DeletePaymentMethodUseCase deletePaymentMethodUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final GetIncomesUseCase getIncomesUseCase;

  PaymentMethodBloc({
    required this.getPaymentMethodsUseCase,
    required this.addPaymentMethodUseCase,
    required this.updatePaymentMethodUseCase,
    required this.deletePaymentMethodUseCase,
    required this.getExpensesUseCase,
    required this.getIncomesUseCase,
  }) : super(const PaymentMethodInitial()) {
    on<FetchPaymentMethodsEvent>(_onFetch);
    on<AddPaymentMethodEvent>(_onAdd);
    on<UpdatePaymentMethodEvent>(_onUpdate);
    on<DeletePaymentMethodEvent>(_onDelete);
  }

  Future<void> _onFetch(FetchPaymentMethodsEvent event, Emitter<PaymentMethodState> emit) async {
    emit(const PaymentMethodLoading());
    try {
      final methodsResult = await getPaymentMethodsUseCase(event.userId);
      List<PaymentMethod>? methods;
      methodsResult.fold(
        (failure) => emit(PaymentMethodError(failure.message)),
        (m) => methods = m,
      );
      if (methods == null) return;

      final balances = <String, double>{};
      final availableCredits = <String, double>{};
      final accountMethods =
          methods!.where((m) => m.type.hasBalance && m.initialBalance != null).toList();
      final creditCardMethods = methods!
          .where((m) => m.type == PaymentMethodType.creditCard && m.creditLimit != null)
          .toList();

      if (accountMethods.isNotEmpty || creditCardMethods.isNotEmpty) {
        // Fetch expenses e incomes una sola vez para todos los métodos
        final expensesResult = await getExpensesUseCase(event.userId);
        final incomesResult = await getIncomesUseCase(event.userId);

        final expenses = expensesResult.fold((_) => [], (e) => e);
        final incomes = incomesResult.fold((_) => [], (i) => i);

        for (final method in accountMethods) {
          bool afterStart(DateTime date) =>
              method.balanceStartDate == null || !date.isBefore(method.balanceStartDate!);

          final spent = expenses
              .where((e) => e.paymentMethodId == method.id && afterStart(e.date))
              .fold(0.0, (sum, e) => sum + e.amount);

          final earned = incomes
              .where((i) => i.paymentMethodId == method.id && afterStart(i.date))
              .fold(0.0, (sum, i) => sum + i.amount);

          balances[method.id] = method.initialBalance! + earned - spent;
        }

        for (final method in creditCardMethods) {
          bool afterStart(DateTime date) =>
              method.balanceStartDate == null || !date.isBefore(method.balanceStartDate!);

          final spent = expenses
              .where((e) => e.paymentMethodId == method.id && afterStart(e.date))
              .fold(0.0, (sum, e) => sum + e.amount);

          final paid = incomes
              .where((i) => i.paymentMethodId == method.id && afterStart(i.date))
              .fold(0.0, (sum, i) => sum + i.amount);

          availableCredits[method.id] = method.creditLimit! - spent + paid;
        }
      }

      emit(PaymentMethodLoaded(methods!, balances: balances, availableCredits: availableCredits));
    } catch (e) {
      emit(PaymentMethodError(e.toString()));
    }
  }

  Future<void> _onAdd(AddPaymentMethodEvent event, Emitter<PaymentMethodState> emit) async {
    emit(const PaymentMethodLoading());
    final result = await addPaymentMethodUseCase(event.paymentMethod);
    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (_) => emit(const PaymentMethodOperationSuccess('Método de pago agregado')),
    );
  }

  Future<void> _onUpdate(UpdatePaymentMethodEvent event, Emitter<PaymentMethodState> emit) async {
    emit(const PaymentMethodLoading());
    final result = await updatePaymentMethodUseCase(event.paymentMethod);
    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (_) => emit(const PaymentMethodOperationSuccess('Método de pago actualizado')),
    );
  }

  Future<void> _onDelete(DeletePaymentMethodEvent event, Emitter<PaymentMethodState> emit) async {
    emit(const PaymentMethodLoading());
    final result = await deletePaymentMethodUseCase(event.paymentMethodId);
    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (_) => emit(const PaymentMethodOperationSuccess('Método de pago eliminado')),
    );
  }
}
