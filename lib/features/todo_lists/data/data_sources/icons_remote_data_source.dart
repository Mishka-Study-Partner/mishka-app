import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/todo_lists/data/models/icon_api_model.dart';

class IconsRemoteDataSource {
  IconsRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<IconApiModel>> getIcons() async {
    final env = await _api.get<List<IconApiModel>>(
      ApiEndpoints.icons,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => IconApiModel.fromJson(Map<String, dynamic>.from(e)))
            .where((icon) => icon.id > 0)
            .toList();
      },
    );
    return env.data ?? const [];
  }
}
