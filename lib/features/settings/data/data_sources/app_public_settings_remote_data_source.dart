import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';

import '../models/app_public_settings_model.dart';

/// Public app copy (no JWT required).
class AppPublicSettingsRemoteDataSource {
  AppPublicSettingsRemoteDataSource(this._api);

  final ApiService _api;

  Future<AppPublicSettingsModel?> fetch() async {
    final env = await _api.get<AppPublicSettingsModel?>(
      ApiEndpoints.publicAppSettings,
      dataFromJson: AppPublicSettingsModel.tryParseEnvelopeData,
    );
    return env.data;
  }
}
