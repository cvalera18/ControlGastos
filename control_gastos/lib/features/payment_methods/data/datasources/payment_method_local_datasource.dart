import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:control_gastos/core/errors/exceptions.dart';
import 'package:control_gastos/features/payment_methods/data/models/payment_method_model.dart';

abstract class PaymentMethodLocalDataSource {
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId);
  Future<void> savePaymentMethods(List<PaymentMethodModel> methods);
  Future<void> deletePaymentMethod(String paymentMethodId);
}

class PaymentMethodLocalDataSourceImpl implements PaymentMethodLocalDataSource {
  final SharedPreferences _prefs;

  PaymentMethodLocalDataSourceImpl(this._prefs);

  String _key(String userId) => 'payment_methods_$userId';

  @override
  Future<List<PaymentMethodModel>> getPaymentMethods(String userId) async {
    try {
      final jsonStr = _prefs.getString(_key(userId));
      if (jsonStr == null) return [];
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> savePaymentMethods(List<PaymentMethodModel> methods) async {
    if (methods.isEmpty) return;
    try {
      final userId = methods.first.userId;
      final existing = await getPaymentMethods(userId);
      final Map<String, PaymentMethodModel> map = {for (final m in existing) m.id: m};
      for (final m in methods) {
        map[m.id] = m;
      }
      await _prefs.setString(_key(userId), jsonEncode(map.values.map((m) => m.toJson()).toList()));
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      final allKeys = _prefs.getKeys().where((k) => k.startsWith('payment_methods_'));
      for (final key in allKeys) {
        final jsonStr = _prefs.getString(key);
        if (jsonStr == null) continue;
        final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
        final filtered = list.where((e) => (e as Map<String, dynamic>)['id'] != paymentMethodId).toList();
        if (filtered.length != list.length) {
          await _prefs.setString(key, jsonEncode(filtered));
          return;
        }
      }
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
