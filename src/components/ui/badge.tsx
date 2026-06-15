import * as React from "react";
import { cn } from "@/lib/utils";

function Badge({
  className,
  variant = "default",
  ...props
}: React.HTMLAttributes<HTMLDivElement> & {
  variant?:
    | "default"
    | "secondary"
    | "destructive"
    | "outline"
    | "success"
    | "warning"
    | "info";
}) {
  const variants: Record<string, string> = {
    default: "border-transparent bg-primary-soft text-primary",
    secondary: "border-transparent bg-secondary text-secondary-foreground",
    destructive:
      "border-transparent bg-destructive/15 text-destructive",
    outline: "border-border text-foreground",
    success:
      "border-transparent bg-success/15 text-success",
    warning:
      "border-transparent bg-warning/15 text-warning",
    info:
      "border-transparent bg-info/15 text-info",
  };

  return (
    <div
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors",
        variants[variant],
        className,
      )}
      {...props}
    />
  );
}

export { Badge };
