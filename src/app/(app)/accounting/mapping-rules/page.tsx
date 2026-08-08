"use client";

import React, { useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { ArrowLeft, Landmark, Loader2, Plus, Save, Edit, Trash2, Search, SlidersHorizontal, Settings } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/shared/PageHeader";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { accountingService, type Ledger } from "@/services/accountingService";

export default function MappingRulesPage() {
  const [rules, setRules] = useState<any[]>([]);
  const [ledgers, setLedgers] = useState<Ledger[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  // Modal State
  const [isOpen, setIsOpen] = useState(false);
  const [selectedRule, setSelectedRule] = useState<any | null>(null); // Null means "Create" mode
  const [pattern, setPattern] = useState("");
  const [ledgerId, setLedgerId] = useState("");
  const [confidence, setConfidence] = useState("100");
  const [isSaving, setIsSaving] = useState(false);

  // Load Rules and Ledgers
  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      const [rulesList, ledgersList] = await Promise.all([
        accountingService.getMappingRules(),
        accountingService.getLedgers({ isActive: true })
      ]);
      setRules(rulesList);
      setLedgers(ledgersList);
    } catch (err: any) {
      toast.error("Failed to load mapping parameters");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  // Open modal for Create
  const handleOpenCreate = () => {
    setSelectedRule(null);
    setPattern("");
    setLedgerId("");
    setConfidence("100");
    setIsOpen(true);
  };

  // Open modal for Edit
  const handleOpenEdit = (rule: any) => {
    setSelectedRule(rule);
    setPattern(rule.pattern);
    setLedgerId(rule.ledgerId?._id || rule.ledgerId || "");
    setConfidence(String(rule.confidence || 100));
    setIsOpen(true);
  };

  // Save Mapping Rule
  const handleSaveRule = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!pattern.trim()) {
      toast.error("Please enter a narration pattern");
      return;
    }
    if (!ledgerId) {
      toast.error("Please select a ledger account");
      return;
    }

    setIsSaving(true);
    try {
      const payload = {
        pattern: pattern.trim().toUpperCase(),
        ledgerId,
        confidence: Number(confidence) || 100
      };

      if (selectedRule) {
        // Edit Mode
        await accountingService.updateMappingRule(selectedRule._id, payload);
        toast.success("Mapping rule updated successfully");
      } else {
        // Create Mode
        await accountingService.createMappingRule(payload);
        toast.success("Mapping rule created successfully");
      }

      setIsOpen(false);
      void loadData();
    } catch (err: any) {
      toast.error(err.response?.data?.message || "Failed to save mapping rule");
    } finally {
      setIsSaving(false);
    }
  };

  // Delete Rule
  const handleDeleteRule = async (id: string) => {
    if (!confirm("Are you sure you want to delete this mapping rule? The system will no longer auto-suggest mappings for this pattern.")) {
      return;
    }

    try {
      await accountingService.deleteMappingRule(id);
      toast.success("Mapping rule deleted successfully");
      void loadData();
    } catch (err: any) {
      toast.error("Failed to delete mapping rule");
    }
  };

  const filteredRules = rules.filter((rule) => {
    const term = search.toLowerCase().trim();
    return (
      rule.pattern.toLowerCase().includes(term) ||
      rule.ledgerName.toLowerCase().includes(term) ||
      rule.groupType.toLowerCase().includes(term)
    );
  });

  return (
    <div className="container mx-auto p-6 space-y-6 max-w-7xl">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Link href="/accounting/bank-statement-import">
            <Button variant="ghost" size="icon" className="border border-border bg-card/50 backdrop-blur-sm">
              <ArrowLeft className="h-4 w-4" />
            </Button>
          </Link>
          <PageHeader 
            title="Mapping Rules" 
            description="Manage auto-suggestion rules mapping transaction keywords to ledger categories." 
          />
        </div>
        <Button onClick={handleOpenCreate} className="gap-2">
          <Plus className="h-4 w-4" />
          Add Rule
        </Button>
      </div>

      <Card className="border border-border bg-card shadow-sm">
        <CardHeader className="pb-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 border-b border-border">
          <div>
            <CardTitle className="text-base font-bold flex items-center gap-2">
              <Settings className="h-4 w-4 text-primary" />
              Narration Mapping Table
            </CardTitle>
            <CardDescription>Rules defining keyword match targets for the import wizard.</CardDescription>
          </div>
          <div className="relative w-full sm:w-72">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search patterns, ledgers..."
              className="pl-9 h-9 text-sm"
            />
          </div>
        </CardHeader>
        <CardContent className="p-0 overflow-x-auto">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-12 gap-2 text-muted-foreground">
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
              <span>Loading rules...</span>
            </div>
          ) : filteredRules.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-16 text-center text-muted-foreground gap-2">
              <SlidersHorizontal className="h-10 w-10 text-muted-foreground/45" />
              <p className="font-semibold text-foreground">No rules found</p>
              <p className="text-xs max-w-xs text-muted-foreground">Add rules manually or mapping transactions in import runs will generate rules automatically.</p>
              <Button size="sm" onClick={handleOpenCreate} className="mt-2">Create First Rule</Button>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow className="bg-secondary/20 hover:bg-secondary/20">
                  <TableHead>Narration Pattern</TableHead>
                  <TableHead>Mapped Ledger</TableHead>
                  <TableHead>Ledger Group</TableHead>
                  <TableHead className="w-[120px] text-center">Confidence</TableHead>
                  <TableHead className="w-[120px] text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredRules.map((rule) => (
                  <TableRow key={rule._id} className="border-b border-border/60 hover:bg-secondary/10">
                    <TableCell className="font-mono text-xs font-semibold text-foreground">
                      {rule.pattern}
                    </TableCell>
                    <TableCell className="font-medium text-xs text-foreground">
                      {rule.ledgerName}
                    </TableCell>
                    <TableCell className="text-xs text-muted-foreground">
                      {rule.groupType}
                    </TableCell>
                    <TableCell className="text-center text-xs font-semibold text-primary">
                      {rule.confidence}%
                    </TableCell>
                    <TableCell className="text-right flex items-center justify-end gap-1.5 h-12">
                      <Button variant="ghost" size="icon" className="h-8 w-8 hover:bg-secondary" onClick={() => handleOpenEdit(rule)}>
                        <Edit className="h-3.5 w-3.5 text-muted-foreground" />
                      </Button>
                      <Button variant="ghost" size="icon" className="h-8 w-8 hover:bg-destructive/10" onClick={() => handleDeleteRule(rule._id)}>
                        <Trash2 className="h-3.5 w-3.5 text-rose-500" />
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Add / Edit Dialog */}
      <Dialog open={isOpen} onOpenChange={setIsOpen}>
        <DialogContent className="max-w-md bg-card border border-border shadow-xl">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Plus className="h-4 w-4 text-primary" />
              {selectedRule ? "Edit Mapping Rule" : "Add Mapping Rule"}
            </DialogTitle>
            <DialogDescription>
              Define matching keywords inside statement narrations to auto-fill accounts.
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleSaveRule} className="space-y-4">
            <div className="space-y-1">
              <Label htmlFor="pattern" className="text-xs font-semibold">Narration Pattern (e.g. AMAZON)</Label>
              <Input
                id="pattern"
                value={pattern}
                onChange={(e) => setPattern(e.target.value)}
                placeholder="AMAZON, SWIGGY, SALARY..."
                className="h-9 text-sm uppercase"
              />
            </div>

            <div className="space-y-1">
               <Label htmlFor="ledger" className="text-xs font-semibold">Map to Ledger</Label>
               <Select value={ledgerId || "NONE"} onValueChange={(value) => setLedgerId(value === "NONE" ? "" : value)}>
                 <SelectTrigger id="ledger" className="h-9">
                   <SelectValue placeholder="Select Ledger..." />
                 </SelectTrigger>
                 <SelectContent>
                   <SelectItem value="NONE">Select Ledger...</SelectItem>
                   {ledgers.map(l => (
                     <SelectItem key={l._id} value={l._id}>
                       {l.name} ({l.code})
                     </SelectItem>
                   ))}
                 </SelectContent>
               </Select>
             </div>

            <div className="space-y-1">
              <Label htmlFor="confidence" className="text-xs font-semibold">Confidence Weight (%)</Label>
              <Input
                id="confidence"
                type="number"
                min="10"
                max="100"
                value={confidence}
                onChange={(e) => setConfidence(e.target.value)}
                placeholder="100"
                className="h-9 text-sm"
              />
            </div>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setIsOpen(false)}>
                Cancel
              </Button>
              <Button type="submit" disabled={isSaving} className="gap-1">
                {isSaving ? (
                  <>
                    <Loader2 className="h-4 w-4 animate-spin" />
                    Saving...
                  </>
                ) : (
                  <>
                    <Save className="h-4 w-4" />
                    Save Rule
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
