"use client";

import { motion } from "framer-motion";
import { LucideIcon, PackageOpen } from "lucide-react";
import { Button } from "@/components/ui/button";

interface EmptyStateProps {
  icon?: LucideIcon;
  title: string;
  description?: string;
  children?: React.ReactNode;
  action?: {
    label: string;
    onClick: () => void;
    icon?: LucideIcon;
  };
}

export function EmptyState({ icon: Icon = PackageOpen, title, description, children, action }: EmptyStateProps) {
  
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.95 }}
      animate={{ opacity: 1, scale: 1 }}
      className="flex flex-col items-center justify-center px-4 py-16 text-center"
    >
      <div className="mb-6 rounded-full bg-primary-soft p-8 ring-8 ring-primary/5">
        <Icon className="h-12 w-12 text-primary" />
      </div>
      <h3 className="text-xl font-bold tracking-tight mb-2">{title}</h3>
      {description && (
        <p className="text-sm text-muted-foreground max-w-sm mb-8 leading-relaxed">{description}</p>
      )}
      
      {action && (
        <Button onClick={action.onClick} className="h-11 gap-2 px-8 shadow-sm shadow-primary/20">
          {action.icon && <action.icon className="h-4 w-4" />}
          {action.label}
        </Button>
      )}
      
      {children}
    </motion.div>
  );
}
