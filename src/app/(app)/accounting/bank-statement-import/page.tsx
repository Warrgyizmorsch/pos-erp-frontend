"use client";

import React, { useState, useEffect, useCallback, useMemo } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { ArrowLeft, ArrowDownUp, CheckCircle, FileText, Loader2, Landmark, Plus, Save, AlertTriangle, ShieldCheck, History, Sparkles, ChevronRight, Check, Settings } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Badge } from "@/components/ui/badge";
import { Textarea } from "@/components/ui/textarea";
import { accountingService, type Ledger } from "@/services/accountingService";

export default function BankStatementImportPage() {
  const [bankLedgers, setBankLedgers] = useState<Ledger[]>([]);
  const [allLedgers, setAllLedgers] = useState<Ledger[]>([]);
  const [accountGroups, setAccountGroups] = useState<any[]>([]);
  const [selectedBankLedger, setSelectedBankLedger] = useState<string>("");
  const [file, setFile] = useState<File | null>(null);
  
  const searchParams = useSearchParams();
  const importId = searchParams.get("id");
  
  // State for import preview
  const [isParsing, setIsParsing] = useState(false);
  const [previewData, setPreviewData] = useState<any>(null);
  const [mappings, setMappings] = useState<Record<string, string>>({}); // transactionIndex -> ledgerId
  const [mappingsSource, setMappingsSource] = useState<Record<string, "auto" | "manual" | "none">>({});
  const [filterMode, setFilterMode] = useState<"all" | "auto" | "manual" | "pending">("all");

  // Stepper state for resolving unknown entries
  const [isStepperOpen, setIsStepperOpen] = useState(false);
  const [stepperIndex, setStepperIndex] = useState(0);
  const [unmappedRows, setUnmappedRows] = useState<number[]>([]);
  const [stepperLedgerId, setStepperLedgerId] = useState("");
  const [isSavingRule, setIsSavingRule] = useState(false);

  // Modal state for creating new ledger
  const [isLedgerModalOpen, setIsLedgerModalOpen] = useState(false);
  const [activeMappingRowIndex, setActiveMappingRowIndex] = useState<number | null>(null);
  const [newLedgerName, setNewLedgerName] = useState("");
  const [newLedgerGroupId, setNewLedgerGroupId] = useState("");
  const [newLedgerOpeningBalance, setNewLedgerOpeningBalance] = useState("0");
  const [newLedgerDesc, setNewLedgerDesc] = useState("");
  const [isCreatingLedger, setIsCreatingLedger] = useState(false);

  // Posting state
  const [isPosting, setIsPosting] = useState(false);
  const [postResult, setPostResult] = useState<any>(null);

  // Load ledgers and groups
  const loadData = useCallback(async () => {
    try {
      const ledgersList = await accountingService.getLedgers({ isActive: true });
      setAllLedgers(ledgersList);
      
      // Bank ledgers are typically of type "BANK"
      const banks = ledgersList.filter(l => l.ledgerType === "BANK" || l.groupId?.code === "BANK_ACCOUNTS");
      setBankLedgers(banks);

      const groups = await accountingService.getAccountGroups();
      setAccountGroups(groups.sort((a, b) => a.name.localeCompare(b.name)));
    } catch (err: any) {
      toast.error("Failed to load initial ledger parameters");
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  // Load saved statement details if loading a draft from history
  useEffect(() => {
    if (importId) {
      const loadImportDetails = async () => {
        try {
          setIsParsing(true);
          const data = await accountingService.getBankStatementDetails(importId);
          
          setPreviewData({
            _id: data._id,
            statementNo: data.statementNo,
            fileName: data.fileName,
            bankLedgerId: data.bankLedgerId?._id,
            bankName: data.bankLedgerId?.name,
            transactions: data.transactions,
            summary: {
              totalCount: data.transactions.length,
              duplicateCount: data.transactions.filter((t: any) => t.status === "skipped").length,
              autoMappedCount: 0 // Will compute dynamically
            }
          });
          
          setSelectedBankLedger(data.bankLedgerId?._id || "");
          
          const initialMappings: Record<string, string> = {};
          const initialSources: Record<string, "auto" | "manual" | "none"> = {};
          data.transactions.forEach((txn: any, idx: number) => {
            if (txn.status === "skipped") {
              initialMappings[idx] = "duplicate";
              initialSources[idx] = "none";
            } else if (txn.mappedLedgerId?._id || txn.mappedLedgerId) {
              initialMappings[idx] = txn.mappedLedgerId?._id || txn.mappedLedgerId;
              initialSources[idx] = "auto";
            } else {
              initialMappings[idx] = "";
              initialSources[idx] = "none";
            }
          });
          setMappings(initialMappings);
          setMappingsSource(initialSources);
        } catch (err: any) {
          toast.error("Failed to load saved statement details");
        } finally {
          setIsParsing(false);
        }
      };
      void loadImportDetails();
    }
  }, [importId]);

  // Handle PDF Statement Upload & Parsing
  const handleParseStatement = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!file) {
      toast.error("Please upload a PDF bank statement file");
      return;
    }

    setIsParsing(true);
    setPreviewData(null);
    setMappings({});
    setMappingsSource({});
    setPostResult(null);

    try {
      const data = await accountingService.uploadBankStatement(file, selectedBankLedger);
      setPreviewData(data);
      
      // Auto-select resolved bank ledger
      if (data.bankLedgerId) {
        setSelectedBankLedger(data.bankLedgerId);
      }

      const initialMappings: Record<string, string> = {};
      const initialSources: Record<string, "auto" | "manual" | "none"> = {};
      data.transactions.forEach((txn: any, idx: number) => {
        if (txn.isDuplicate) {
          initialMappings[idx] = "duplicate";
          initialSources[idx] = "none";
        } else if (txn.mappedLedgerId) {
          initialMappings[idx] = txn.mappedLedgerId;
          initialSources[idx] = "auto";
        } else if (data.defaultExpenseLedgerId && txn.debit > 0) {
          initialMappings[idx] = data.defaultExpenseLedgerId;
          initialSources[idx] = "none";
        } else {
          initialMappings[idx] = "";
          initialSources[idx] = "none";
        }
      });
      setMappings(initialMappings);
      setMappingsSource(initialSources);
      toast.success("Statement parsed and auto-matched successfully!");
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Failed to parse PDF statement. Ensure it is a valid search-text PDF.");
    } finally {
      setIsParsing(false);
    }
  };

  // Change individual row mapping selection
  const handleMappingChange = (rowIndex: number, ledgerId: string) => {
    if (ledgerId === "CREATE_NEW_LEDGER") {
      setActiveMappingRowIndex(rowIndex);
      setNewLedgerName("");
      setNewLedgerGroupId("");
      setNewLedgerOpeningBalance("0");
      setNewLedgerDesc("");
      setIsLedgerModalOpen(true);
      return;
    }

    setMappings((prev: Record<string, string>) => ({
      ...prev,
      [rowIndex]: ledgerId
    }));
    setMappingsSource((prev: any) => ({
      ...prev,
      [rowIndex]: ledgerId ? "manual" : "none"
    }));
  };

  // Create new ledger from inside the modal popup
  const handleCreateLedger = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newLedgerName.trim()) {
      toast.error("Please enter a ledger name");
      return;
    }
    if (!newLedgerGroupId) {
      toast.error("Please select an account group");
      return;
    }

    setIsCreatingLedger(true);
    try {
      const payload = {
        name: newLedgerName.trim(),
        groupId: newLedgerGroupId,
        openingBalance: Number(newLedgerOpeningBalance) || 0,
        description: newLedgerDesc.trim(),
        code: `LDG-${Date.now().toString().slice(-6).toUpperCase()}`, // Auto-generated code
        ledgerType: "OTHER"
      };

      const newLedger = await accountingService.createLedger(payload);
      toast.success(`Ledger "${newLedger.name}" created successfully`);
      
      // Refresh ledger lists
      const ledgersList = await accountingService.getLedgers({ isActive: true });
      setAllLedgers(ledgersList);

      // Auto-assign created ledger ID to active row
      if (activeMappingRowIndex !== null) {
        handleMappingChange(activeMappingRowIndex, newLedger._id);
      }

      setIsLedgerModalOpen(false);
      setActiveMappingRowIndex(null);
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Failed to create ledger");
    } finally {
      setIsCreatingLedger(false);
    }
  };

  // Stepper resolution trigger
  const handleStartStepper = () => {
    if (!previewData) return;
    const unmapped = previewData.transactions
      .map((t: any, idx: number) => ({ idx, isDuplicate: t.isDuplicate, mappedId: mappings[idx] }))
      .filter((item: any) => !item.isDuplicate && !item.mappedId)
      .map((item: any) => item.idx);
    
    if (unmapped.length === 0) {
      toast.info("All transactions are already mapped!");
      return;
    }
    setUnmappedRows(unmapped);
    setStepperIndex(0);
    setStepperLedgerId("");
    setIsStepperOpen(true);
  };

  // Save rule & go next in stepper wizard
  const handleStepperSave = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!stepperLedgerId) {
      toast.error("Please select a ledger account");
      return;
    }

    const activeRowIdx = unmappedRows[stepperIndex];
    const activeTxn = previewData.transactions[activeRowIdx];
    
    setIsSavingRule(true);
    try {
      // Create mapping rule pattern instantly on the backend
      await accountingService.createMappingRule({
        pattern: activeTxn.narration,
        ledgerId: stepperLedgerId
      });
      
      // Update page table mappings state
      handleMappingChange(activeRowIdx, stepperLedgerId);
      
      toast.success(`Mapping rule for "${activeTxn.narration}" saved`);

      if (stepperIndex + 1 < unmappedRows.length) {
        setStepperIndex(prev => prev + 1);
        setStepperLedgerId("");
      } else {
        setIsStepperOpen(false);
        toast.success("All unknown transactions resolved!");
      }
    } catch (err: any) {
      toast.error("Failed to save mapping rule. Suggest updating directly in table instead.");
      // Fallback: update state anyway and continue
      handleMappingChange(activeRowIdx, stepperLedgerId);
      if (stepperIndex + 1 < unmappedRows.length) {
        setStepperIndex(prev => prev + 1);
        setStepperLedgerId("");
      } else {
        setIsStepperOpen(false);
      }
    } finally {
      setIsSavingRule(false);
    }
  };

  // Skip step in stepper
  const handleStepperSkip = () => {
    if (stepperIndex + 1 < unmappedRows.length) {
      setStepperIndex(prev => prev + 1);
      setStepperLedgerId("");
    } else {
      setIsStepperOpen(false);
      toast.info("Stepper resolved");
    }
  };

  // Save parsed draft statement to MongoDB, then post mappings
  const handlePostEntries = async () => {
    const transactions = previewData.transactions;
    const pendingMappingCount = transactions.filter((txn: any, idx: number) => {
      return !txn.isDuplicate && !mappings[idx];
    }).length;

    if (pendingMappingCount > 0) {
      toast.error(`Please resolve all ${pendingMappingCount} pending transactions before posting.`);
      return;
    }

    setIsPosting(true);
    try {
      let savedImportId = previewData._id;
      const postPayload: Record<string, string> = {};

      if (previewData._id) {
        // Loaded draft
        transactions.forEach((txn: any, idx: number) => {
          const selectedLedgerId = mappings[idx];
          if (selectedLedgerId && selectedLedgerId !== "duplicate") {
            postPayload[txn._id] = selectedLedgerId;
          }
        });
      } else {
        // Save draft statement import record to history
        const savedImport = await accountingService.saveBankStatement({
          bankLedgerId: selectedBankLedger,
          fileName: previewData.fileName,
          statementNo: previewData.statementNo,
          bank: previewData.bankName,
          transactions: transactions.map((t: any, idx: number) => ({
            ...t,
            mappedLedgerId: mappings[idx] && mappings[idx] !== "duplicate" ? mappings[idx] : undefined
          }))
        });
        savedImportId = savedImport._id;

        savedImport.transactions.forEach((txn: any, idx: number) => {
          const selectedLedgerId = mappings[idx];
          if (selectedLedgerId && selectedLedgerId !== "duplicate") {
            postPayload[txn._id] = selectedLedgerId;
          }
        });
      }

      const result = await accountingService.postMappedStatementEntries(savedImportId, postPayload);
      setPostResult(result);
      toast.success("Statement entries posted successfully!");
      setPreviewData(null);
      setFile(null);
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Failed to post entries to vouchers");
    } finally {
      setIsPosting(false);
    }
  };

  // Compute stats for bulk approval banner
  const stats = useMemo(() => {
    if (!previewData) return null;
    const txns = previewData.transactions;
    const total = txns.length;
    const duplicates = txns.filter((t: any) => t.isDuplicate).length;
    
    let autoMapped = 0;
    let manuallyMapped = 0;
    let pending = 0;

    txns.forEach((txn: any, idx: number) => {
      if (txn.isDuplicate) return;
      const mapped = mappings[idx];
      const source = mappingsSource[idx];
      
      if (!mapped) {
        pending++;
      } else if (source === "auto" || txn.mappedLedgerId) {
        autoMapped++;
      } else {
        manuallyMapped++;
      }
    });

    return { total, duplicates, autoMapped, manuallyMapped, pending };
  }, [previewData, mappings, mappingsSource]);

  const filteredTransactions = useMemo(() => {
    if (!previewData) return [];
    return previewData.transactions
      .map((txn: any, idx: number) => ({ ...txn, originalIndex: idx }))
      .filter((txn: any) => {
        if (txn.isDuplicate) return filterMode === "all";
        
        const mappedId = mappings[txn.originalIndex];
        const source = mappingsSource[txn.originalIndex];
        
        if (filterMode === "auto") {
          return mappedId && (source === "auto" || txn.mappedLedgerId);
        }
        if (filterMode === "manual") {
          return mappedId && source === "manual" && !txn.mappedLedgerId;
        }
        if (filterMode === "pending") {
          return !mappedId;
        }
        return true;
      });
  }, [previewData, filterMode, mappings, mappingsSource]);

  return (
    <div className="container mx-auto p-6 space-y-6 max-w-7xl">
      <div className="flex items-center justify-between">
        <PageHeader 
          title="Bank Statement Import" 
          description="Upload statements and map transactions using fuzzy-learning mapping." 
        />
        <div className="flex items-center gap-3">
          <Link href="/accounting/mapping-rules">
            <Button variant="outline" className="gap-2 bg-card/50">
              <Settings className="h-4 w-4 text-primary" />
              Mapping Rules
            </Button>
          </Link>
          <Link href="/accounting/bank-statement-import/history">
            <Button variant="outline" className="gap-2 bg-card/50">
              <History className="h-4 w-4 text-primary" />
              Import History
            </Button>
          </Link>
        </div>
      </div>

      {postResult && (
        <Card className="border-l-4 border-l-success bg-card border border-border shadow-lg">
          <CardContent className="p-6">
            <div className="flex items-start gap-4">
              <CheckCircle className="h-6 w-6 text-success mt-1 flex-shrink-0" />
              <div className="space-y-2 w-full">
                <h4 className="font-bold text-foreground text-base">Statement Processed & Vouchers Posted</h4>
                <p className="text-sm text-muted-foreground">
                  Transaction details saved to ledger books successfully.
                </p>
                
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6 pt-4 border-t border-border">
                  <div className="bg-background p-4 rounded-lg border border-border">
                    <p className="text-xs text-muted-foreground font-semibold">Vouchers Created</p>
                    <p className="text-2xl font-black mt-1 text-foreground">{postResult.postedCount}</p>
                  </div>
                  <div className="bg-success/10 p-4 rounded-lg border border-success/30">
                    <p className="text-xs text-success font-semibold">Ledger Entries Posted</p>
                    <p className="text-2xl font-black mt-1 text-success">{postResult.postedCount * 2}</p>
                  </div>
                  <div className="bg-warning/10 p-4 rounded-lg border border-warning/30">
                    <p className="text-xs text-warning font-semibold">Status Code</p>
                    <p className="text-lg font-bold mt-1 text-warning uppercase">{postResult.status || "COMPLETED"}</p>
                  </div>
                  <div className="bg-destructive/10 p-4 rounded-lg border border-destructive/30">
                    <p className="text-xs text-destructive font-semibold">Failures/Errors</p>
                    <p className="text-2xl font-black mt-1 text-destructive">{postResult.errorCount}</p>
                  </div>
                </div>

                {postResult.errors && postResult.errors.length > 0 && (
                  <div className="mt-4 p-3 bg-destructive/5 border border-destructive/20 rounded-lg">
                    <p className="text-xs font-bold text-destructive mb-1.5">Posting Failures details:</p>
                    <ul className="text-xs text-destructive space-y-1 list-disc pl-4">
                      {postResult.errors.map((err: any, idx: number) => (
                        <li key={idx}><strong>{err.narration}</strong>: {err.error}</li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Upload and Configuration Form */}
      <Card className="shadow-sm">
        <CardHeader>
          <CardTitle className="text-base font-semibold">Configure Bank Statement Import</CardTitle>
          <CardDescription>Select bank accounts and upload statement in PDF format.</CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleParseStatement} className="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
            <div className="space-y-2">
              <Label htmlFor="bank-ledger" className="text-sm font-semibold">
                Select Bank Ledger
              </Label>
              <Select value={selectedBankLedger} onValueChange={setSelectedBankLedger}>
                <SelectTrigger id="bank-ledger" className="h-10">
                  <SelectValue placeholder="Choose bank account..." />
                </SelectTrigger>
                <SelectContent>
                  {bankLedgers.map(ledger => (
                    <SelectItem key={ledger._id} value={ledger._id}>
                      {ledger.name} ({ledger.code})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="statement-file" className="text-sm font-semibold">
                Statement File (PDF only)
              </Label>
              <Input
                id="statement-file"
                type="file"
                accept=".pdf"
                onChange={(e) => setFile(e.target.files?.[0] || null)}
                className="bg-background cursor-pointer"
              />
            </div>

            <div className="flex flex-col justify-end self-stretch">
              <Button type="submit" disabled={isParsing || !file} className="w-full gap-2 h-10">
                {isParsing ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Parsing Statement...
                  </>
                ) : (
                  <>
                    <ArrowDownUp className="h-4 w-4" />
                    Import & Parse Statement
                  </>
                )}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* Bulk Approval & Mapping Banner */}
      {stats && (
        <Card className="bg-secondary/15 border-border shadow-sm">
          <CardContent className="py-4 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
            <div className="flex flex-wrap items-center gap-6">
              <div>
                <p className="text-xs text-muted-foreground">Total Rows</p>
                <p className="text-lg font-bold">{stats.total}</p>
              </div>
              <div className="h-8 w-px bg-border hidden sm:block" />
              <div>
                <p className="text-xs text-success flex items-center gap-1.5">
                  <Sparkles className="h-3 w-3" />
                  Mapped Automatically
                </p>
                <p className="text-lg font-bold text-success">{stats.autoMapped}</p>
              </div>
              <div className="h-8 w-px bg-border hidden sm:block" />
              <div>
                <p className="text-xs text-info">Mapped Manually</p>
                <p className="text-lg font-bold text-info">{stats.manuallyMapped}</p>
              </div>
              <div className="h-8 w-px bg-border hidden sm:block" />
              <div>
                <p className="text-xs text-warning">Pending Resolve</p>
                <p className="text-lg font-bold text-warning">{stats.pending}</p>
              </div>
              <div className="h-8 w-px bg-border hidden sm:block" />
              <div>
                <p className="text-xs text-muted-foreground">Duplicates Skipped</p>
                <p className="text-lg font-bold text-muted-foreground">{stats.duplicates}</p>
              </div>
            </div>
            {stats.pending > 0 && (
              <Button onClick={handleStartStepper} variant="default" className="gap-2">
                <Sparkles className="h-4 w-4 text-warning animate-pulse" />
                Resolve Unknown Entries ({stats.pending})
              </Button>
            )}
          </CardContent>
        </Card>
      )}

      {/* Parsing Preview Table */}
      {previewData && (
        <Card className="shadow-lg border border-border">
          <CardHeader className="flex flex-col sm:flex-row sm:items-center sm:justify-between border-b border-border pb-4 gap-4">
            <div>
              <CardTitle className="text-base font-bold flex items-center gap-2">
                <FileText className="h-4 w-4 text-primary" />
                Parsed Statement Rows: {previewData.fileName}
              </CardTitle>
              <CardDescription>
                Statement Reference: <span className="font-mono text-foreground font-semibold">{previewData.statementNo}</span>
              </CardDescription>
            </div>
            
            <div className="flex items-center gap-1.5 bg-background p-0.5 rounded-lg border border-border w-fit">
              <Button
                type="button"
                variant={filterMode === "all" ? "secondary" : "ghost"}
                className={`h-7 text-xs px-2.5 rounded-md ${filterMode === "all" ? "bg-secondary text-primary" : ""}`}
                onClick={() => setFilterMode("all")}
              >
                All
              </Button>
              <Button
                type="button"
                variant={filterMode === "auto" ? "secondary" : "ghost"}
                className={`h-7 text-xs px-2.5 rounded-md gap-1 ${filterMode === "auto" ? "bg-secondary text-primary" : ""}`}
                onClick={() => setFilterMode("auto")}
              >
                <Sparkles className="h-3.5 w-3.5 text-success" />
                Auto Mapped
              </Button>
              <Button
                type="button"
                variant={filterMode === "manual" ? "secondary" : "ghost"}
                className={`h-7 text-xs px-2.5 rounded-md ${filterMode === "manual" ? "bg-secondary text-primary" : ""}`}
                onClick={() => setFilterMode("manual")}
              >
                Manually Mapped
              </Button>
              <Button
                type="button"
                variant={filterMode === "pending" ? "secondary" : "ghost"}
                className={`h-7 text-xs px-2.5 rounded-md gap-1 ${filterMode === "pending" ? "bg-secondary text-warning" : "text-warning hover:text-warning"}`}
                onClick={() => setFilterMode("pending")}
              >
                Pending ({stats?.pending})
              </Button>
            </div>
          </CardHeader>
          <CardContent className="p-0 overflow-x-auto">
            {previewData.detectedBank && (
              <div className="m-4 p-3.5 bg-primary-soft/40 dark:bg-primary/5 border border-primary/20 rounded-lg flex items-center gap-3 text-sm text-primary">
                <Sparkles className="h-4.5 w-4.5 text-primary flex-shrink-0 animate-pulse" />
                <span>
                  <strong>{previewData.detectedBank} Bank</strong> statement detected automatically. Account ledger <strong>{previewData.bankName}</strong> pre-selected.
                </span>
              </div>
            )}
            <Table>
              <TableHeader>
                <TableRow className="bg-secondary/20 hover:bg-secondary/20">
                  <TableHead className="w-[120px]">Date</TableHead>
                  <TableHead>Narration</TableHead>
                  <TableHead className="w-[120px] text-right">Debit (DR)</TableHead>
                  <TableHead className="w-[120px] text-right">Credit (CR)</TableHead>
                  <TableHead className="w-[120px] text-right">Balance</TableHead>
                  <TableHead className="w-[300px]">Map to Ledger Account</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredTransactions.map((txn: any) => {
                  const idx = txn.originalIndex;
                  const isDuplicate = txn.isDuplicate;
                  const selectedLedgerId = mappings[idx];
                  const source = mappingsSource[idx];

                  return (
                    <TableRow key={idx} className={isDuplicate ? "opacity-60 bg-muted/10" : ""}>
                      <TableCell className="text-xs font-medium">
                        {new Date(txn.date).toLocaleDateString("en-IN", {
                          day: "2-digit",
                          month: "2-digit",
                          year: "numeric"
                        })}
                      </TableCell>
                      <TableCell className="font-mono text-xs max-w-sm truncate text-foreground" title={txn.narration}>
                        {txn.narration}
                      </TableCell>
                      <TableCell className="text-right text-xs font-semibold text-rose-600">
                        {txn.debit > 0 ? `₹${txn.debit.toFixed(2)}` : "-"}
                      </TableCell>
                      <TableCell className="text-right text-xs font-semibold text-success">
                        {txn.credit > 0 ? `₹${txn.credit.toFixed(2)}` : "-"}
                      </TableCell>
                      <TableCell className="text-right text-xs text-muted-foreground">
                        {txn.balance > 0 ? `₹${txn.balance.toFixed(2)}` : "-"}
                      </TableCell>
                      <TableCell>
                        {isDuplicate ? (
                          <div className="flex items-center gap-1.5 text-xs text-warning bg-warning/10 px-2.5 py-1 rounded-md font-semibold w-fit">
                            <AlertTriangle className="h-3 w-3" />
                            Already Posted (Duplicate Skip)
                          </div>
                        ) : (
                          <div className="space-y-1.5">
                            <Select 
                              value={selectedLedgerId || "NONE"} 
                              onValueChange={(value) => handleMappingChange(idx, value === "NONE" ? "" : value)}
                            >
                              <SelectTrigger 
                                className={`h-9 text-xs ${
                                  !selectedLedgerId ? "border-warning/50 bg-warning/5 text-warning" : "border-border"
                                }`}
                              >
                                <SelectValue placeholder="Select Ledger Account..." />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectItem value="NONE">Select Ledger Account...</SelectItem>
                                <SelectItem value="CREATE_NEW_LEDGER" className="font-bold text-primary">
                                  + Create New Ledger
                                </SelectItem>
                                {allLedgers.map(l => (
                                  <SelectItem key={l._id} value={l._id}>
                                    {l.name}
                                  </SelectItem>
                                ))}
                              </SelectContent>
                            </Select>
                            
                            {selectedLedgerId && selectedLedgerId !== "" && (
                              <div className="flex items-center gap-2">
                                {source === "auto" ? (
                                  <Badge className="bg-success/10 text-success hover:bg-success/20 text-[10px] font-bold border-none px-2 py-0.5 flex items-center gap-1 w-fit">
                                    <Sparkles className="h-2.5 w-2.5 text-success" />
                                    Auto-Suggested
                                  </Badge>
                                ) : (
                                  <Badge className="bg-info/10 text-info hover:bg-info/20 text-[10px] font-bold border-none px-2 py-0.5 flex items-center gap-1 w-fit">
                                    Manually Mapped
                                  </Badge>
                                )}
                              </div>
                            )}
                          </div>
                        )}
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
          <div className="p-4 border-t border-border flex justify-end items-center bg-secondary/15">
            {stats && stats.pending === 0 ? (
              <Button
                onClick={handlePostEntries}
                disabled={isPosting}
                className="gap-2 font-bold text-white"
              >
                {isPosting ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Auto-Posting Entries...
                  </>
                ) : (
                  <>
                    <Sparkles className="h-4 w-4 text-yellow-300 animate-pulse" />
                    One-Click Auto Post
                  </>
                )}
              </Button>
            ) : (
              <Button
                onClick={handlePostEntries}
                disabled={isPosting}
                className="gap-2 shadow-sm font-semibold"
              >
                {isPosting ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Posting Vouchers...
                  </>
                ) : (
                  <>
                    <ShieldCheck className="h-4 w-4" />
                    Post Entries
                  </>
                )}
              </Button>
            )}
          </div>
        </Card>
      )}

      {/* Stepper Resolution Modal Wizard */}
      <Dialog open={isStepperOpen} onOpenChange={setIsStepperOpen}>
        <DialogContent className="max-w-md bg-card border border-border shadow-xl">
          {previewData && unmappedRows.length > 0 && (
            <>
              <DialogHeader>
                <div className="flex items-center justify-between">
                  <DialogTitle className="text-base font-bold flex items-center gap-2">
                    <Sparkles className="h-4 w-4 text-warning" />
                    Resolve Unknown Transactions
                  </DialogTitle>
                  <span className="text-xs font-semibold bg-secondary text-muted-foreground px-2 py-1 rounded">
                    {stepperIndex + 1} of {unmappedRows.length}
                  </span>
                </div>
                <DialogDescription>
                  Train the engine. Auto-creates mapping rules for recurring narrations.
                </DialogDescription>
              </DialogHeader>

              {(() => {
                const activeIdx = unmappedRows[stepperIndex];
                const activeTxn = previewData.transactions[activeIdx];
                const isDebit = activeTxn.debit > 0;
                
                return (
                  <form onSubmit={handleStepperSave} className="space-y-5 pt-3">
                    <div className="bg-background p-4 rounded-lg border border-border space-y-2">
                      <p className="text-[10px] uppercase font-bold text-muted-foreground tracking-wider">Narration</p>
                      <p className="font-mono text-sm font-bold text-foreground leading-tight">
                        {activeTxn.narration}
                      </p>
                      <div className="flex items-center justify-between pt-2 border-t border-border">
                        <div>
                          <p className="text-[10px] uppercase font-bold text-muted-foreground tracking-wider">Date</p>
                          <p className="text-xs font-semibold text-foreground">
                            {new Date(activeTxn.date).toLocaleDateString("en-IN")}
                          </p>
                        </div>
                        <div className="text-right">
                          <p className="text-[10px] uppercase font-bold text-muted-foreground tracking-wider">Amount</p>
                          <p className={`text-sm font-bold ${isDebit ? 'text-rose-600' : 'text-success'}`}>
                            {isDebit ? `₹${activeTxn.debit.toFixed(2)} Dr` : `₹${activeTxn.credit.toFixed(2)} Cr`}
                          </p>
                        </div>
                      </div>
                    </div>

                    <div className="space-y-1">
                      <Label htmlFor="stepper-ledger" className="text-xs font-semibold flex items-center justify-between">
                        <span>Select Ledger Account</span>
                        <button
                          type="button"
                          onClick={() => {
                            setActiveMappingRowIndex(activeIdx);
                            setNewLedgerName("");
                            setNewLedgerGroupId("");
                            setNewLedgerOpeningBalance("0");
                            setNewLedgerDesc("");
                            setIsLedgerModalOpen(true);
                          }}
                          className="text-primary hover:underline flex items-center gap-0.5 text-[10px] font-bold"
                        >
                          <Plus className="h-3 w-3" />
                          Create New
                        </button>
                      </Label>
                      <Select value={stepperLedgerId} onValueChange={setStepperLedgerId}>
                        <SelectTrigger id="stepper-ledger" className="h-9">
                          <SelectValue placeholder="Choose Ledger Account..." />
                        </SelectTrigger>
                        <SelectContent>
                          {allLedgers.map(l => (
                            <SelectItem key={l._id} value={l._id}>
                              {l.name}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <DialogFooter className="flex sm:justify-between items-center pt-2">
                      <Button type="button" variant="ghost" onClick={handleStepperSkip} className="h-9 px-3 text-muted-foreground hover:text-foreground text-xs animate-none transition-all">
                        Skip Transaction
                      </Button>
                      <div className="flex gap-2">
                        <Button type="button" variant="outline" onClick={() => setIsStepperOpen(false)}>
                          Cancel
                        </Button>
                        <Button type="submit" disabled={isSavingRule || !stepperLedgerId} className="gap-1">
                          {isSavingRule ? (
                            <>
                              <Loader2 className="h-4 w-4 animate-spin" />
                              Saving...
                            </>
                          ) : (
                            <>
                              <Check className="h-4 w-4" />
                              Save & Next
                            </>
                          )}
                        </Button>
                      </div>
                    </DialogFooter>
                  </form>
                );
              })()}
            </>
          )}
        </DialogContent>
      </Dialog>

      {/* Create New Ledger Dialog Modal */}
      <Dialog open={isLedgerModalOpen} onOpenChange={setIsLedgerModalOpen}>
        <DialogContent className="max-w-md bg-card border border-border shadow-xl">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Plus className="h-4 w-4 text-primary" />
              Create New Ledger Account
            </DialogTitle>
            <DialogDescription>
              Create ledger immediately. It will be mapped automatically.
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleCreateLedger} className="space-y-4">
            <div className="space-y-1">
              <Label htmlFor="new-ledger-name" className="text-xs font-semibold">Ledger Name</Label>
              <Input
                id="new-ledger-name"
                value={newLedgerName}
                onChange={(e) => setNewLedgerName(e.target.value)}
                placeholder="e.g. Office Expenses A/c"
                className="h-9 text-sm"
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="new-ledger-group" className="text-xs font-semibold">Account Group</Label>
              <Select value={newLedgerGroupId} onValueChange={setNewLedgerGroupId}>
                <SelectTrigger id="new-ledger-group" className="h-9">
                  <SelectValue placeholder="Select Account Group..." />
                </SelectTrigger>
                <SelectContent>
                  {accountGroups.map(group => (
                    <SelectItem key={group._id} value={group._id}>
                      {group.name} ({group.nature})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1">
              <Label htmlFor="new-ledger-balance" className="text-xs font-semibold">Opening Balance (₹)</Label>
              <Input
                id="new-ledger-balance"
                type="number"
                value={newLedgerOpeningBalance}
                onChange={(e) => setNewLedgerOpeningBalance(e.target.value)}
                placeholder="0.00"
                className="h-9 text-sm"
              />
            </div>

            <div className="space-y-1">
              <Label htmlFor="new-ledger-desc" className="text-xs font-semibold">Description</Label>
              <Textarea
                id="new-ledger-desc"
                value={newLedgerDesc}
                onChange={(e) => setNewLedgerDesc(e.target.value)}
                placeholder="Optional notes..."
                className="text-sm min-h-[60px]"
              />
            </div>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setIsLedgerModalOpen(false)}>
                Cancel
              </Button>
              <Button type="submit" disabled={isCreatingLedger} className="gap-1">
                {isCreatingLedger ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4" />
                    Create Ledger
                  </>
                )}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
