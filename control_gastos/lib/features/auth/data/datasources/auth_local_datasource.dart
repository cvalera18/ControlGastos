import 'package:shared_preferences/shared_preferences.dart';
import 'package:control_gastos/core/config/constants.dart';
import 'package:control_gastos/core/errors/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearUser();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveUserId(String userId) async {
    try {
      await _prefs.setString(AppConstants.keyUserId, userId);
      await _prefs.setBool(AppConstants.keyIsLoggedIn, true);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<String?> getUserId() async => _prefs.getString(AppConstants.keyUserId);

  @override
  Future<void> clearUser() async {
    try {
      await _prefs.remove(AppConstants.keyUserId);
      await _prefs.remove(AppConstants.keyUserEmail);
      await _prefs.remove(AppConstants.keyUserName);
      await _prefs.setBool(AppConstants.keyIsLoggedIn, false);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<bool> isLoggedIn() async =>
      _prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
}
