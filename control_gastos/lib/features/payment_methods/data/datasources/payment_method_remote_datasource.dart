import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/payment_methods/data/models/payment_method_model.dart';

abstract class PaymentMethodRemoteDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId);
  Future<void> addPaymentMethod(PaymentMethodModel paymentMethod);
  Future<void> updatePaymentMethod(PaymentMethodModel paymentMethod);
  Future<void> deletePaymentMethod(String paymentMethodId);
}

class PaymentMethodRemoteDataSourceImpl implements PaymentMethodRemoteDataSource {
  final FirebaseFirestore _firestore;

  PaymentMethodRemoteDataSourceImpl(this._firestore);

  CollectionReference get _col => _firestore.collection(AppConstants.paymentMethodsCollection);

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId) async {
    try {
      final snap = await _col.where('userId', isEqualTo: userId).get();
      return snap.docs.map((d) => PaymentMethodModel.fromJson(d.data() as Map<String, dynamic>, id: d.id)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addPaymentMethod(PaymentMethodModel paymentMethod) async {
    try { await _col.doc(paymentMethod.id).set(paymentMethod.toJson()); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> updatePaymentMethod(PaymentMethodModel paymentMethod) async {
    try { await _col.doc(paymentMethod.id).update(paymentMethod.toJson()); } catch (e) { throw ServerException(e.toString()); }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try { await _col.doc(paymentMethodId).delete(); } catch (e) { throw ServerException(e.toString()); }
  }
}
