part of 'payment_method_bloc.dart';

abstract class PaymentMethodEvent extends Equatable {
  const PaymentMethodEvent();
  @override
  List<Object?> get props => [];
}

class FetchPaymentMethodsEvent extends PaymentMethodEvent {
  final String userId;
  const FetchPaymentMethodsEvent(this.userId);
  @override
  List<Object> get props => [userId];
}

class AddPaymentMethodEvent extends PaymentMethodEvent {
  final PaymentMethod paymentMethod;
  const AddPaymentMethodEvent(this.paymentMethod);
  @override
  List<Object> get props => [paymentMethod];
}

class DeletePaymentMethodEvent extends PaymentMethodEvent {
  final String paymentMethodId;
  const DeletePaymentMethodEvent(this.paymentMethodId);
  @override
  List<Object> get props => [paymentMethodId];
}
