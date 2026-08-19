import { motion } from "framer-motion";
import { Package, AlertTriangle, PlusCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { StatCard } from "@/components/shared/StatCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import Link from "next/link";
import type { DashboardStats } from "@/types";

export function InventorySection({ stats }: { stats: DashboardStats | null }) {
  const lowStockProducts = stats?.lowStockProducts ?? [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold tracking-tight">Inventory</h2>
      </div>

      {/* Stat cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-2">
        <StatCard
          title="Total Products"
          value={stats?.totalProducts || 0}
          icon={Package}
          color="slate"
          href="/products"
        />
        <StatCard
          title="Low Stock Alerts"
          value={lowStockProducts.length}
          subtitle="Items need restock"
          icon={AlertTriangle}
          color="rose"
          href="/inventory"
        />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-amber-500" />
              Low Stock Alerts
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {lowStockProducts.length === 0 && (
                <p className="text-sm text-muted-foreground text-center py-8">
                  All products are well stocked
                </p>
              )}
              {lowStockProducts.map((product) => (
                <div
                  key={product._id}
                  className="flex items-center justify-between py-2 border-b border-border/50 last:border-0"
                >
                  <div>
                    <p className="text-sm font-medium">{product.name}</p>
                    <p className="text-xs text-muted-foreground">{product.sku}</p>
                  </div>
                  <div className="flex items-center gap-3">
                    <Badge variant={product.stock === 0 ? "destructive" : "warning"}>
                      {product.stock === 0 ? "Out of stock" : `${product.stock} left`}
                    </Badge>
                    <Button size="sm" variant="outline" asChild>
                      <Link href="/purchases/create">
                        <PlusCircle className="h-4 w-4 mr-2" /> Restock
                      </Link>
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </motion.div>
    </div>
  );
}
