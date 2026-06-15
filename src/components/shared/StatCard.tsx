"use client";

import { motion } from "framer-motion";
import { LucideIcon } from "lucide-react";
import { cn } from "@/lib/utils";

interface StatCardProps {
  title: string;
  value: string | number;
  subtitle?: string;
  icon: LucideIcon;
  trend?: { value: number; label: string };
  color?: "orange" | "indigo" | "slate" | "emerald" | "amber" | "rose" | "blue";
  className?: string;
}

const colorMap = {
  orange:
    "from-accent/10 to-accent/5 text-accent border-accent/20",
  indigo:
    "from-primary/10 to-primary/5 text-primary border-primary/20",
  emerald:
    "from-success/10 to-success/5 text-success border-success/20",
  slate:
    "from-secondary to-secondary/40 text-muted-foreground border-border",
  amber:
    "from-warning/10 to-warning/5 text-warning border-warning/20",
  rose: "from-destructive/10 to-destructive/5 text-destructive border-destructive/20",
  blue: "from-info/10 to-info/5 text-info border-info/20",
};

const iconBgMap = {
  orange: "bg-accent/10 text-accent",
  indigo: "bg-primary-soft text-primary",
  emerald: "bg-success/10 text-success",
  slate: "bg-secondary text-muted-foreground",
  amber: "bg-warning/10 text-warning",
  rose: "bg-destructive/10 text-destructive",
  blue: "bg-info/10 text-info",
};

export function StatCard({
  title,
  value,
  subtitle,
  icon: Icon,
  trend,
  color = "indigo",
  className,
}: StatCardProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4 }}
      whileHover={{ y: -2, transition: { duration: 0.2 } }}
      className={cn(
        "relative overflow-hidden rounded-lg border bg-gradient-to-br p-5 transition-shadow duration-300 hover:shadow-md",
        colorMap[color],
        className,
      )}
    >
      <div className="flex items-start justify-between">
        <div className="space-y-1.5">
          <p className="text-sm font-medium text-muted-foreground">{title}</p>
          <p className="text-lg font-semibold tracking-tight text-foreground">
            {value}
          </p>
          {subtitle && (
            <p className="text-xs text-muted-foreground">{subtitle}</p>
          )}
          {trend && (
            <div className="flex items-center gap-1">
              <span
                className={cn(
                  "text-xs font-medium",
                  trend.value >= 0
                    ? "text-success"
                    : "text-destructive",
                )}
              >
                {trend.value >= 0 ? "+" : ""}
                {trend.value}%
              </span>
              <span className="text-xs text-muted-foreground">
                {trend.label}
              </span>
            </div>
          )}
        </div>
        <div
          className={cn(
            "absolute right-2 top-2 rounded-lg p-3",
            iconBgMap[color],
          )}
        >
          <Icon className="h-6 w-6" />
        </div>
      </div>
    </motion.div>
  );
}
