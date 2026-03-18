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
  /// currentBalance por paymentMethodId. Solo para métodos con hasBalance e initialBalance.
  final Map<String, double> balances;
  /// cupo disponible por paymentMethodId. Solo para tarjetas de crédito con creditLimit.
  final Map<String, double> availableCredits;

  const PaymentMethodLoaded(
    this.paymentMethods, {
    this.balances = const {},
    this.availableCredits = const {},
  });

  @override
  List<Object?> get props => [paymentMethods, balances, availableCredits];
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
