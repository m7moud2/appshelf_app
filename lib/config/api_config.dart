import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Base URL for the Next.js AppShelf API.
///
/// Priority: runtime prefs override → dart-define → platform defaults.
class ApiConfig {
  static const String appVersion = '1.0.0';

  /// Production web/API (Vercel).
  static const String productionBaseUrl = 'https://appshelf-nine.vercel.app';

  static const String _defineBase = String.fromEnvironment(
    'APPSHELF_API_BASE',
    defaultValue: '',
  );
  static const _prefsKey = 'appshelf_api_base_override';

  static String? _runtimeOverride;

  static Future<void> loadOverride() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_prefsKey);
    _runtimeOverride = (v != null && v.trim().isNotEmpty) ? v.trim() : null;
  }

  static Future<void> setOverride(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    final cleaned = url?.trim().replaceAll(RegExp(r'/$'), '');
    if (cleaned == null || cleaned.isEmpty) {
      await prefs.remove(_prefsKey);
      _runtimeOverride = null;
    } else {
      await prefs.setString(_prefsKey, cleaned);
      _runtimeOverride = cleaned;
    }
  }

  static Future<void> useProductionServer() =>
      setOverride(productionBaseUrl);

  static Future<void> clearOverride() => setOverride(null);

  static String get baseUrl {
    if (_runtimeOverride != null && _runtimeOverride!.isNotEmpty) {
      return _runtimeOverride!;
    }
    if (_defineBase.isNotEmpty) return _defineBase.replaceAll(RegExp(r'/$'), '');
    if (!kDebugMode) return productionBaseUrl;
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    } catch (_) {}
    return 'http://localhost:3000';
  }

  static bool get isUsingProduction =>
      baseUrl.replaceAll(RegExp(r'/$'), '') == productionBaseUrl;

  /// Public store listing for this mobile client.
  static String get storeListingUrl => '$baseUrl/apps/appshelf';

  static String resolveMedia(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) return '$baseUrl$path';
    return '$baseUrl/$path';
  }
}
