"use client";

import { useEffect, useState, useCallback } from "react";
import { motion } from "framer-motion";
import { IndianRupee, Plus, Pencil, Trash2, Loader2 } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/shared/PageHeader";
import { SearchInput } from "@/components/shared/SearchInput";
import { EmptyState } from "@/components/shared/EmptyState";
import { ConfirmDialog } from "@/components/shared/ConfirmDialog";
import { TableSkeleton } from "@/components/shared/LoadingSkeleton";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { expenseService } from "@/services/expenseService";
import type { LedgerOption } from "@/services/expenseService";
import { cashBankService } from "@/services/cashBankService";
import { accountingService } from "@/services/accountingService";
import { useAuthStore } from "@/store/authStore";
import { formatCurrency } from "@/lib/utils";
import type { Expense } from "@/types";

interface IncomeExpensePageProps {
  /** Which entry type this page is for */
  entryType: "expense" | "income";
}

const GROUP_CODE_MAP: Record<string, string> = {
  "expense-direct": "DIRECT_EXPENSES",
  "expense-indirect": "INDIRECT_EXPENSES",
  "income-direct": "DIRECT_INCOME",
  "income-indirect": "INDIRECT_INCOME",
};

const NATURE_BADGE_CLASSES: Record<string, string> = {
  "expense-direct": "bg-red-500/10 text-red-600 border-red-500/20",
  "expense-indirect": "bg-amber-500/10 text-amber-600 border-amber-500/20",
  "income-direct": "bg-emerald-500/10 text-emerald-600 border-emerald-500/20",
  "income-indirect": "bg-teal-500/10 text-teal-600 border-teal-500/20",
};

const NATURE_BADGE_LABELS: Record<string, string> = {
  "expense-direct": "Direct Expense",
  "expense-indirect": "Indirect Expense",
  "income-direct": "Direct Income",
  "income-indirect": "Indirect Income",
};

const accountingStatusClasses: Record<string, string> = {
  posted: "bg-emerald-500/10 text-emerald-600 border-emerald-500/20",
  failed: "bg-red-500/10 text-red-600 border-red-500/20",
  not_posted: "bg-slate-500/10 text-slate-600 border-slate-500/20",
};

const GST_RATES = ["0", "5", "12", "18", "28"];

const emptyForm = {
  nature: "indirect" as "direct" | "indirect",
  title: "",
  amount: "",
  ledgerId: "",
  ledgerName: "",
  date: new Date().toISOString().split("T")[0],
  description: "",
  paymentMethod: "cash",
  cashBankAccountId: "",
  gstApplicable: false,
  gstRate: "0",
  gstType: "cgst_sgst" as "cgst_sgst" | "igst",
};

export default function IncomeExpensePage({ entryType }: IncomeExpensePageProps) {
  const { user } = useAuthStore();
  const isAdmin = user?.role === "admin";
  const isIncome = entryType === "income";
  const pageTitle = isIncome ? "Income" : "Expenses";
  const pageDesc = isIncome ? "Track and manage business income" : "Track and manage business expenses";

  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [natureFilter, setNatureFilter] = useState("all");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [deleteOpen, setDeleteOpen] = useState(false);
  const [editItem, setEditItem] = useState<Expense | null>(null);
  const [deleteId, setDeleteId] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [bankAccounts, setBankAccounts] = useState<any[]>([]);
  const [ledgers, setLedgers] = useState<LedgerOption[]>([]);
  const [ledgersLoading, setLedgersLoading] = useState(false);
  const [showQuickAddLedger, setShowQuickAddLedger] = useState(false);
  const [newLedgerName, setNewLedgerName] = useState("");
  const [quickCreatingLedger, setQuickCreatingLedger] = useState(false);

  const load = useCallback(async () => {
    try {
      setLoading(true);
      const result = await expenseService.getAll({
        search,
        page,
        limit: 15,
        entryType,
        nature: natureFilter !== "all" ? natureFilter : undefined,
      });
      setExpenses(result.data);
      setTotalPages(result.pagination?.pages || 1);
    } catch { toast.error(`Failed to load ${pageTitle.toLowerCase()}`); }
    finally { setLoading(false); }
  }, [search, page, entryType, natureFilter, pageTitle]);

  useEffect(() => {
    const delayDebounceFn = setTimeout(() => {
      load();
    }, 500);
    return () => clearTimeout(delayDebounceFn);
  }, [search, page, load]);

  useEffect(() => {
    setPage(1);
  }, [search, natureFilter]);

  useEffect(() => {
    cashBankService.getAccounts()
      .then(res => {
        if (res.success && res.data) {
          setBankAccounts(res.data.filter((a: any) => a.accountType === "bank" && a.status === "active"));
        } else {
          toast.error(res.message || "Failed to load bank accounts");
        }
      })
      .catch(() => toast.error("Failed to load bank accounts"));
  }, []);

  // Load ledgers when nature or dialog opens
  const loadLedgers = useCallback(async (nature: string) => {
    const groupCode = GROUP_CODE_MAP[`${entryType}-${nature}`];
    if (!groupCode) return;
    try {
      setLedgersLoading(true);
      const data = await expenseService.getLedgersByGroup(groupCode);
      setLedgers(data);
    } catch {
      setLedgers([]);
    } finally {
      setLedgersLoading(false);
    }
  }, [entryType]);

  const openCreate = () => {
    setEditItem(null);
    setForm({ ...emptyForm });
    setShowQuickAddLedger(false);
    setNewLedgerName("");
    setDialogOpen(true);
    loadLedgers("indirect");
  };

  const openEdit = (e: Expense) => {
    setEditItem(e);
    setForm({
      nature: e.nature || "indirect",
      title: e.title,
      amount: e.amount.toString(),
      ledgerId: e.ledgerId || "",
      ledgerName: e.ledgerName || "",
      date: new Date(e.date).toISOString().split("T")[0],
      description: e.description || "",
      paymentMethod: e.paymentMethod || "cash",
      cashBankAccountId: e.cashBankAccountId || e.paymentAccountId || "",
      gstApplicable: e.gstApplicable || false,
      gstRate: String(e.gstRate || "0"),
      gstType: e.gstType || "cgst_sgst",
    });
    setShowQuickAddLedger(false);
    setNewLedgerName("");
    setDialogOpen(true);
    loadLedgers(e.nature || "indirect");
  };

  const handleNatureChange = (val: string) => {
    setForm({ ...form, nature: val as "direct" | "indirect", ledgerId: "", ledgerName: "" });
    loadLedgers(val);
  };

  const handlePaymentMethodChange = (val: string) => {
    let nextAccountId = form.cashBankAccountId;
    if (val !== "cash") {
      const defaultBank = bankAccounts.find(a => a.isDefault) || bankAccounts[0];
      if (defaultBank && !nextAccountId) {
        nextAccountId = defaultBank._id;
      }
    } else {
      nextAccountId = "";
    }
    setForm({ ...form, paymentMethod: val, cashBankAccountId: nextAccountId });
  };

  const handleLedgerChange = (val: string) => {
    const selected = ledgers.find(l => l._id === val);
    setForm({
      ...form,
      ledgerId: val,
      ledgerName: selected?.name || "",
    });
  };

  const handleSaveQuickLedger = async () => {
    if (!newLedgerName.trim()) return;
    try {
      setQuickCreatingLedger(true);
      const ledger = await expenseService.quickCreateLedger({
        name: newLedgerName.trim(),
        entryType,
        nature: form.nature,
      });
      toast.success("Ledger created successfully");
      
      // Reload ledgers
      const groupCode = GROUP_CODE_MAP[`${entryType}-${form.nature}`];
      const data = await expenseService.getLedgersByGroup(groupCode);
      setLedgers(data);
      
      // Select the newly created ledger
      setForm((prev) => ({
        ...prev,
        ledgerId: ledger._id,
        ledgerName: ledger.name,
      }));
      
      setNewLedgerName("");
      setShowQuickAddLedger(false);
    } catch {
      toast.error("Failed to create ledger");
    } finally {
      setQuickCreatingLedger(false);
    }
  };

  // Calculate GST amounts for display
  const getGSTAmounts = () => {
    const amt = Number(form.amount) || 0;
    const rate = form.gstApplicable ? Number(form.gstRate) || 0 : 0;
    const taxable = amt;
    const gst = Math.round((taxable * (rate / 100)) * 100) / 100;
    const total = Math.round((taxable + gst) * 100) / 100;
    return { taxable, gst, total };
  };

  const handleSave = async () => {
    const amount = Number(form.amount);
    if (!form.title || !form.amount) { toast.error("Title and amount are required"); return; }
    if (!amount || amount <= 0) { toast.error("Amount must be greater than 0"); return; }
    if (form.paymentMethod !== "cash" && !form.cashBankAccountId) {
      toast.error("Please select a bank account for non-cash payment");
      return;
    }

    const gstAmounts = getGSTAmounts();

    try {
      setSaving(true);
      const payload = {
        entryType,
        nature: form.nature,
        title: form.title,
        amount,
        ledgerId: form.ledgerId || undefined,
        ledgerName: form.ledgerName || form.title,
        date: form.date,
        description: form.description,
        paymentMethod: form.paymentMethod,
        cashBankAccountId: form.cashBankAccountId || undefined,
        paymentAccountId: form.cashBankAccountId || undefined,
        category: form.ledgerName || form.title,
        categoryName: form.ledgerName || form.title,
        gstApplicable: form.gstApplicable,
        gstRate: form.gstApplicable ? Number(form.gstRate) : 0,
        gstType: form.gstType,
        taxableAmount: gstAmounts.taxable,
        gstAmount: gstAmounts.gst,
        totalAmount: gstAmounts.total,
      };

      if (editItem) {
        await expenseService.update(editItem._id, payload);
        toast.success(`${isIncome ? "Income" : "Expense"} updated`);
      } else {
        await expenseService.create(payload);
        toast.success(`${isIncome ? "Income" : "Expense"} created`);
      }
      setDialogOpen(false);
      load();
    } catch (error: unknown) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || "Operation failed");
    } finally { setSaving(false); }
  };

  const handleDelete = async () => {
    if (!deleteId) return;
    try {
      await expenseService.delete(deleteId);
      toast.success(`${isIncome ? "Income" : "Expense"} deleted`);
      load();
    } catch { toast.error("Failed to delete"); }
  };

  const handleRepostAccounting = async (expenseId: string) => {
    try {
      const result = await accountingService.repostExpenseAccounting(expenseId);
      toast.success(result.message || "Accounting voucher posted");
      load();
    } catch (error: unknown) {
      const err = error as { response?: { data?: { message?: string } } };
      toast.error(err.response?.data?.message || "Failed to repost accounting voucher");
    }
  };

  const gstAmounts = getGSTAmounts();

  return (
    <div className="space-y-6">
      <PageHeader
        title={pageTitle}
        description={pageDesc}
        icon={IndianRupee}
        action={{ label: `Add ${isIncome ? "Income" : "Expense"}`, onClick: openCreate, icon: Plus }}
      />

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-3">
        <SearchInput value={search} onChange={setSearch} placeholder={`Search ${pageTitle.toLowerCase()}...`} className="max-w-sm" />
        <Select value={natureFilter} onValueChange={(v) => setNatureFilter(v)}>
          <SelectTrigger className="w-[140px]">
            <SelectValue placeholder="Nature" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All Nature</SelectItem>
            <SelectItem value="direct">Direct</SelectItem>
            <SelectItem value="indirect">Indirect</SelectItem>
          </SelectContent>
        </Select>
      </div>

      {loading ? <TableSkeleton rows={5} /> : expenses.length === 0 ? (
        <EmptyState title={`No ${pageTitle.toLowerCase()} found`} description={`Add your first ${isIncome ? "income" : "expense"} record`}>
          <Button onClick={openCreate}><Plus className="h-4 w-4 mr-2" />Add {isIncome ? "Income" : "Expense"}</Button>
        </EmptyState>
      ) : (
        <Card className="overflow-hidden rounded-lg">
          <div className="overflow-x-auto">
            <table className="min-w-[1180px] w-full table-fixed">
              <colgroup>
                <col className="w-[120px]" />
                <col className="w-[160px]" />
                <col className="w-[220px]" />
                <col className="w-[180px]" />
                <col className="w-[150px]" />
                <col className="w-[140px]" />
                <col className="w-[120px]" />
                <col className="w-[140px]" />
                <col className="w-[140px]" />
                <col className="w-[100px]" />
              </colgroup>
              <thead>
                <tr className="border-b bg-muted/30">
                  <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Date</th>
                  <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Nature</th>
                  <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Title / Particular</th>
                  <th className="px-4 py-3 text-left text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Ledger</th>
                  <th className="px-4 py-3 text-center text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Payment Mode</th>
                  <th className="px-4 py-3 text-right text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Taxable</th>
                  <th className="px-4 py-3 text-right text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">GST</th>
                  <th className="px-4 py-3 text-right text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Total</th>
                  <th className="px-4 py-3 text-center text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Accounting</th>
                  <th className="px-4 py-3 text-right text-xs font-bold uppercase tracking-[0.12em] text-muted-foreground">Actions</th>
                </tr>
              </thead>
              <tbody>
                {expenses.map((e, i) => {
                  const eType = e.entryType || "expense";
                  const eNature = e.nature || "indirect";
                  const badgeKey = `${eType}-${eNature}`;
                  const amountColorClass = eType === "income" ? "text-emerald-600" : "text-destructive";

                  return (
                    <motion.tr
                      key={e._id}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      transition={{ delay: i * 0.03 }}
                      className="border-b border-border/50 hover:bg-muted/30 transition-colors"
                    >
                      <td className="px-4 py-4 text-sm text-muted-foreground whitespace-nowrap">
                        {new Date(e.date).toLocaleDateString("en-IN")}
                      </td>
                      <td className="px-4 py-4">
                        <Badge variant="outline" className={`max-w-full whitespace-nowrap px-2.5 py-1 font-semibold ${NATURE_BADGE_CLASSES[badgeKey] || ""}`}>
                          {NATURE_BADGE_LABELS[badgeKey] || badgeKey}
                        </Badge>
                      </td>
                      <td className="px-4 py-4">
                        <p className="truncate text-sm font-semibold text-foreground" title={e.title}>{e.title}</p>
                        {e.description && <p className="text-xs text-muted-foreground line-clamp-1">{e.description}</p>}
                      </td>
                      <td className="px-4 py-4 text-sm">
                        <Badge
                          variant="secondary"
                          title={e.ledgerName || e.categoryName || (typeof e.category === "string" ? e.category : e.category?.name) || "—"}
                          className="max-w-full truncate rounded-md px-2.5 py-1 text-xs font-medium"
                        >
                          {e.ledgerName || e.categoryName || (typeof e.category === "string" ? e.category : e.category?.name) || "—"}
                        </Badge>
                      </td>
                      <td className="px-4 py-4 text-center text-sm capitalize text-muted-foreground">
                        {(e.paymentMethod || "cash").replace("_", " ")}
                      </td>
                      <td className={`px-4 py-4 text-right font-semibold tabular-nums ${amountColorClass}`}>
                        {formatCurrency(e.taxableAmount || e.amount)}
                      </td>
                      <td className={`px-4 py-4 text-right text-sm font-semibold tabular-nums ${amountColorClass}`}>
                        {e.gstApplicable && e.gstAmount ? formatCurrency(e.gstAmount) : "—"}
                      </td>
                      <td className={`px-4 py-4 text-right font-bold tabular-nums ${amountColorClass}`}>
                        {formatCurrency(e.totalAmount || e.amount)}
                      </td>
                      <td className="px-4 py-4 text-center">
                        <Badge
                          variant="outline"
                          className={`whitespace-nowrap px-2.5 py-1 font-semibold ${accountingStatusClasses[e.accountingStatus || "not_posted"]}`}
                        >
                          {(e.accountingStatus || "not_posted").replace("_", " ")}
                        </Badge>
                      </td>
                      <td className="px-4 py-4 text-right">
                        <div className="flex items-center justify-end gap-1">
                          {isAdmin && (e.accountingStatus || "not_posted") !== "posted" && (
                            <Button variant="ghost" size="icon-sm" onClick={() => handleRepostAccounting(e._id)} title="Repost accounting">
                              <IndianRupee className="h-4 w-4 text-primary" />
                            </Button>
                          )}
                          <Button variant="ghost" size="icon-sm" onClick={() => openEdit(e)}>
                            <Pencil className="h-4 w-4" />
                          </Button>
                          <Button variant="ghost" size="icon-sm" onClick={() => { setDeleteId(e._id); setDeleteOpen(true); }}>
                            <Trash2 className="h-4 w-4 text-destructive" />
                          </Button>
                        </div>
                      </td>
                    </motion.tr>
                  );
                })}
              </tbody>
            </table>
          </div>
          {/* Pagination */}
          {totalPages > 1 && (
            <div className="flex items-center justify-between p-4 border-t bg-muted/10">
              <p className="text-sm text-muted-foreground">
                Page {page} of {totalPages}
              </p>
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page <= 1}
                  onClick={() => setPage((p) => p - 1)}
                >
                  Previous
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  disabled={page >= totalPages}
                  onClick={() => setPage((p) => p + 1)}
                >
                  Next
                </Button>
              </div>
            </div>
          )}
        </Card>
      )}

      {/* Create/Edit Dialog */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="sm:max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editItem ? "Edit" : "Add"} {isIncome ? "Income" : "Expense"}</DialogTitle>
            <DialogDescription>Record a {isIncome ? "income" : "expense"} entry with accounting details</DialogDescription>
          </DialogHeader>
          <div className="space-y-4 py-4">
            {/* Nature */}
            <div className="space-y-2">
              <Label>Nature *</Label>
              <Select value={form.nature} onValueChange={handleNatureChange}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="direct">Direct</SelectItem>
                  <SelectItem value="indirect">Indirect</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Ledger / Category */}
            {showQuickAddLedger ? (
              <div className="space-y-2 animate-in fade-in-50 duration-200">
                <div className="flex items-center justify-between">
                  <Label>New Ledger Name *</Label>
                  <Button 
                    type="button" 
                    variant="link" 
                    size="sm" 
                    className="h-auto p-0 text-xs text-muted-foreground hover:text-foreground"
                    onClick={() => {
                      setShowQuickAddLedger(false);
                      setNewLedgerName("");
                    }}
                  >
                    Select Existing
                  </Button>
                </div>
                <div className="flex gap-2">
                  <Input 
                    value={newLedgerName} 
                    onChange={(e) => setNewLedgerName(e.target.value)} 
                    placeholder={isIncome ? "e.g. Interest Received" : "e.g. Office Rent"}
                    className="flex-1"
                    onKeyDown={(e) => {
                      if (e.key === "Enter") {
                        e.preventDefault();
                        handleSaveQuickLedger();
                      }
                    }}
                  />
                  <Button 
                    type="button" 
                    size="sm" 
                    onClick={handleSaveQuickLedger}
                    disabled={quickCreatingLedger || !newLedgerName.trim()}
                  >
                    {quickCreatingLedger ? <Loader2 className="h-3.5 w-3.5 animate-spin" /> : "Save"}
                  </Button>
                </div>
              </div>
            ) : (
              <div className="space-y-2">
                <div className="flex items-center justify-between">
                  <Label>Ledger / Category</Label>
                  <Button 
                    type="button" 
                    variant="link" 
                    size="sm" 
                    className="h-auto p-0 text-xs text-primary"
                    onClick={() => setShowQuickAddLedger(true)}
                  >
                    + Add New Ledger
                  </Button>
                </div>
                <Select value={form.ledgerId} onValueChange={handleLedgerChange}>
                  <SelectTrigger>
                    <SelectValue placeholder={ledgersLoading ? "Loading..." : "Select ledger"} />
                  </SelectTrigger>
                  <SelectContent>
                    {ledgers.map(l => (
                      <SelectItem key={l._id} value={l._id}>{l.name}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}

            {/* Title */}
            <div className="space-y-2">
              <Label>Title / Particular *</Label>
              <Input value={form.title} onChange={(e) => setForm({ ...form, title: e.target.value })} placeholder={isIncome ? "e.g. Commission Income" : "e.g. Office Stationery"} />
            </div>

            {/* Amount + Date */}
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-2">
                <Label>Amount (₹) *</Label>
                <Input type="number" min={0} value={form.amount} onChange={(e) => setForm({ ...form, amount: e.target.value })} placeholder="0.00" />
              </div>
              <div className="space-y-2">
                <Label>Date *</Label>
                <Input type="date" value={form.date} onChange={(e) => setForm({ ...form, date: e.target.value })} />
              </div>
            </div>

            {/* Payment Mode */}
            <div className="space-y-2">
              <Label>{isIncome ? "Receipt Account" : "Payment Mode"}</Label>
              <Select value={form.paymentMethod} onValueChange={handlePaymentMethodChange}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="cash">Cash</SelectItem>
                  <SelectItem value="bank_transfer">Bank Transfer</SelectItem>
                  <SelectItem value="upi">UPI</SelectItem>
                  <SelectItem value="card">Card</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Bank Account selection */}
            {form.paymentMethod !== "cash" && bankAccounts.length > 0 && (
              <div className="space-y-2">
                <Label>{isIncome ? "Receive Into Bank Account" : "Pay From Bank Account"} *</Label>
                <Select value={form.cashBankAccountId} onValueChange={(val) => setForm({ ...form, cashBankAccountId: val })}>
                  <SelectTrigger><SelectValue placeholder="Select bank account" /></SelectTrigger>
                  <SelectContent>
                    {bankAccounts.map((account) => (
                      <SelectItem key={account._id} value={account._id}>
                        {account.accountName} {account.bankName ? `(${account.bankName})` : ""} - ₹{account.currentBalance.toFixed(2)}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            )}

            {/* GST Section */}
            <div className="space-y-3 rounded-lg border border-border/50 p-3">
              <div className="flex items-center justify-between">
                <Label className="text-sm font-medium">GST Applicable</Label>
                <Switch
                  checked={form.gstApplicable}
                  onCheckedChange={(checked) => setForm({ ...form, gstApplicable: checked })}
                />
              </div>

              {form.gstApplicable && (
                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-2">
                    <Label className="text-xs">GST Rate</Label>
                    <Select value={form.gstRate} onValueChange={(val) => setForm({ ...form, gstRate: val })}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        {GST_RATES.map(r => (
                          <SelectItem key={r} value={r}>{r}%</SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label className="text-xs">GST Type</Label>
                    <Select value={form.gstType} onValueChange={(val) => setForm({ ...form, gstType: val as "cgst_sgst" | "igst" })}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="cgst_sgst">CGST + SGST</SelectItem>
                        <SelectItem value="igst">IGST</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              )}

              {form.gstApplicable && Number(form.amount) > 0 && (
                <div className="text-xs space-y-1 pt-2 border-t border-border/30">
                  <div className="flex justify-between text-muted-foreground">
                    <span>Taxable Amount</span>
                    <span>{formatCurrency(gstAmounts.taxable)}</span>
                  </div>
                  {form.gstType === "igst" ? (
                    <div className="flex justify-between text-muted-foreground">
                      <span>IGST ({form.gstRate}%)</span>
                      <span>{formatCurrency(gstAmounts.gst)}</span>
                    </div>
                  ) : (
                    <>
                      <div className="flex justify-between text-muted-foreground">
                        <span>CGST ({Number(form.gstRate) / 2}%)</span>
                        <span>{formatCurrency(Math.round((gstAmounts.gst / 2) * 100) / 100)}</span>
                      </div>
                      <div className="flex justify-between text-muted-foreground">
                        <span>SGST ({Number(form.gstRate) / 2}%)</span>
                        <span>{formatCurrency(gstAmounts.gst - Math.round((gstAmounts.gst / 2) * 100) / 100)}</span>
                      </div>
                    </>
                  )}
                  <div className="flex justify-between font-semibold text-foreground pt-1">
                    <span>Total Amount</span>
                    <span>{formatCurrency(gstAmounts.total)}</span>
                  </div>
                </div>
              )}
            </div>

            {/* Description */}
            <div className="space-y-2">
              <Label>Description / Narration</Label>
              <Textarea value={form.description} onChange={(e) => setForm({ ...form, description: e.target.value })} rows={2} placeholder="Additional notes..." />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button onClick={handleSave} disabled={saving}>
              {saving && <Loader2 className="h-4 w-4 animate-spin mr-2" />}
              {editItem ? "Update" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={deleteOpen}
        onOpenChange={setDeleteOpen}
        title={`Delete ${isIncome ? "Income" : "Expense"}`}
        description={`This will cancel this ${isIncome ? "income" : "expense"} record and reverse its accounting entries. This action cannot be undone.`}
        confirmLabel="Delete"
        onConfirm={handleDelete}
      />
    </div>
  );
}
