"use client";

import { useEffect, useState } from "react";
import { toast } from "sonner";
import { db } from "@/lib/db";
import api from "@/services/api";

export function OfflineSyncManager() {
  const [isOnline, setIsOnline] = useState(typeof navigator !== 'undefined' ? navigator.onLine : true);

  useEffect(() => {
    const handleOnline = () => {
      setIsOnline(true);
      toast.success("Back online! Syncing data...");
      syncData();
    };

    const handleOffline = () => {
      setIsOnline(false);
      toast.error("You are offline. Operating in offline mode.");
    };

    window.addEventListener("online", handleOnline);
    window.addEventListener("offline", handleOffline);

    // Initial check
    if (navigator.onLine) {
      syncData();
    }

    return () => {
      window.removeEventListener("online", handleOnline);
      window.removeEventListener("offline", handleOffline);
    };
  }, []);

  const syncData = async () => {
    if (!navigator.onLine) return;

    try {
      // 1. Sync Offline Sales
      const pendingSales = await db.offlineSales.where('status').equals('pending').toArray();
      
      for (const sale of pendingSales) {
        try {
          // Mark as syncing
          await db.offlineSales.update(sale.id!, { status: 'syncing' });
          
          // Try sending to server
          await api.post("/sales", sale.payload);
          
          // Delete from local DB on success
          await db.offlineSales.delete(sale.id!);
          console.log(`Synced offline sale: ${sale.uuid}`);
        } catch (error: any) {
          console.error("Failed to sync sale:", sale.uuid, error);
          await db.offlineSales.update(sale.id!, { 
            status: 'failed',
            errorMessage: error?.message || 'Unknown error'
          });
        }
      }

      // 2. Sync Queue (e.g. created customers)
      const pendingQueue = await db.syncQueue.where('status').equals('pending').toArray();
      
      for (const item of pendingQueue) {
        try {
          await db.syncQueue.update(item.id!, { status: 'syncing' });
          
          if (item.operation === 'create_customer') {
            await api.post("/customers", item.payload);
          }
          
          await db.syncQueue.delete(item.id!);
          console.log(`Synced queue item: ${item.operation}`);
        } catch (error: any) {
          console.error("Failed to sync queue item:", item.operation, error);
          await db.syncQueue.update(item.id!, { 
            status: 'failed',
            errorMessage: error?.message || 'Unknown error'
          });
        }
      }

      if (pendingSales.length > 0 || pendingQueue.length > 0) {
        toast.success("Offline data synced successfully!");
      }
    } catch (error) {
      console.error("Sync process encountered an error:", error);
    }
  };

  return null; // This is a logic-only component
}
