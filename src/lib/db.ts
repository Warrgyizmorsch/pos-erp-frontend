import Dexie, { type Table } from 'dexie';
import type { Product, Customer } from '@/types';

// We need to define types for our offline tables
export interface OfflineSale {
  id?: number; // Auto-incremented primary key for Dexie
  uuid: string; // Unique ID for the sale to prevent duplicates
  payload: any; // The sale payload that will be sent to the backend
  status: 'pending' | 'syncing' | 'failed';
  createdAt: string;
  errorMessage?: string;
}

export interface SyncQueueItem {
  id?: number;
  operation: 'create_customer' | 'update_customer' | 'other';
  payload: any;
  status: 'pending' | 'syncing' | 'failed';
  createdAt: string;
  errorMessage?: string;
}

export class POSDatabase extends Dexie {
  products!: Table<Product, string>; // string is the type of the primary key (_id)
  customers!: Table<Customer, string>;
  offlineSales!: Table<OfflineSale, number>;
  syncQueue!: Table<SyncQueueItem, number>;

  constructor() {
    super('POSDatabase');
    
    // Define tables and indexes
    this.version(1).stores({
      products: '_id, name, barcode, sku, category',
      customers: '_id, name, phone, isOffline', // isOffline added to quickly find offline created customers
      offlineSales: '++id, uuid, status, createdAt',
      syncQueue: '++id, operation, status, createdAt'
    });
  }
}

export const db = new POSDatabase();
