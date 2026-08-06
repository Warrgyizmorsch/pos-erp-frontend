"use client";

import React, { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { ArrowLeft, Landmark, Loader2, Plus, Save, Trash2, Settings, ShieldCheck, HelpCircle } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { accountingService, type Ledger } from "@/services/accountingService";

export default function BankImportSettingsPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Form states
  const [defaultBankLedgerId, setDefaultBankLedgerId] = useState("");
  const [defaultExpenseLedgerId, setDefaultExpenseLedgerId] = useState("");
  const [autoPostEnabled, setAutoPostEnabled] = useState(false);
  const [confidenceThreshold, setConfidenceThreshold] = useState(90);
  const [bankMappings, setBankMappings] = useState<Array<{ keyword: string; bankLedgerId: string }>>([]);

  // Ledgers list
  const [bankLedgers, setBankLedgers] = useState<Ledger[]>([]);
  const [allLedgers, setAllLedgers] = useState<Ledger[]>([]);

  // Load initial settings and ledgers
  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [settingsData, ledgersList] = await Promise.all([
        accountingService.getBankImportSettings(),
        accountingService.getLedgers({ isActive: true })
      ]);

      setAllLedgers(ledgersList);
      
      const banks = ledgersList.filter(l => l.ledgerType === "BANK" || l.groupId?.code === "BANK_ACCOUNTS");
      setBankLedgers(banks);

      if (settingsData) {
        setDefaultBankLedgerId(settingsData.defaultBankLedgerId?._id || settingsData.defaultBankLedgerId || "");
        setDefaultExpenseLedgerId(settingsData.defaultExpenseLedgerId?._id || settingsData.defaultExpenseLedgerId || "");
        setAutoPostEnabled(settingsData.autoPostEnabled || false);
        setConfidenceThreshold(settingsData.confidenceThreshold ?? 90);
        
        // Unpack mapping rules
        const rules = (settingsData.bankMappings || []).map((m: any) => ({
          keyword: m.keyword || "",
          bankLedgerId: m.bankLedgerId?._id || m.bankLedgerId || ""
        }));
        setBankMappings(rules);
      }
    } catch (err: any) {
      toast.error("Failed to load bank import configuration settings");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  // Save configurations
  const handleSaveSettings = async (e: React.FormEvent) => {
    e.preventDefault();
    setSaving(true);
    
    // Clean mappings
    const cleanedMappings = bankMappings
      .filter(m => m.keyword.trim() && m.bankLedgerId)
      .map(m => ({
        keyword: m.keyword.trim().toUpperCase(),
        bankLedgerId: m.bankLedgerId
      }));

    // Perform validation
    if (autoPostEnabled && !defaultBankLedgerId) {
      toast.error("Default Bank Account is required for Auto-Posting Mode.");
      setSaving(false);
      return;
    }

    try {
      const payload = {
        defaultBankLedgerId: defaultBankLedgerId || null,
        defaultExpenseLedgerId: defaultExpenseLedgerId || null,
        autoPostEnabled,
        confidenceThreshold: Number(confidenceThreshold) || 90,
        bankMappings: cleanedMappings
      };

      await accountingService.updateBankImportSettings(payload);
      toast.success("Bank import settings saved successfully");
      void loadData();
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Failed to update import configuration");
    } finally {
      setSaving(false);
    }
  };

  const handleAddMappingRow = () => {
    setBankMappings(prev => [...prev, { keyword: "", bankLedgerId: "" }]);
  };

  const handleRemoveMappingRow = (index: number) => {
    setBankMappings(prev => prev.filter((_, idx) => idx !== index));
  };

  const handleMappingChange = (index: number, field: "keyword" | "bankLedgerId", value: string) => {
    setBankMappings(prev => prev.map((item, idx) => {
      if (idx === index) {
        return { ...item, [field]: value };
      }
      return item;
    }));
  };

  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[50vh] gap-3 text-slate-500">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <span>Loading Bank Import Settings...</span>
      </div>
    );
  }

  return (
    <div className="container mx-auto p-6 space-y-6 max-w-5xl">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/accounting/bank-statement-import">
            <Button variant="ghost" size="icon" className="border border-border bg-card/50 backdrop-blur-sm">
              <ArrowLeft className="h-4 w-4" />
            </Button>
          </Link>
          <PageHeader 
            title="Bank Import Settings" 
            description="Configure global default accounts, confidence thresholds, and automatic bank detection mappings." 
          />
        </div>
      </div>

      <form onSubmit={handleSaveSettings} className="space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Default Account Mapping Configurations */}
          <Card className="md:col-span-2 shadow-sm">
            <CardHeader className="border-b pb-4">
              <CardTitle className="text-base font-bold flex items-center gap-2">
                <Landmark className="h-4 w-4 text-primary" />
                Default Account Assignments
              </CardTitle>
              <CardDescription>Configure fallbacks for unrecognized statements or auto-detected categories.</CardDescription>
            </CardHeader>
            <CardContent className="p-6 space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="space-y-1">
                  <Label htmlFor="defaultBank" className="text-xs font-semibold">
                    Default Bank Account (Ledger)
                  </Label>
                  <Select value={defaultBankLedgerId || "NONE"} onValueChange={(value) => setDefaultBankLedgerId(value === "NONE" ? "" : value)}>
                    <SelectTrigger id="defaultBank" className="h-9">
                      <SelectValue placeholder="Select Default Bank Ledger..." />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="NONE">Select Default Bank Ledger...</SelectItem>
                      {bankLedgers.map(l => (
                        <SelectItem key={l._id} value={l._id}>
                          {l.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <p className="text-[10px] text-muted-foreground">Used if statement upload doesn't specify a bank ledger.</p>
                </div>

                <div className="space-y-1">
                  <Label htmlFor="defaultExpense" className="text-xs font-semibold">
                    Default Expense Account (Ledger)
                  </Label>
                  <Select value={defaultExpenseLedgerId || "NONE"} onValueChange={(value) => setDefaultExpenseLedgerId(value === "NONE" ? "" : value)}>
                    <SelectTrigger id="defaultExpense" className="h-9">
                      <SelectValue placeholder="Select Default Expense Ledger..." />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="NONE">Select Default Expense Ledger...</SelectItem>
                      {allLedgers.map(l => (
                        <SelectItem key={l._id} value={l._id}>
                          {l.name} ({l.groupId?.name || "Other"})
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <p className="text-[10px] text-muted-foreground">Pre-populated in wizard when no matching narration rule is found.</p>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Engine Parameters Card */}
          <Card className="shadow-sm">
            <CardHeader className="border-b border-border pb-4">
              <CardTitle className="text-base font-bold flex items-center gap-2">
                <Settings className="h-4 w-4 text-primary" />
                Posting Controls
              </CardTitle>
              <CardDescription>Set accuracy limits and posting toggles.</CardDescription>
            </CardHeader>
            <CardContent className="p-6 space-y-4">
              <div className="space-y-2">
                <Label htmlFor="confidence" className="text-xs font-semibold">
                  Confidence Match Threshold ({confidenceThreshold}%)
                </Label>
                <div className="flex items-center gap-3">
                  <input
                    type="range"
                    id="confidence"
                    min="50"
                    max="100"
                    step="5"
                    className="flex-1 accent-primary h-1.5 bg-secondary rounded-lg cursor-pointer"
                    value={confidenceThreshold}
                    onChange={(e) => setConfidenceThreshold(Number(e.target.value))}
                  />
                  <span className="font-mono text-sm font-semibold w-10 text-right">{confidenceThreshold}%</span>
                </div>
                <p className="text-[10px] text-muted-foreground leading-tight">Rules below this threshold are shown as low confidence suggestions in the review pane.</p>
              </div>

              <div className="border-t border-border pt-4 flex items-start gap-3">
                <input
                  type="checkbox"
                  id="autoPost"
                  className="mt-1 h-4 w-4 accent-primary rounded border-border focus:ring-primary cursor-pointer"
                  checked={autoPostEnabled}
                  onChange={(e) => setAutoPostEnabled(e.target.checked)}
                />
                <div className="space-y-0.5">
                  <Label htmlFor="autoPost" className="text-xs font-semibold cursor-pointer">
                    Enable One-Click Bulk Post
                  </Label>
                  <p className="text-[10px] text-muted-foreground leading-tight">Allows bypassing the stepper if 100% of transactions match existing narration rules with high confidence.</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Bank Identifier Keyword Rules */}
        <Card className="shadow-sm">
          <CardHeader className="pb-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-border">
            <div>
              <CardTitle className="text-base font-bold flex items-center gap-2">
                <ShieldCheck className="h-4 w-4 text-primary" />
                Automatic Bank Detection Mappings
              </CardTitle>
              <CardDescription>Associate keywords parsed from PDF contents with their corresponding Bank ledger accounts.</CardDescription>
            </div>
            <Button type="button" onClick={handleAddMappingRow} variant="outline" size="sm" className="gap-1">
              <Plus className="h-3.5 w-3.5" />
              Add Bank Rule
            </Button>
          </CardHeader>
          <CardContent className="p-0 overflow-x-auto">
            {bankMappings.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-center text-muted-foreground gap-2">
                <HelpCircle className="h-10 w-10 text-muted-foreground/60" />
                <p className="font-semibold text-sm">No Bank Mappings Configured</p>
                <p className="text-xs max-w-md">Add rules below to auto-select bank accounts. E.g., if PDF contains keyword "HDFC", select HDFC Bank ledger automatically.</p>
                <Button type="button" size="sm" variant="ghost" onClick={handleAddMappingRow} className="mt-2 text-primary">Configure First Mapping</Button>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow className="bg-secondary/20 hover:bg-secondary/20">
                    <TableHead className="w-1/2">Bank Keyword (Detected in PDF Text)</TableHead>
                    <TableHead className="w-1/2">Target Bank Ledger Account</TableHead>
                    <TableHead className="w-[80px] text-right"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {bankMappings.map((mapping, idx) => (
                    <TableRow key={idx}>
                      <TableCell className="p-4">
                        <Input
                          placeholder="e.g. HDFC, ICICI, SBI, AXIS"
                          value={mapping.keyword}
                          onChange={(e) => handleMappingChange(idx, "keyword", e.target.value)}
                          className="h-9 font-mono text-sm uppercase"
                        />
                      </TableCell>
                      <TableCell className="p-4">
                        <Select value={mapping.bankLedgerId || "NONE"} onValueChange={(value) => handleMappingChange(idx, "bankLedgerId", value === "NONE" ? "" : value)}>
                          <SelectTrigger className="h-9">
                            <SelectValue placeholder="Select Target Bank Ledger..." />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectItem value="NONE">Select Target Bank Ledger...</SelectItem>
                            {bankLedgers.map(l => (
                              <SelectItem key={l._id} value={l._id}>
                                {l.name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </TableCell>
                      <TableCell className="p-4 text-right">
                        <Button 
                          type="button" 
                          variant="ghost" 
                          size="icon" 
                          onClick={() => handleRemoveMappingRow(idx)}
                          className="h-8 w-8 hover:bg-destructive/10 text-destructive"
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>

        {/* Action Button footer */}
        <div className="flex items-center justify-end gap-3 pt-2">
          <Link href="/accounting/bank-statement-import">
            <Button type="button" variant="outline">
              Cancel
            </Button>
          </Link>
          <Button type="submit" disabled={saving} className="gap-2 px-6">
            {saving ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Saving settings...
              </>
            ) : (
              <>
                <Save className="h-4 w-4" />
                Save Configurations
              </>
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}
