"use client";

import { FileText, Landmark, Layers, ListCollapse, Settings } from "lucide-react";
import { EmptyState } from "@/components/shared/EmptyState";
import { PageHeader } from "@/components/shared/PageHeader";

type AccountingIconName = "landmark" | "layers" | "ledgers" | "vouchers" | "settings";

const accountingIcons = {
  landmark: Landmark,
  layers: Layers,
  ledgers: ListCollapse,
  vouchers: FileText,
  settings: Settings,
};

interface AccountingPlaceholderProps {
  title: string;
  description: string;
  icon: AccountingIconName;
  emptyTitle: string;
  emptyDescription: string;
}

export function AccountingPlaceholder({
  title,
  description,
  icon: iconName,
  emptyTitle,
  emptyDescription,
}: AccountingPlaceholderProps) {
  const icon = accountingIcons[iconName];

  return (
    <div className="space-y-6">
      <PageHeader title={title} description={description} icon={icon} />

      <section className="rounded-lg border border-border bg-card">
        <EmptyState
          icon={icon}
          title={emptyTitle}
          description={emptyDescription}
        >
          <div className="rounded-full border border-primary/20 bg-primary/5 px-4 py-2 text-sm font-medium text-primary">
            Foundation ready
          </div>
        </EmptyState>
      </section>
    </div>
  );
}
