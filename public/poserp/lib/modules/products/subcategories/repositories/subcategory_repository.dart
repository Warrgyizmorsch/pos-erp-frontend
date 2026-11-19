import '../../../../core/api/api_exceptions.dart';
import '../../../../data/models/api_response.dart';
import '../models/subcategory.dart';
import '../models/subcategory_payload.dart';
import '../services/subcategory_service.dart';

class SubcategoryRepository {
  final SubcategoryService _subcategoryService;

  SubcategoryRepository(this._subcategoryService);

  Future<ApiResponse<List<Subcategory>>> getSubcategories({
    String? search,
    String? parentCategoryId,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      return await _subcategoryService.getAll(
        search: search,
        parentCategoryId: parentCategoryId,
        page: page,
        limit: limit,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch subcategories.');
    }
  }

  Future<Subcategory> createSubcategory(SubcategoryPayload payload) async {
    try {
      final res = await _subcategoryService.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(
        message: res.message ?? 'Failed to create subcategory.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create subcategory.');
    }
  }

  Future<Subcategory> updateSubcategory(
    String id,
    SubcategoryPayload payload,
  ) async {
    try {
      final res = await _subcategoryService.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(
        message: res.message ?? 'Failed to update subcategory.',
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update subcategory.');
    }
  }

  Future<void> deleteSubcategory(String id) async {
    try {
      await _subcategoryService.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete subcategory.');
    }
  }
}
