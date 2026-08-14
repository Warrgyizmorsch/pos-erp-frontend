"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import {
  ShoppingCart,
  DollarSign,
  Package,
  Users,
  AlertTriangle,
  TrendingUp,
  ArrowUpRight,
} from "lucide-react";
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  BarChart,
  Bar,
} from "recharts";
import { StatCard } from "@/components/shared/StatCard";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CardSkeleton } from "@/components/shared/LoadingSkeleton";
import { saleService } from "@/services/saleService";
import { useAuthStore } from "@/store/authStore";
import type { DashboardStats } from "@/types";
import { toast } from "sonner";

import { SalesSection } from "@/components/dashboard/SalesSection";
import { InventorySection } from "@/components/dashboard/InventorySection";
import { AccountingSection } from "@/components/dashboard/AccountingSection";
import { CashierSection } from "@/components/dashboard/CashierSection";

const monthNames = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

export default function DashboardPage() {
  const { user } = useAuthStore();
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const loadStats = async () => {
      try {
        const data = await saleService.getDashboardStats();
        setStats(data);
      } catch (error) {
        console.error("Failed to load dashboard stats:", error);
        toast.error("Failed to load dashboard stats");
      } finally {
        setLoading(false);
      }
    };

    void loadStats();
  }, []);

  // Helper for permission checks
  const hasPermission = (module: string) => {
    return user?.permissions?.includes(module) || user?.role === 'admin';
  };

  const showSales = hasPermission('sales') || hasPermission('dashboard');
  const showInventory = hasPermission('inventory') || hasPermission('products');
  const showAccounting = hasPermission('accounting') || hasPermission('bank') || hasPermission('cash-bank');
  const showCashier = hasPermission('shifts') || hasPermission('pos');

  if (loading) {
    return (
      <div className="space-y-6">
        <PageHeader
          title="Dashboard"
          description="Overview of your business"
          icon={TrendingUp}
        />
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <CardSkeleton key={i} />
          ))}
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-12 pb-10">
      <PageHeader
        title="Dashboard"
        description={`Overview of your business performance (Role: ${user?.role})`}
        icon={TrendingUp}
      />

      {showSales && (
        <div>
          <SalesSection stats={stats} />
        </div>
      )}

      {showInventory && (
        <div className="pt-6 border-t border-border/50">
          <InventorySection stats={stats} />
        </div>
      )}

      {showAccounting && (
        <div className="pt-6 border-t border-border/50">
          <AccountingSection stats={stats} />
        </div>
      )}

      {showCashier && (
        <div className="pt-6 border-t border-border/50">
          <CashierSection stats={stats} />
        </div>
      )}

      {!showSales && !showInventory && !showAccounting && !showCashier && (
        <div className="text-center py-12 text-muted-foreground">
          You don't have permission to view any dashboard widgets.
        </div>
      )}
    </div>
  );
}
