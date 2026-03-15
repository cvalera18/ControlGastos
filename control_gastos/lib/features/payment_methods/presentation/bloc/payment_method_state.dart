part of 'payment_method_bloc.dart';

abstract class PaymentMethodState extends Equatable {
  const PaymentMethodState();
  @override
  List<Object?> get props => [];
}

class PaymentMethodInitial extends PaymentMethodState {
  const PaymentMethodInitial();
}

class PaymentMethodLoading extends PaymentMethodState {
  const PaymentMethodLoading();
}

class PaymentMethodLoaded extends PaymentMethodState {
  final List<PaymentMethod> paymentMethods;
  const PaymentMethodLoaded(this.paymentMethods);
  @override
  List<Object> get props => [paymentMethods];
}

class PaymentMethodOperationSuccess extends PaymentMethodState {
  final String message;
  const PaymentMethodOperationSuccess(this.message);
  @override
  List<Object> get props => [message];
}

class PaymentMethodError extends PaymentMethodState {
  final String message;
  const PaymentMethodError(this.message);
  @override
  List<Object> get props => [message];
}
