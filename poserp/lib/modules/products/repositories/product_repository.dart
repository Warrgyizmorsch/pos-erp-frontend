import '../../../core/api/api_exceptions.dart';
import '../../../data/models/api_response.dart';
import '../models/product.dart';
import '../models/product_payload.dart';
import '../services/product_service.dart';

class ProductRepository {
  final ProductService _productService;

  ProductRepository(this._productService);

  Future<ApiResponse<List<Product>>> getProducts({
    String? search,
    String? category,
    int page = 1,
    int limit = 15,
  }) async {
    try {
      return await _productService.getAll(
        search: search,
        category: category,
        page: page,
        limit: limit,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch products.');
    }
  }

  Future<Product> getProductById(String id) async {
    try {
      final res = await _productService.getById(id);
      if (res.data != null) return res.data!;
      throw AppException(message: res.message ?? 'Product not found.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to fetch product.');
    }
  }

  Future<Product> createProduct(ProductPayload payload) async {
    try {
      final res = await _productService.create(payload);
      if (res.data != null) return res.data!;
      throw AppException(message: res.message ?? 'Failed to create product.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to create product.');
    }
  }

  Future<Product> updateProduct(String id, ProductPayload payload) async {
    try {
      final res = await _productService.update(id, payload);
      if (res.data != null) return res.data!;
      throw AppException(message: res.message ?? 'Failed to update product.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to update product.');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.delete(id);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(message: 'Failed to delete product.');
    }
  }
}
