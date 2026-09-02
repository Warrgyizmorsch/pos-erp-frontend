import api from "./api";
import type { Product, ApiResponse, Pagination, ProductPriceOptionsResponse } from "@/types";
import { db } from "@/lib/db";

export const productService = {
  getAll: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
    category?: string;
    sortBy?: string;
    sortOrder?: string;
    lowStock?: boolean;
  }): Promise<{ data: Product[]; pagination: Pagination }> => {
    try {
      const { data } = await api.get<ApiResponse<Product[]>>("/products", { params });
      
      // Cache to IndexedDB asynchronously
      if (data.data && data.data.length > 0 && !params?.search && !params?.category) {
        // Only cache the full list (or first big chunk) when there are no filters
        db.products.bulkPut(data.data).catch(console.error);
      }
      
      return { data: data.data, pagination: data.pagination! };
    } catch (error: any) {
      // If offline, fetch from Dexie
      if (error.code === 'ERR_NETWORK' || !navigator.onLine) {
        console.log("Offline mode: Fetching products from local DB");
        let query = db.products.toCollection();
        
        if (params?.search) {
          const searchLower = params.search.toLowerCase();
          query = db.products.filter(p => 
            p.name.toLowerCase().includes(searchLower) || 
            (p.barcode || "").toLowerCase().includes(searchLower) || 
            (p.sku || "").toLowerCase().includes(searchLower)
          );
        } else if (params?.category) {
          query = db.products.filter(p => p.category === params.category);
        }
        
        const localProducts = await query.toArray();
        return { 
          data: localProducts, 
          pagination: { 
            total: localProducts.length, 
            page: 1, 
            limit: localProducts.length, 
            pages: 1 
          } 
        };
      }
      throw error;
    }
  },

  getById: async (id: string): Promise<Product> => {
    const { data } = await api.get<ApiResponse<Product>>(`/products/${id}`);
    return data.data;
  },

  getByBarcode: async (barcode: string): Promise<Product> => {
    try {
      const { data } = await api.get<ApiResponse<Product>>(`/products/barcode/${barcode}`);
      if (data.data) {
        db.products.put(data.data).catch(console.error);
      }
      return data.data;
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || !navigator.onLine) {
        const localProduct = await db.products.where('barcode').equals(barcode).first();
        if (localProduct) return localProduct;
      }
      throw error;
    }
  },

  getPriceOptions: async (id: string): Promise<ProductPriceOptionsResponse> => {
    const { data } = await api.get<ApiResponse<ProductPriceOptionsResponse> & ProductPriceOptionsResponse>(`/products/${id}/price-options`);
    return data.data || {
      product: data.product,
      priceOptions: data.priceOptions,
      defaultPrice: data.defaultPrice,
      priceSelectionRequired: data.priceSelectionRequired,
    };
  },

  create: async (payload: Partial<Product>): Promise<Product> => {
    const { data } = await api.post<ApiResponse<Product>>("/products", payload);
    return data.data;
  },

  update: async (id: string, payload: Partial<Product>): Promise<Product> => {
    const { data } = await api.put<ApiResponse<Product>>(`/products/${id}`, payload);
    return data.data;
  },

  delete: async (id: string): Promise<void> => {
    await api.delete(`/products/${id}`);
  },

  getStats: async () => {
    const { data } = await api.get("/products/stats/overview");
    return data.data;
  },

  getPricing: async (id: string, strategy: "latest" | "fifo" = "latest"): Promise<{
    productId: string;
    batchNo: string;
    purchasePrice: number;
    salesPrice: number;
    availableQty: number;
    taxPercent: number;
    salesTaxType?: string;
  }> => {
    const { data } = await api.get<ApiResponse<any>>(`/products/${id}/pricing`, { params: { strategy } });
    return data.data;
  },

  bulkImport: async (products: any[]): Promise<any> => {
    const { data } = await api.post<ApiResponse<any>>("/products/bulk-import", { products });
    return data;
  },

  getGlobalLibrary: async (params?: { search?: string; barcode?: string }): Promise<any[]> => {
    const { data } = await api.get<ApiResponse<any[]>>("/products/global-library", { params });
    return data.data;
  },
};
