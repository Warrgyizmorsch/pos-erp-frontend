"use client";

import React, { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { ArrowLeft, ArrowDownUp, CheckCircle, FileText, Loader2, Eye, Calendar, Building, List } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { accountingService } from "@/services/accountingService";

export default function BankStatementImportHistoryPage() {
  const [history, setHistory] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchHistory = useCallback(async () => {
    try {
      setLoading(true);
      const data = await accountingService.getBankStatementHistory();
      setHistory(data);
    } catch (err: any) {
      toast.error("Failed to load bank statement import history");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void fetchHistory();
  }, [fetchHistory]);

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "completed":
        return <Badge className="bg-success/10 text-success hover:bg-success/20 font-semibold border-none">Completed</Badge>;
      case "partially_posted":
        return <Badge className="bg-warning/10 text-warning hover:bg-warning/20 font-semibold border-none">Partially Posted</Badge>;
      default:
        return <Badge className="bg-muted/15 text-muted-foreground hover:bg-muted/25 font-semibold border-none">Pending Map</Badge>;
    }
  };

  return (
    <div className="container mx-auto p-6 space-y-6 max-w-7xl">
      <div className="flex items-center gap-4">
        <Link href="/accounting/bank-statement-import">
          <Button variant="ghost" size="icon" className="border border-border bg-card/50 backdrop-blur-sm">
            <ArrowLeft className="h-4 w-4" />
          </Button>
        </Link>
        <PageHeader 
          title="Bank Import History" 
          description="Track past statement uploads, mapping runs, and posted transactions." 
        />
      </div>

      <Card className="shadow-sm">
        <CardHeader className="pb-2">
          <CardTitle className="text-base font-bold flex items-center gap-2">
            <List className="h-4 w-4 text-primary" />
            Historical Statement Runs
          </CardTitle>
          <CardDescription>View status of statement imports or map pending transactions.</CardDescription>
        </CardHeader>
        <CardContent className="p-0 overflow-x-auto">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-12 gap-2 text-muted-foreground">
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
              <span>Loading import logs...</span>
            </div>
          ) : history.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center text-muted-foreground gap-2">
              <FileText className="h-10 w-10 text-muted-foreground/60" />
              <p className="font-semibold text-foreground">No imports found</p>
              <p className="text-xs max-w-xs text-muted-foreground">Upload your first bank statement file to get started.</p>
              <Link href="/accounting/bank-statement-import" className="mt-2">
                <Button size="sm">Import Statement</Button>
              </Link>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow className="bg-secondary/20 hover:bg-secondary/20">
                  <TableHead className="w-[180px]">Run Number</TableHead>
                  <TableHead>Filename</TableHead>
                  <TableHead>Target Bank Account</TableHead>
                  <TableHead className="w-[150px]">Import Date</TableHead>
                  <TableHead className="w-[120px] text-center">Rows</TableHead>
                  <TableHead className="w-[150px]">Status</TableHead>
                  <TableHead className="w-[140px] text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {history.map((record: any) => (
                  <TableRow key={record._id}>
                    <TableCell className="font-mono text-xs font-semibold text-foreground">
                      {record.statementNo}
                    </TableCell>
                    <TableCell className="max-w-[200px] truncate" title={record.fileName}>
                      {record.fileName}
                    </TableCell>
                    <TableCell className="text-xs">
                      <div className="flex items-center gap-1.5 font-medium text-foreground">
                        <Building className="h-3.5 w-3.5 text-muted-foreground" />
                        {record.bankLedgerId?.name || "Unspecified Bank"}
                      </div>
                    </TableCell>
                    <TableCell className="text-xs text-muted-foreground">
                      <div className="flex items-center gap-1.5">
                        <Calendar className="h-3.5 w-3.5 text-muted-foreground" />
                        {new Date(record.importDate).toLocaleDateString("en-IN", {
                          day: "2-digit",
                          month: "2-digit",
                          year: "numeric"
                        })}
                      </div>
                    </TableCell>
                    <TableCell className="text-center text-xs font-semibold text-foreground">
                      {record.transactions?.length || 0}
                    </TableCell>
                    <TableCell>{getStatusBadge(record.status)}</TableCell>
                    <TableCell className="text-right">
                      <Link href={`/accounting/bank-statement-import?id=${record._id}`}>
                        <Button variant="ghost" size="sm" className="gap-1 h-8 text-primary hover:text-primary">
                          <Eye className="h-3.5 w-3.5" />
                          {record.status === "completed" ? "View" : "Map & Post"}
                        </Button>
                      </Link>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
