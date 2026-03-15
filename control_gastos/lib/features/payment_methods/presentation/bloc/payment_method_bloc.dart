import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:control_gastos/features/payment_methods/domain/entities/payment_method.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/add_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/delete_payment_method_usecase.dart';
import 'package:control_gastos/features/payment_methods/domain/usecases/get_payment_methods_usecase.dart';

part 'payment_method_event.dart';
part 'payment_method_state.dart';

class PaymentMethodBloc extends Bloc<PaymentMethodEvent, PaymentMethodState> {
  final GetPaymentMethodsUseCase getPaymentMethodsUseCase;
  final AddPaymentMethodUseCase addPaymentMethodUseCase;
  final DeletePaymentMethodUseCase deletePaymentMethodUseCase;

  PaymentMethodBloc({
    required this.getPaymentMethodsUseCase,
    required this.addPaymentMethodUseCase,
    required this.deletePaymentMethodUseCase,
  }) : super(const PaymentMethodInitial()) {
    on<FetchPaymentMethodsEvent>(_onFetch);
    on<AddPaymentMethodEvent>(_onAdd);
    on<DeletePaymentMethodEvent>(_onDelete);
  }

  Future<void> _onFetch(FetchPaymentMethodsEvent event, Emitter<PaymentMethodState> emit) async {
    emit(const PaymentMethodLoading());
    final result = await getPaymentMethodsUseCase(event.userId);
    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (methods) => emit(PaymentMethodLoaded(methods)),
    );
  }

  Future<void> _onAdd(AddPaymentMethodEvent event, Emitter<PaymentMethodState> emit) async {
    emit(const PaymentMethodLoading());
    final result = await addPaymentMethodUseCase(event.paymentMethod);
    result.fold(
      (failure) => emit(PaymentMethodError(failure.message)),
      (_) => emit(const PaymentMethodOperationSuccess('Método de pago agregado')),
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
