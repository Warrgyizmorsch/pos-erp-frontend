import api from "./api";
import type { Customer, ApiResponse, Pagination } from "@/types";
import { db } from "@/lib/db";

export const customerService = {
  getAll: async (params?: {
    page?: number;
    limit?: number;
    search?: string;
  }): Promise<{ data: Customer[]; pagination: Pagination }> => {
    try {
      const { data } = await api.get<ApiResponse<Customer[]>>("/customers", { params });
      
      if (data.data && data.data.length > 0 && !params?.search) {
        db.customers.bulkPut(data.data).catch(console.error);
      }
      
      return { data: data.data, pagination: data.pagination! };
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || !navigator.onLine) {
        let query = db.customers.toCollection();
        
        if (params?.search) {
          const searchLower = params.search.toLowerCase();
          query = db.customers.filter(c => 
            c.name.toLowerCase().includes(searchLower) || 
            (c.phone || "").includes(searchLower)
          );
        }
        
        const localCustomers = await query.toArray();
        return { 
          data: localCustomers, 
          pagination: { 
            total: localCustomers.length, 
            page: 1, 
            limit: localCustomers.length, 
            pages: 1 
          } 
        };
      }
      throw error;
    }
  },

  getById: async (id: string): Promise<Customer> => {
    try {
      const { data } = await api.get<ApiResponse<Customer>>(`/customers/${id}`);
      if (data.data) {
        db.customers.put(data.data).catch(console.error);
      }
      return data.data;
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || !navigator.onLine) {
        const localCustomer = await db.customers.get(id);
        if (localCustomer) return localCustomer;
      }
      throw error;
    }
  },

  create: async (payload: Partial<Customer>): Promise<Customer> => {
    try {
      const { data } = await api.post<ApiResponse<Customer>>("/customers", payload);
      if (data.data) {
        db.customers.put(data.data).catch(console.error);
      }
      return data.data;
    } catch (error: any) {
      if (error.code === 'ERR_NETWORK' || !navigator.onLine) {
        // Create an offline customer
        const newCustomer: Customer = {
          _id: `offline_${crypto.randomUUID()}`,
          name: payload.name || '',
          phone: payload.phone || '',
          email: payload.email || '',
          address: payload.address || '',
          totalPurchases: 0,
          totalSpent: 0,
          walletBalance: 0,
          isActive: true,
          createdAt: new Date().toISOString(),
          // Custom flag (you can cast or ignore type error if not strictly defined)
          ...( { isOffline: true } as any )
        };
        
        await db.customers.put(newCustomer);
        
        // Add to sync queue
        await db.syncQueue.add({
          operation: 'create_customer',
          payload: newCustomer,
          status: 'pending',
          createdAt: new Date().toISOString(),
        });
        
        return newCustomer;
      }
      throw error;
    }
  },

  update: async (id: string, payload: Partial<Customer>): Promise<Customer> => {
    const { data } = await api.put<ApiResponse<Customer>>(`/customers/${id}`, payload);
    return data.data;
  },

  delete: async (id: string): Promise<void> => {
    await api.delete(`/customers/${id}`);
  },
};
