"use client";

import { motion } from "framer-motion";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { LucideIcon, TrendingUp, TrendingDown } from "lucide-react";
import { formatCurrency } from "@/lib/utils";

interface AnalyticsCardProps {
  title: string;
  value: number | string;
  icon?: LucideIcon;
  color?: "orange" | "emerald" | "slate" | "amber" | "rose" | "violet" | "cyan";
  trend?: {
    value: number;
    isPositive: boolean;
  };
  format?: "currency" | "number" | "percent";
  loading?: boolean;
}

const colorClasses = {
  orange: "text-accent bg-accent/10",
  emerald: "text-success bg-success/10",
  slate: "text-muted-foreground bg-secondary",
  amber: "text-warning bg-warning/10",
  rose: "text-destructive bg-destructive/10",
  violet: "text-primary bg-primary-soft",
  cyan: "text-primary bg-primary-soft",
};

/**
 * Compact currency formatter that abbreviates large values
 * to prevent overflow in tight grid cells.
 * e.g. 6714906 → "₹67.1L", 42796 → "₹42,796"
 */
function formatCompactCurrency(value: number): string {
  const abs = Math.abs(value);
  if (abs >= 10000000) {
    return `₹${(value / 10000000).toFixed(2)}Cr`;
  }
  if (abs >= 100000) {
    return `₹${(value / 100000).toFixed(2)}L`;
  }
  return formatCurrency(value);
}

export function AnalyticsCard({
  title,
  value,
  icon: Icon,
  color = "cyan",
  trend,
  format = "number",
  loading = false,
}: AnalyticsCardProps) {
  const numValue = typeof value === "number" ? value : 0;

  const displayValue =
    format === "currency"
      ? formatCompactCurrency(numValue)
      : format === "percent"
        ? `${numValue.toFixed(2)}%`
        : typeof value === "number"
          ? value.toLocaleString("en-IN")
          : value;

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      className="min-w-0"
    >
      <Card className="relative h-full overflow-hidden border border-border bg-card transition-colors hover:border-primary/30">
        <CardHeader className="pb-1 pt-3 px-3 flex flex-row items-start justify-between space-y-0 gap-1">
          <CardTitle className="text-xs font-medium text-muted-foreground leading-tight">
            {title}
          </CardTitle>
          {Icon && (
            <div className={`p-1.5 rounded-lg shrink-0 ${colorClasses[color]}`}>
              <Icon className="h-3.5 w-3.5" />
            </div>
          )}
        </CardHeader>
        <CardContent className="px-3 pb-3 pt-0">
          <div className="truncate text-xl font-bold tracking-tight leading-tight">
            {loading ? (
              <div className="h-7 w-20 bg-muted rounded animate-pulse" />
            ) : (
              displayValue
            )}
          </div>
          {trend && (
            <div className="flex items-center gap-1 text-[10px] mt-1">
              {trend.isPositive ? (
                <TrendingUp className="h-3 w-3 shrink-0 text-success" />
              ) : (
                <TrendingDown className="h-3 w-3 shrink-0 text-destructive" />
              )}
              <span
                className={
                  trend.isPositive ? "text-success" : "text-destructive"
                }
              >
                {trend.isPositive ? "+" : "-"}
                {Math.abs(trend.value).toFixed(1)}%
              </span>
            </div>
          )}
        </CardContent>
      </Card>
    </motion.div>
  );
}
