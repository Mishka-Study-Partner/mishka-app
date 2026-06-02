import 'data_sources/app_public_settings_remote_data_source.dart';
import 'models/app_public_settings_model.dart';

/// In-memory cache so Privacy + Help share one `/public/app-settings` fetch.
class AppPublicSettingsCache {
  AppPublicSettingsCache._();

  static AppPublicSettingsModel? _cached;

  static Future<AppPublicSettingsModel?> load(
    AppPublicSettingsRemoteDataSource remote, {
    bool refresh = false,
  }) async {
    if (!refresh && _cached != null) return _cached;
    _cached = await remote.fetch();
    return _cached;
  }

  static void invalidate() => _cached = null;
}
