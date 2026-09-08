import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OAuthResult {
  const OAuthResult({
    required this.provider,
    this.idToken,
    this.accessToken,
    this.email,
    this.name,
    this.demo = false,
    this.cancelled = false,
  });

  final String provider;
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? name;
  final bool demo;
  final bool cancelled;
}

/// Native Google / Apple when available; otherwise a clear demo fallback.
class OAuthService {
  final GoogleSignIn _google = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  Future<bool> get appleAvailable async {
    if (kIsWeb) return false;
    try {
      if (!(Platform.isIOS || Platform.isMacOS)) return false;
      return SignInWithApple.isAvailable();
    } catch (_) {
      return false;
    }
  }

  bool get showAppleButton {
    if (kIsWeb) return true;
    try {
      return Platform.isIOS || Platform.isMacOS || Platform.isAndroid;
    } catch (_) {
      return true;
    }
  }

  Future<OAuthResult> signInWithGoogle() async {
    try {
      final account = await _google.signIn();
      if (account == null) {
        return const OAuthResult(provider: 'google', cancelled: true);
      }
      final auth = await account.authentication;
      if (auth.idToken != null || auth.accessToken != null) {
        return OAuthResult(
          provider: 'google',
          idToken: auth.idToken,
          accessToken: auth.accessToken,
          email: account.email,
          name: account.displayName,
        );
      }
    } catch (_) {
      // Fall through to demo — no client IDs / Play Services in local builds.
    }
    return const OAuthResult(
      provider: 'google',
      demo: true,
      name: 'مستخدم Google',
    );
  }

  Future<OAuthResult> signInWithApple() async {
    try {
      final available = await appleAvailable;
      if (available) {
        final cred = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        final name = [
          cred.givenName,
          cred.familyName,
        ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
        return OAuthResult(
          provider: 'apple',
          idToken: cred.identityToken,
          accessToken: cred.authorizationCode,
          email: cred.email,
          name: name.isEmpty ? null : name,
        );
      }
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('cancel') || msg.contains('canceled')) {
        return const OAuthResult(provider: 'apple', cancelled: true);
      }
    }
    return const OAuthResult(
      provider: 'apple',
      demo: true,
      name: 'مستخدم Apple',
    );
  }
}
