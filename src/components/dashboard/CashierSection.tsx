import { useState } from "react";
import { motion } from "framer-motion";
import { Clock, CheckCircle2, XCircle, LayoutGrid, PowerOff } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { formatCurrency } from "@/lib/utils";
import type { DashboardStats } from "@/types";
import Link from "next/link";

export function CashierSection({ stats }: { stats: DashboardStats | null }) {
  const [isEndShiftOpen, setIsEndShiftOpen] = useState(false);
  const shift = stats?.shift;

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h2 className="text-xl font-bold tracking-tight">Cashier Station</h2>
      </div>

      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.1 }}
      >
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <Clock className="h-5 w-5 text-primary" />
                  Shift Status
                </CardTitle>
                <CardDescription>Your current active shift details</CardDescription>
              </div>
              <Badge variant={shift ? "success" : "secondary"}>
                {shift ? "Active Shift" : "No Active Shift"}
              </Badge>
            </div>
          </CardHeader>
          <CardContent>
            {shift ? (
              <div className="space-y-6">
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Shift Number</p>
                    <p className="text-lg font-semibold">{shift.shiftNumber}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Started At</p>
                    <p className="text-lg font-semibold">{new Date(shift.startTime).toLocaleTimeString()}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Starting Cash</p>
                    <p className="text-lg font-semibold text-emerald-500">{formatCurrency(shift.startingCash)}</p>
                  </div>
                  <div>
                    <p className="text-sm font-medium text-muted-foreground">Current Cash</p>
                    <p className="text-lg font-semibold text-emerald-500">{formatCurrency(shift.currentCash)}</p>
                  </div>
                </div>
                
                <div className="flex gap-4 pt-4 border-t border-border/50">
                  <Button asChild className="w-full sm:w-auto">
                    <Link href="/pos">
                      <LayoutGrid className="mr-2 h-4 w-4" /> Open POS
                    </Link>
                  </Button>
                  <Button variant="destructive" className="w-full sm:w-auto" onClick={() => setIsEndShiftOpen(true)}>
                    <PowerOff className="mr-2 h-4 w-4" /> End Shift
                  </Button>
                </div>
              </div>
            ) : (
              <div className="text-center py-8">
                <div className="inline-flex h-12 w-12 items-center justify-center rounded-full bg-muted mb-4">
                  <XCircle className="h-6 w-6 text-muted-foreground" />
                </div>
                <h3 className="text-lg font-medium">You don't have an active shift</h3>
                <p className="text-sm text-muted-foreground mb-4">You need to open a shift to start billing.</p>
                <Button asChild>
                  <Link href="/shifts">Manage Shifts</Link>
                </Button>
              </div>
            )}
          </CardContent>
        </Card>
      </motion.div>

      {/* End Shift Dialog */}
      <Dialog open={isEndShiftOpen} onOpenChange={setIsEndShiftOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>End Shift</DialogTitle>
            <DialogDescription>
              Are you sure you want to end your current shift? You will need to confirm your cash drawer total on the next screen.
            </DialogDescription>
          </DialogHeader>
          <DialogFooter>
            <Button variant="outline" onClick={() => setIsEndShiftOpen(false)}>Cancel</Button>
            <Button asChild variant="destructive">
              <Link href="/shifts">Proceed to End Shift</Link>
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
