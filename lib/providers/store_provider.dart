import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/api_client.dart';

class StoreProvider extends ChangeNotifier {
  StoreProvider(this._api);

  final ApiClient _api;
  List<StoreApp> apps = [];
  bool loading = false;
  String? error;
  String query = '';
  String category = 'all';
  String sort = 'newest';
  bool usingMock = false;

  List<StoreApp> get filtered {
    var list = apps;
    if (category != 'all') {
      list = list.where((a) => a.category == category).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((a) {
        return a.name.toLowerCase().contains(q) ||
            a.nameAr.contains(query.trim()) ||
            a.shortDescription.toLowerCase().contains(q) ||
            a.shortDescriptionAr.contains(query.trim()) ||
            a.category.toLowerCase().contains(q);
      }).toList();
    }
    list = [...list];
    if (sort == 'popular') {
      list.sort((a, b) => b.downloadsPlaceholder.compareTo(a.downloadsPlaceholder));
    } else if (sort == 'rating') {
      list.sort((a, b) => b.downloadsPlaceholder.compareTo(a.downloadsPlaceholder));
    } else {
      list.sort((a, b) => b.slug.compareTo(a.slug));
    }
    return list;
  }

  List<StoreApp> get featured =>
      apps.where((a) => a.featured).toList();

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      apps = await _api.fetchPublishedApps();
      usingMock = _api.usingMock;
    } catch (e) {
      error = 'تعذّر تحميل التطبيقات';
    }
    loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setSort(String value) {
    sort = value;
    notifyListeners();
  }

  StoreApp? findBySlug(String slug) {
    try {
      return apps.firstWhere((a) => a.slug == slug || a.id == slug);
    } catch (_) {
      return null;
    }
  }
}
