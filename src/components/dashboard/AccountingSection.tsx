import { motion } from "framer-motion";
import { Landmark, Banknote, ListOrdered } from "lucide-react";
import { StatCard } from "@/components/shared/StatCard";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { formatCurrency, formatDate } from "@/lib/utils";
import Link from "next/link";
import type { DashboardStats } from "@/types";

export function AccountingSection({ stats }: { stats: DashboardStats | null }) {
  const accounting = stats?.accounting;
  const recentTransactions = accounting?.recentTransactions || [];

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold tracking-tight">Accounting & Banking</h2>
      </div>

      {/* Stat cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-2">
        <StatCard
          title="Total Cash Balance"
          value={formatCurrency(accounting?.totalCashBalance || 0)}
          icon={Banknote}
          color="emerald"
          href="/cash"
        />
        <StatCard
          title="Total Bank Balance"
          value={formatCurrency(accounting?.totalBankBalance || 0)}
          icon={Landmark}
          color="blue"
          href="/bank"
        />
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.2 }}
      >
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="flex items-center gap-2">
              <ListOrdered className="h-5 w-5 text-indigo-500" />
              Recent Transactions
            </CardTitle>
            <Link href="/cash-bank/transaction-history" className="text-sm text-primary hover:underline font-medium">
              View All
            </Link>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {recentTransactions.length === 0 && (
                <p className="text-sm text-muted-foreground text-center py-8">
                  No recent transactions
                </p>
              )}
              {recentTransactions.map((trx: any) => (
                <div
                  key={trx._id}
                  className="flex items-center justify-between py-2 border-b border-border/50 last:border-0"
                >
                  <div>
                    <p className="text-sm font-medium">{trx.description || "Transaction"}</p>
                    <p className="text-xs text-muted-foreground">
                      {formatDate(trx.date)} • {trx.accountType} {trx.accountId?.name ? `(${trx.accountId.name})` : ''}
                    </p>
                  </div>
                  <div className={`text-sm font-bold ${trx.direction === 'in' ? 'text-green-500' : 'text-red-500'}`}>
                    {trx.direction === 'in' ? '+' : '-'}{formatCurrency(trx.amount)}
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
