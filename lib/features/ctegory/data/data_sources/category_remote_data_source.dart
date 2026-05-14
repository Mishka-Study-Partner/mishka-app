import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/ctegory/data/models/ai_tool_api_model.dart';
import 'package:mishka_app/features/ctegory/data/models/category_api_model.dart';
import 'package:mishka_app/features/ctegory/data/models/saved_category_api_model.dart';

class CategoryRemoteDataSource {
  CategoryRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<CategoryApiModel>> getCategories() async {
    final env = await _api.get<List<CategoryApiModel>>(
      ApiEndpoints.categories,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => CategoryApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<AiToolApiModel>> getAiTools() async {
    final env = await _api.get<List<AiToolApiModel>>(
      ApiEndpoints.aiTools,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => AiToolApiModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<List<SavedCategoryApiModel>> getSavedCategories() async {
    final env = await _api.get<List<SavedCategoryApiModel>>(
      ApiEndpoints.userSavedCategories,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map(
              (e) => SavedCategoryApiModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<SavedCategoryApiModel?> saveCategory({required String categoryId}) async {
    final env = await _api.post<SavedCategoryApiModel>(
      ApiEndpoints.userSavedCategories,
      data: {'categoryId': categoryId},
      dataFromJson: (raw) {
        if (raw is Map) {
          return SavedCategoryApiModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid saved category response');
      },
    );
    return env.data;
  }

  Future<void> removeSavedCategory({required String savedRowId}) async {
    await _api.delete<void>(ApiEndpoints.userSavedCategoryById(savedRowId));
  }
}
