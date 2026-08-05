import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../models/category.dart';
import '../models/category_payload.dart';
import '../services/category_service.dart';

class CategoryRepository {
  final CategoryService _categoryService;

  CategoryRepository(this._categoryService);

  Future<ApiResponse<List<Category>>> getCategories({
    String? search,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      return await _categoryService.getAll(
        search: search,
        page: page,
        limit: limit,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch categories.');
    }
  }

  Future<Category> createCategory(CategoryPayload payload) async {
    try {
      final res = await _categoryService.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: res.message ?? 'Failed to create category.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create category.');
    }
  }

  Future<Category> updateCategory(String id, CategoryPayload payload) async {
    try {
      final res = await _categoryService.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(message: res.message ?? 'Failed to update category.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update category.');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _categoryService.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete category.');
    }
  }
}
