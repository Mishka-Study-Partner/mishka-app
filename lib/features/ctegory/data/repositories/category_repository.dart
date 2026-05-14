import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/ctegory/data/data_sources/category_remote_data_source.dart';
import 'package:mishka_app/features/ctegory/data/models/ai_tool_api_model.dart';
import 'package:mishka_app/features/ctegory/data/models/category_api_model.dart';
import 'package:mishka_app/features/ctegory/data/models/saved_category_api_model.dart';

class CategoryRepository {
  CategoryRepository({CategoryRemoteDataSource? remote})
      : _remote = remote ?? CategoryRemoteDataSource(ApiService());

  final CategoryRemoteDataSource _remote;

  Future<List<CategoryApiModel>> getCategories() => _remote.getCategories();

  Future<List<AiToolApiModel>> getAiTools() => _remote.getAiTools();

  Future<List<SavedCategoryApiModel>> getSavedCategories() =>
      _remote.getSavedCategories();

  Future<SavedCategoryApiModel?> saveCategory({required String categoryId}) =>
      _remote.saveCategory(categoryId: categoryId);

  Future<void> removeSavedCategory({required String savedRowId}) =>
      _remote.removeSavedCategory(savedRowId: savedRowId);
}
