import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';
import '../services/oauth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._api, {OAuthService? oauth})
      : _oauth = oauth ?? OAuthService();

  final ApiClient _api;
  final OAuthService _oauth;
  AppUser? user;
  bool loading = true;
  String? error;

  bool get isLoggedIn => user != null;
  bool get isDeveloper => user?.isDeveloper ?? false;
  OAuthService get oauthService => _oauth;

  Future<void> bootstrap() async {
    loading = true;
    notifyListeners();
    await _api.loadToken();
    user = await _api.me();
    loading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      user = await _api.login(email.trim(), password);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      user = await _api.signup(
        email: email.trim(),
        password: password,
        name: name.trim(),
        role: role,
      );
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      final result = await _oauth.signInWithGoogle();
      if (result.cancelled) {
        loading = false;
        notifyListeners();
        return false;
      }
      user = await _api.oauth(
        provider: 'google',
        idToken: result.idToken,
        accessToken: result.accessToken,
        email: result.email,
        name: result.name,
        demo: result.demo || result.idToken == null,
      );
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithApple() async {
    error = null;
    loading = true;
    notifyListeners();
    try {
      final result = await _oauth.signInWithApple();
      if (result.cancelled) {
        loading = false;
        notifyListeners();
        return false;
      }
      user = await _api.oauth(
        provider: 'apple',
        idToken: result.idToken,
        accessToken: result.accessToken,
        email: result.email,
        name: result.name,
        demo: result.demo || result.idToken == null,
      );
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString().replaceFirst('ApiException: ', '');
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    user = null;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
