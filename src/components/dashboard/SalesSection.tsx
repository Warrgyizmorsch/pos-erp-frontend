import { useState } from "react";
import { motion } from "framer-motion";
import { ShoppingCart, DollarSign, Users, TrendingUp, ArrowUpRight, Eye } from "lucide-react";
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
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { formatCurrency, formatDate } from "@/lib/utils";
import type { DashboardStats, Sale } from "@/types";

const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

export function SalesSection({ stats }: { stats: DashboardStats | null }) {
  const [selectedSale, setSelectedSale] = useState<Sale | null>(null);
  const [isSaleDialogOpen, setIsSaleDialogOpen] = useState(false);

  // Generate last 6 months
  const generateLast6Months = () => {
    const data = [];
    const today = new Date();
    for (let i = 5; i >= 0; i--) {
      const d = new Date(today.getFullYear(), today.getMonth() - i, 1);
      data.push({
        month: d.getMonth() + 1,
        year: d.getFullYear(),
        name: monthNames[d.getMonth()],
        revenue: 0,
        sales: 0
      });
    }
    return data;
  };

  const baseChartData = generateLast6Months();
  const salesChartData = baseChartData.map(baseItem => {
    const found = (stats?.salesByMonth ?? []).find(
      (s: any) => s._id.month === baseItem.month && s._id.year === baseItem.year
    );
    if (found) {
      return { ...baseItem, revenue: found.totalRevenue, sales: found.totalSales };
    }
    return baseItem;
  });

  // Generate last 7 days
  const generateLast7Days = () => {
    const data = [];
    const today = new Date();
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      // adjust for local timezone offset to get correct YYYY-MM-DD
      const offset = d.getTimezoneOffset();
      const localDate = new Date(d.getTime() - (offset * 60 * 1000));
      const dateString = localDate.toISOString().split('T')[0];
      
      data.push({
        dateString,
        name: d.toLocaleDateString("en-IN", { weekday: "short" }),
        revenue: 0,
        sales: 0
      });
    }
    return data;
  };

  const baseDailyData = generateLast7Days();
  const dailyChartData = baseDailyData.map(baseItem => {
    const found = (stats?.salesByDay ?? []).find((s: any) => s._id === baseItem.dateString);
    if (found) {
      return { ...baseItem, revenue: found.totalRevenue, sales: found.totalSales };
    }
    return baseItem;
  });

  const recentSales = stats?.recentSales ?? [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold tracking-tight">Sales & Revenue</h2>
      </div>
      
      {/* Stat cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        <StatCard
          title="Today's Sales"
          value={stats?.today?.totalSales || 0}
          subtitle={formatCurrency(stats?.today?.totalRevenue || 0)}
          icon={ShoppingCart}
          color="orange"
          href="/sales"
        />
        <StatCard
          title="Monthly Revenue"
          value={formatCurrency(stats?.monthly?.totalRevenue || 0)}
          subtitle={`${stats?.monthly?.totalSales || 0} orders`}
          icon={DollarSign}
          color="emerald"
          href="/reports"
        />
        <StatCard
          title="Customers"
          value={stats?.totalCustomers || 0}
          icon={Users}
          color="amber"
          href="/customers"
        />
      </div>

      {/* Charts */}
      <div className="grid gap-6 lg:grid-cols-2">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <TrendingUp className="h-5 w-5 text-primary" />
                Revenue Overview
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%" minWidth={0}>
                  <AreaChart
                    data={
                      salesChartData.length > 0
                        ? salesChartData
                        : [{ month: 0, year: 0, name: "No data", revenue: 0, sales: 0 }]
                    }
                  >
                    <defs>
                      <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#f97316" stopOpacity={0.3} />
                        <stop offset="95%" stopColor="#f97316" stopOpacity={0} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                    <XAxis dataKey="name" className="text-xs" tick={{ fill: "var(--muted-foreground)" }} />
                    <YAxis className="text-xs" tick={{ fill: "var(--muted-foreground)" }} />
                    <Tooltip
                      formatter={(value: any) => formatCurrency(Number(value) || 0)}
                      contentStyle={{
                        backgroundColor: "var(--card)",
                        border: "1px solid var(--border)",
                        borderRadius: "12px",
                        color: "var(--foreground)",
                      }}
                    />
                    <Area
                      type="monotone"
                      dataKey="revenue"
                      stroke="#f97316"
                      strokeWidth={2}
                      fill="url(#revenueGradient)"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </motion.div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
        >
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <ShoppingCart className="h-5 w-5 text-emerald-500" />
                Daily Sales (Last 7 Days)
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%" minWidth={0}>
                  <BarChart
                    data={
                      dailyChartData.length > 0
                        ? dailyChartData
                        : [{ dateString: "", name: "No data", revenue: 0, sales: 0 }]
                    }
                  >
                    <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                    <XAxis dataKey="name" className="text-xs" tick={{ fill: "var(--muted-foreground)" }} />
                    <YAxis className="text-xs" tick={{ fill: "var(--muted-foreground)" }} />
                    <Tooltip
                      formatter={(value: any) => formatCurrency(Number(value) || 0)}
                      contentStyle={{
                        backgroundColor: "var(--card)",
                        border: "1px solid var(--border)",
                        borderRadius: "12px",
                        color: "var(--foreground)",
                      }}
                    />
                    <Bar dataKey="revenue" fill="#22c55e" radius={[6, 6, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </CardContent>
          </Card>
        </motion.div>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.4 }}
      >
        <Card>
          <CardHeader>
            <CardTitle>Recent Sales</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentSales.length === 0 && (
                <p className="text-sm text-muted-foreground text-center py-8">
                  No sales yet
                </p>
              )}
              {recentSales.slice(0, 6).map((sale) => (
                <div
                  key={sale._id}
                  className="flex items-center justify-between py-2 border-b border-border/50 last:border-0"
                >
                  <div className="flex items-center gap-3">
                    <div className="flex h-9 w-9 items-center justify-center rounded-full bg-primary/10">
                      <ArrowUpRight className="h-4 w-4 text-primary" />
                    </div>
                    <div>
                      <p className="text-sm font-medium">{sale.customerName}</p>
                      <p className="text-xs text-muted-foreground">{sale.invoiceNumber}</p>
                    </div>
                  </div>
                  <div className="text-right flex items-center gap-3">
                    <div>
                      <p className="text-sm font-semibold">{formatCurrency(sale.totalAmount)}</p>
                      <p className="text-xs text-muted-foreground">{formatDate(sale.createdAt)}</p>
                    </div>
                    <Button 
                      variant="ghost" 
                      size="icon"
                      onClick={() => {
                        setSelectedSale(sale);
                        setIsSaleDialogOpen(true);
                      }}
                    >
                      <Eye className="h-4 w-4" />
                    </Button>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </motion.div>

      {/* Sale Details Dialog */}
      <Dialog open={isSaleDialogOpen} onOpenChange={setIsSaleDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Sale Details</DialogTitle>
          </DialogHeader>
          {selectedSale && (
            <div className="space-y-4">
              <div className="flex justify-between items-center pb-4 border-b">
                <div>
                  <p className="text-sm text-muted-foreground">Invoice</p>
                  <p className="font-medium">{selectedSale.invoiceNumber}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm text-muted-foreground">Date</p>
                  <p className="font-medium">{formatDate(selectedSale.createdAt)}</p>
                </div>
              </div>
              <div className="flex justify-between items-center pb-4 border-b">
                <div>
                  <p className="text-sm text-muted-foreground">Customer</p>
                  <p className="font-medium">{selectedSale.customerName}</p>
                </div>
                <div className="text-right">
                  <p className="text-sm text-muted-foreground">Payment Status</p>
                  <Badge variant={selectedSale.paymentStatus === 'paid' ? 'success' : 'warning'}>
                    {selectedSale.paymentStatus}
                  </Badge>
                </div>
              </div>
              <div>
                <p className="font-medium mb-2">Items</p>
                <div className="space-y-2">
                  {selectedSale.items?.map((item: any, i: number) => (
                    <div key={i} className="flex justify-between text-sm">
                      <span>{item.quantity}x {item.name || item.itemName}</span>
                      <span>{formatCurrency(item.total)}</span>
                    </div>
                  ))}
                </div>
              </div>
              <div className="pt-4 border-t flex justify-between font-bold text-lg">
                <span>Total</span>
                <span>{formatCurrency(selectedSale.totalAmount)}</span>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
