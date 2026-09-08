import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';

class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._api);

  final ApiClient _api;
  List<StoreApp> favorites = [];
  List<StoreApp> installed = [];
  final Set<String> favoriteIds = {};
  final Set<String> installedIds = {};
  bool loading = false;
  String? error;

  Future<void> refresh({bool requireAuth = true}) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _api.library();
      favorites = result.favorites;
      installed = result.installed;
      favoriteIds
        ..clear()
        ..addAll(favorites.map((a) => a.id));
      installedIds
        ..clear()
        ..addAll(installed.map((a) => a.id));
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        favorites = [];
        installed = [];
        favoriteIds.clear();
        installedIds.clear();
        if (requireAuth) error = e.message;
      } else {
        error = e.message;
      }
    } catch (_) {
      error = 'تعذّر تحميل المكتبة';
    }
    loading = false;
    notifyListeners();
  }

  Future<bool> toggleFavorite(String appId) async {
    try {
      final favorited = await _api.toggleFavorite(appId);
      if (favorited) {
        favoriteIds.add(appId);
      } else {
        favoriteIds.remove(appId);
        favorites = favorites.where((a) => a.id != appId).toList();
      }
      notifyListeners();
      return favorited;
    } catch (e) {
      rethrow;
    }
  }

  void markInstalled(String appId, StoreApp? app) {
    installedIds.add(appId);
    if (app != null && !installed.any((a) => a.id == appId)) {
      installed = [app, ...installed];
    }
    notifyListeners();
  }

  bool isFavorite(String appId) => favoriteIds.contains(appId);
  bool isInstalled(String appId) => installedIds.contains(appId);

  void clear() {
    favorites = [];
    installed = [];
    favoriteIds.clear();
    installedIds.clear();
    error = null;
    notifyListeners();
  }
}
