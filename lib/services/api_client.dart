import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../data/mock_catalog.dart';
import '../models/models.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// HTTP client for AppShelf Next.js routes + local mock fallback.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  String? _token;
  bool usingMock = false;

  static const _tokenKey = 'appshelf_session_token';

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> _persistToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Map<String, String> _headers({bool jsonBody = false}) {
    final h = <String, String>{
      'Accept': 'application/json',
      'X-AppShelf-Client': 'mobile',
    };
    if (jsonBody) h['Content-Type'] = 'application/json';
    if (_token != null && _token!.isNotEmpty) {
      h['Authorization'] = 'Bearer $_token';
    }
    return h;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$p').replace(queryParameters: query);
  }

  Future<dynamic> _decode(http.Response res) {
    if (res.body.isEmpty) return Future.value(null);
    return Future.value(jsonDecode(utf8.decode(res.bodyBytes)));
  }

  Future<List<StoreApp>> fetchPublishedApps() async {
    try {
      final res = await _http
          .get(_uri('/api/apps'), headers: _headers())
          .timeout(const Duration(seconds: 8));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = await _decode(res);
        usingMock = false;
        if (data is List) {
          final apps = data
              .whereType<Map>()
              .map((e) => StoreApp.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          await _cacheCatalog(apps);
          return apps;
        }
      }
      throw ApiException('تعذّر تحميل المتجر', statusCode: res.statusCode);
    } catch (_) {
      final cached = await _readCachedCatalog();
      if (cached != null && cached.isNotEmpty) {
        usingMock = true;
        return cached;
      }
      usingMock = true;
      return MockCatalog.apps();
    }
  }

  static const _catalogCacheKey = 'appshelf_catalog_cache_v1';

  Future<void> _cacheCatalog(List<StoreApp> apps) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(
        apps
            .map(
              (a) => {
                'id': a.id,
                'slug': a.slug,
                'developerId': a.developerId,
                'name': a.name,
                'nameAr': a.nameAr,
                'shortDescription': a.shortDescription,
                'shortDescriptionAr': a.shortDescriptionAr,
                'description': a.description,
                'descriptionAr': a.descriptionAr,
                'whatsNew': a.whatsNew,
                'whatsNewAr': a.whatsNewAr,
                'iconUrl': a.iconUrl,
                'screenshots': a.screenshots,
                'packageId': a.packageId,
                'version': a.version,
                'sizeLabel': a.sizeLabel,
                'downloadUrl': a.downloadUrl,
                'websiteUrl': a.websiteUrl,
                'category': a.category,
                'platform': a.platform,
                'status': a.status,
                'featured': a.featured,
                'downloadsPlaceholder': a.downloadsPlaceholder,
              },
            )
            .toList(),
      );
      await prefs.setString(_catalogCacheKey, raw);
    } catch (_) {}
  }

  Future<List<StoreApp>?> _readCachedCatalog() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_catalogCacheKey);
      if (raw == null || raw.isEmpty) return null;
      final data = jsonDecode(raw);
      if (data is! List) return null;
      return data
          .whereType<Map>()
          .map((e) => StoreApp.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<AppDetailBundle> fetchAppDetail(String slugOrId) async {
    try {
      final res = await _http
          .get(
            _uri('/api/store/apps/$slugOrId'),
            headers: _headers(),
          )
          .timeout(const Duration(seconds: 8));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = await _decode(res) as Map<String, dynamic>;
        usingMock = false;
        return AppDetailBundle(
          app: StoreApp.fromJson(
            Map<String, dynamic>.from(data['app'] as Map),
          ),
          library: LibraryFlags.fromJson(
            data['library'] == null
                ? null
                : Map<String, dynamic>.from(data['library'] as Map),
          ),
          publisher: PublisherInfo.fromJson(
            Map<String, dynamic>.from(
              (data['publisher'] as Map?) ?? {'name': 'مطوّر'},
            ),
          ),
        );
      }
      throw ApiException('التطبيق غير موجود', statusCode: res.statusCode);
    } catch (_) {
      usingMock = true;
      final apps = MockCatalog.apps();
      final app = apps.firstWhere(
        (a) => a.slug == slugOrId || a.id == slugOrId,
        orElse: () => apps.first,
      );
      return AppDetailBundle(
        app: app,
        library: const LibraryFlags(),
        publisher: const PublisherInfo(
          name: 'AppShelf Demo Dev',
          verified: true,
          website: 'https://appshelf.app',
        ),
      );
    }
  }

  Future<AppUser> oauth({
    required String provider,
    String? idToken,
    String? accessToken,
    String? email,
    String? name,
    bool demo = false,
  }) async {
    final res = await _http
        .post(
          _uri('/api/auth/oauth'),
          headers: _headers(jsonBody: true),
          body: jsonEncode({
            'provider': provider,
            if (idToken != null) 'idToken': idToken,
            if (accessToken != null) 'accessToken': accessToken,
            if (email != null) 'email': email,
            if (name != null) 'name': name,
            'demo': demo,
          }),
        )
        .timeout(const Duration(seconds: 12));
    final data = await _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) await _persistToken(token);
      return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }
    final err = data is Map ? data['error']?.toString() : null;
    throw ApiException(
      err ?? 'تعذّر تسجيل الدخول عبر $provider',
      statusCode: res.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> fetchReviews(String appId) async {
    try {
      final res = await _http
          .get(_uri('/api/apps/$appId/reviews'), headers: _headers())
          .timeout(const Duration(seconds: 8));
      final data = await _decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
        return (data['reviews'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> submitReview({
    required String appId,
    required int rating,
    String comment = '',
  }) async {
    final res = await _http
        .post(
          _uri('/api/apps/$appId/reviews'),
          headers: _headers(jsonBody: true),
          body: jsonEncode({'rating': rating, 'comment': comment}),
        )
        .timeout(const Duration(seconds: 8));
    if (res.statusCode == 401) {
      throw ApiException('يلزم تسجيل الدخول للتقييم', statusCode: 401);
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final data = await _decode(res);
      final err = data is Map ? data['error']?.toString() : null;
      throw ApiException(err ?? 'تعذّر حفظ التقييم', statusCode: res.statusCode);
    }
  }

  Future<AppUser> login(String email, String password) async {
    final res = await _http
        .post(
          _uri('/api/auth/login'),
          headers: _headers(jsonBody: true),
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(const Duration(seconds: 10));
    final data = await _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) await _persistToken(token);
      return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }
    final err = data is Map ? data['error']?.toString() : null;
    throw ApiException(err ?? 'بيانات الدخول غير صحيحة', statusCode: res.statusCode);
  }

  Future<AppUser> signup({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final res = await _http
        .post(
          _uri('/api/auth/signup'),
          headers: _headers(jsonBody: true),
          body: jsonEncode({
            'email': email,
            'password': password,
            'name': name,
            'role': role,
          }),
        )
        .timeout(const Duration(seconds: 10));
    final data = await _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
      final token = data['token']?.toString();
      if (token != null && token.isNotEmpty) await _persistToken(token);
      return AppUser.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    }
    final err = data is Map ? data['error']?.toString() : null;
    throw ApiException(err ?? 'تعذّر إنشاء الحساب', statusCode: res.statusCode);
  }

  Future<AppUser?> me() async {
    if (_token == null || _token!.isEmpty) return null;
    try {
      final res = await _http
          .get(_uri('/api/auth/me'), headers: _headers())
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 401) {
        await _persistToken(null);
        return null;
      }
      final data = await _decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
        final user = data['user'];
        if (user == null) return null;
        return AppUser.fromJson(Map<String, dynamic>.from(user as Map));
      }
    } catch (_) {}
    return null;
  }

  Future<void> logout() async {
    try {
      await _http
          .post(_uri('/api/auth/logout'), headers: _headers())
          .timeout(const Duration(seconds: 5));
    } catch (_) {}
    await _persistToken(null);
  }

  Future<({List<StoreApp> favorites, List<StoreApp> installed})> library() async {
    final res = await _http
        .get(_uri('/api/library'), headers: _headers())
        .timeout(const Duration(seconds: 8));
    final data = await _decode(res);
    if (res.statusCode == 401) {
      throw ApiException('يلزم تسجيل الدخول', statusCode: 401);
    }
    if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
      List<StoreApp> parse(dynamic raw) => (raw as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => StoreApp.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return (
        favorites: parse(data['favorites']),
        installed: parse(data['installed']),
      );
    }
    throw ApiException('تعذّر تحميل المكتبة', statusCode: res.statusCode);
  }

  Future<bool> toggleFavorite(String appId) async {
    final res = await _http
        .post(
          _uri('/api/apps/$appId/favorite'),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 8));
    final data = await _decode(res);
    if (res.statusCode == 401) {
      throw ApiException('يلزم تسجيل الدخول للمفضلة', statusCode: 401);
    }
    if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
      return data['favorited'] == true;
    }
    throw ApiException('تعذّر تحديث المفضلة', statusCode: res.statusCode);
  }

  Future<({String downloadUrl, bool installed})> install(String appId) async {
    final res = await _http
        .post(
          _uri('/api/apps/$appId/install'),
          headers: _headers(),
        )
        .timeout(const Duration(seconds: 8));
    final data = await _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
      return (
        downloadUrl: data['downloadUrl']?.toString() ?? '',
        installed: data['installed'] == true,
      );
    }
    throw ApiException('تعذّر بدء التثبيت', statusCode: res.statusCode);
  }

  Future<List<StoreApp>> myApps() async {
    final res = await _http
        .get(_uri('/api/apps', {'mine': '1'}), headers: _headers())
        .timeout(const Duration(seconds: 8));
    final data = await _decode(res);
    if (res.statusCode == 401) {
      throw ApiException('يلزم تسجيل الدخول', statusCode: 401);
    }
    if (res.statusCode >= 200 && res.statusCode < 300 && data is List) {
      return data
          .whereType<Map>()
          .map((e) => StoreApp.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw ApiException('تعذّر تحميل تطبيقاتك', statusCode: res.statusCode);
  }

  Future<DeveloperProfile?> fetchDeveloperProfile(String slug) async {
    try {
      final res = await _http
          .get(_uri('/api/developers/$slug'), headers: _headers())
          .timeout(const Duration(seconds: 8));
      final data = await _decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300 && data is Map) {
        return DeveloperProfile.fromJson(Map<String, dynamic>.from(data));
      }
    } catch (_) {}
    return null;
  }

  Future<List<StoreApp>> fetchRelatedApps(String appId) async {
    try {
      final res = await _http
          .get(_uri('/api/apps/$appId/related'), headers: _headers())
          .timeout(const Duration(seconds: 8));
      final data = await _decode(res);
      if (res.statusCode >= 200 && res.statusCode < 300 && data is List) {
        return data
            .whereType<Map>()
            .map((e) => StoreApp.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}
