"use client";

import React, { useEffect } from "react";
import { getSocket } from "@/lib/socket";
import { useCashBankStore } from "@/store/cashBankStore";
import { toast } from "sonner";
import { logger } from "@/lib/logger";

interface SocketSale {
  _id: string;
  invoiceNo?: string;
  totalAmount: number;
  customerName?: string;
}

interface SocketPurchase {
  _id: string;
  purchaseNo?: string;
  totalAmount: number;
}

interface SocketPaymentIn {
  receiptNo: string;
  amountReceived: number;
  customerName?: string;
}

interface SocketPaymentOut {
  receiptNo: string;
  amountPaid: number;
  supplierName?: string;
}

interface SocketStockLow {
  name: string;
  stock: number;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
type SocketTransaction = Record<string, any>;

export const SyncProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  useEffect(() => {
    const socket = getSocket();

    const handleConnect = () => {
      logger.info("[Sync Provider] Connected to Socket.IO Server!");
      useCashBankStore.getState().setLiveConnected(true);
    };

    const handleDisconnect = () => {
      logger.warn("[Sync Provider] Disconnected from Socket.IO Server!");
      useCashBankStore.getState().setLiveConnected(false);
    };

    const handleSaleCreated = (data: SocketSale) => {
      toast.success(`Sale Created: Invoice #${data.invoiceNo || data._id}`, {
        description: `Total: ₹${Number(data.totalAmount).toLocaleString("en-IN")}${
          data.customerName ? ` for ${data.customerName}` : ""
        }`,
      });
      // Refresh Cash/Bank registries & stats
      useCashBankStore.getState().fetchSummary();
      useCashBankStore.getState().fetchTransactions();
    };

    const handlePurchaseCreated = (data: SocketPurchase) => {
      toast.success(`Purchase Logged: Invoice #${data.purchaseNo || data._id}`, {
        description: `Total: ₹${Number(data.totalAmount).toLocaleString("en-IN")}`,
      });
      useCashBankStore.getState().fetchSummary();
      useCashBankStore.getState().fetchTransactions();
    };

    const handlePaymentInCreated = (data: SocketPaymentIn) => {
      toast.success(`Payment Received: Receipt #${data.receiptNo}`, {
        description: `Amount: ₹${Number(data.amountReceived).toLocaleString("en-IN")} from ${
          data.customerName || "Customer"
        }`,
      });
      useCashBankStore.getState().fetchSummary();
      useCashBankStore.getState().fetchTransactions();
    };

    const handlePaymentOutCreated = (data: SocketPaymentOut) => {
      toast.success(`Payment Paid Out: Receipt #${data.receiptNo}`, {
        description: `Amount: ₹${Number(data.amountPaid).toLocaleString("en-IN")} to ${
          data.supplierName || "Supplier"
        }`,
      });
      useCashBankStore.getState().fetchSummary();
      useCashBankStore.getState().fetchTransactions();
    };

    const handleStockLow = (data: SocketStockLow) => {
      toast.warning(`Low Stock Alert: ${data.name}`, {
        description: `Only ${data.stock} units remaining in stock!`,
        duration: 8000,
      });
    };

    const handleCashBankTransactionCreated = (transaction: SocketTransaction) => {
      if (transaction) {
        useCashBankStore.getState().addLiveTransaction(transaction);
        useCashBankStore.getState().fetchSummary();
      }
    };

    // Attach listeners
    socket.on("connect", handleConnect);
    socket.on("disconnect", handleDisconnect);
    socket.on("sale:created", handleSaleCreated);
    socket.on("purchase:created", handlePurchaseCreated);
    socket.on("paymentIn:created", handlePaymentInCreated);
    socket.on("paymentOut:created", handlePaymentOutCreated);
    socket.on("stock:low", handleStockLow);
    socket.on("cashBank:transactionCreated", handleCashBankTransactionCreated);

    // Initial connection sync check
    if (socket.connected) {
      handleConnect();
    }

    return () => {
      socket.off("connect", handleConnect);
      socket.off("disconnect", handleDisconnect);
      socket.off("sale:created", handleSaleCreated);
      socket.off("purchase:created", handlePurchaseCreated);
      socket.off("paymentIn:created", handlePaymentInCreated);
      socket.off("paymentOut:created", handlePaymentOutCreated);
      socket.off("stock:low", handleStockLow);
      socket.off("cashBank:transactionCreated", handleCashBankTransactionCreated);
    };
  }, []);

  return <>{children}</>;
};
