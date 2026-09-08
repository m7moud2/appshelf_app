import '../config/api_config.dart';
import 'api_client.dart';

class UpdateChecker {
  UpdateChecker(this._api);

  final ApiClient _api;

  Future<({bool updateAvailable, String? storeVersion, String? storeUrl})>
      checkSelfUpdate({required String currentVersion}) async {
    try {
      final bundle = await _api.fetchAppDetail('appshelf');
      final storeVersion = bundle.app.version;
      final available = _isNewer(storeVersion, currentVersion);
      return (
        updateAvailable: available,
        storeVersion: storeVersion,
        storeUrl: ApiConfig.resolveMedia(bundle.app.downloadUrl),
      );
    } catch (_) {
      return (updateAvailable: false, storeVersion: null, storeUrl: null);
    }
  }

  bool _isNewer(String remote, String local) {
    int parse(String v) {
      final core = v.split('+').first;
      final parts = core.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      while (parts.length < 3) {
        parts.add(0);
      }
      return parts[0] * 10000 + parts[1] * 100 + parts[2];
    }

    return parse(remote) > parse(local);
  }
}
