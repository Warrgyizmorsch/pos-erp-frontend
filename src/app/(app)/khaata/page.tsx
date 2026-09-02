"use client";

import React, { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { 
  BookOpen, 
  IndianRupee, 
  ArrowDownLeft, 
  ArrowUpRight,
  Search,
  Filter,
  Loader2,
  MoreHorizontal
} from "lucide-react";
import { FaWhatsapp } from "react-icons/fa";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { khaataService, KhaataParty } from "@/services/khaataService";

export default function DigitalKhaataPage() {
  const queryClient = useQueryClient();
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  
  // Payment Modal State
  const [paymentModal, setPaymentModal] = useState<{
    isOpen: boolean;
    type: 'payment_in' | 'payment_out';
    party: KhaataParty | null;
  }>({
    isOpen: false,
    type: 'payment_in',
    party: null
  });
  
  const [paymentAmount, setPaymentAmount] = useState("");
  const [paymentNotes, setPaymentNotes] = useState("");

  const { data: parties = [], isLoading } = useQuery({
    queryKey: ["khaata-balances"],
    queryFn: khaataService.getBalances,
  });

  const paymentMutation = useMutation({
    mutationFn: (data: { partyId: string; amount: number; type: 'payment_in'|'payment_out'; partyType: 'customer'|'supplier'; notes: string }) => 
      khaataService.addTransaction(data.partyId, { amount: data.amount, type: data.type, partyType: data.partyType, notes: data.notes }),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["khaata-balances"] });
      toast.success(variables.type === 'payment_in' ? "Payment received successfully!" : "Payment made successfully!");
      setPaymentModal({ isOpen: false, type: 'payment_in', party: null });
      setPaymentAmount("");
      setPaymentNotes("");
    },
    onError: (error: any) => {
      toast.error(error?.response?.data?.message || "Failed to process payment");
    }
  });

  const totalReceivable = parties.filter((p) => p.currentBalance > 0).reduce((acc, p) => acc + p.currentBalance, 0);
  const totalPayable = parties.filter((p) => p.currentBalance < 0).reduce((acc, p) => acc + Math.abs(p.currentBalance), 0);

  const filteredParties = parties.filter((p) => {
    const matchesSearch = p.name.toLowerCase().includes(search.toLowerCase()) || p.phone.includes(search);
    const matchesStatus = statusFilter === "all" 
      ? true 
      : statusFilter === "due" 
        ? p.currentBalance !== 0 
        : p.currentBalance === 0;
    return matchesSearch && matchesStatus;
  });

  const handleSendReminder = async (party: KhaataParty) => {
    try {
      const isCustomer = party.partyType === 'customer';
      const text = isCustomer 
        ? `Namaskar ${party.name},\n\nAapka hamare store par ₹${party.currentBalance} ka udhaar baaki hai. Kripya jald se jald bhugtaan karein.\n\nDhanyawad!`
        : `Namaskar ${party.name},\n\nHamein aapko ₹${Math.abs(party.currentBalance)} ka payment karna baaki hai. Hum ise jald hi clear karenge.\n\nDhanyawad!`;
      
      await khaataService.logReminder(party._id, text);
      window.open(`https://wa.me/91${party.phone}?text=${encodeURIComponent(text)}`, "_blank");
      queryClient.invalidateQueries({ queryKey: ["khaata-balances"] });
    } catch (error) {
      toast.error("Failed to log reminder, but opening WhatsApp anyway.");
      const isCustomer = party.partyType === 'customer';
      const text = isCustomer 
        ? `Namaskar ${party.name},\n\nAapka hamare store par ₹${party.currentBalance} ka udhaar baaki hai. Kripya jald se jald bhugtaan karein.\n\nDhanyawad!`
        : `Namaskar ${party.name},\n\nHamein aapko ₹${Math.abs(party.currentBalance)} ka payment karna baaki hai. Hum ise jald hi clear karenge.\n\nDhanyawad!`;
      window.open(`https://wa.me/91${party.phone}?text=${encodeURIComponent(text)}`, "_blank");
    }
  };

  const handlePaymentSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!paymentModal.party || !paymentAmount || isNaN(Number(paymentAmount)) || Number(paymentAmount) <= 0) {
      toast.error("Please provide a valid amount.");
      return;
    }
    paymentMutation.mutate({ 
      partyId: paymentModal.party._id, 
      amount: Number(paymentAmount),
      type: paymentModal.type,
      partyType: paymentModal.party.partyType,
      notes: paymentNotes
    });
  };

  const openPaymentModal = (party: KhaataParty, type: 'payment_in' | 'payment_out') => {
    setPaymentModal({ isOpen: true, type, party });
    // If they owe us (positive balance), auto-fill receive amount. If we owe them (negative balance), auto-fill pay amount.
    if (type === 'payment_in' && party.currentBalance > 0) {
      setPaymentAmount(String(party.currentBalance));
    } else if (type === 'payment_out' && party.currentBalance < 0) {
      setPaymentAmount(String(Math.abs(party.currentBalance)));
    } else {
      setPaymentAmount("");
    }
    setPaymentNotes("");
  };

  return (
    <div className="flex-1 space-y-4 p-4 md:p-8 pt-6">
      <div className="flex items-center justify-between space-y-2">
        <div>
          <h2 className="text-3xl font-bold tracking-tight flex items-center gap-2">
            <BookOpen className="h-8 w-8 text-primary" />
            Digital Khaata (Ledger)
          </h2>
          <p className="text-muted-foreground mt-1">
            Manage customer udhaar and supplier payables directly synced with accounting.
          </p>
        </div>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Total Receivable (Udhaar)
            </CardTitle>
            <ArrowDownLeft className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-emerald-600">₹{totalReceivable.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">
              Amount parties owe you (Debit Balance)
            </p>
          </CardContent>
        </Card>
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">
              Total Payable (Advance)
            </CardTitle>
            <ArrowUpRight className="h-4 w-4 text-rose-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold text-rose-600">₹{totalPayable.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">
              Amount you owe to parties (Credit Balance)
            </p>
          </CardContent>
        </Card>
      </div>

      <Card className="mt-6">
        <CardHeader>
          <CardTitle>All Parties</CardTitle>
          <CardDescription>
            Unified list of customers and suppliers with their accounting balances.
          </CardDescription>
          <div className="flex items-center gap-4 mt-4">
            <div className="relative max-w-sm flex-1">
              <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
              <Input 
                placeholder="Search by name or phone..." 
                className="pl-8"
                value={search}
                onChange={(e) => setSearch(e.target.value)}
              />
            </div>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Filter by status" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Statuses</SelectItem>
                <SelectItem value="due">Due (Pending)</SelectItem>
                <SelectItem value="settled">Settled (₹0)</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </CardHeader>
        <CardContent>
          {isLoading ? (
            <div className="flex justify-center p-8">
              <Loader2 className="h-8 w-8 animate-spin text-muted-foreground" />
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Party Name</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Contact</TableHead>
                  <TableHead>Balance</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredParties.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center h-24 text-muted-foreground">
                      No parties found.
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredParties.map((party) => (
                    <TableRow key={party._id}>
                      <TableCell className="font-medium">
                        {party.name}
                        {party.lastReminderSentAt && (
                          <div className="text-[10px] text-muted-foreground mt-1">
                            Last reminded: {new Date(party.lastReminderSentAt).toLocaleDateString()}
                          </div>
                        )}
                      </TableCell>
                      <TableCell>
                        <Badge variant="outline" className="capitalize">
                          {party.partyType}
                        </Badge>
                      </TableCell>
                      <TableCell>{party.phone}</TableCell>
                      <TableCell>
                        {party.currentBalance > 0 ? (
                          <span className="text-emerald-600 font-semibold flex items-center gap-1">
                            <IndianRupee className="h-3 w-3" />
                            {party.currentBalance.toLocaleString()} (Receivable)
                          </span>
                        ) : party.currentBalance < 0 ? (
                          <span className="text-rose-600 font-semibold flex items-center gap-1">
                            <IndianRupee className="h-3 w-3" />
                            {Math.abs(party.currentBalance).toLocaleString()} (Payable)
                          </span>
                        ) : (
                          <span className="text-muted-foreground">Settled (₹0)</span>
                        )}
                      </TableCell>
                      <TableCell>
                        {party.currentBalance !== 0 ? (
                          <Badge variant="secondary" className="bg-amber-100 text-amber-800 hover:bg-amber-100">Due</Badge>
                        ) : (
                          <Badge variant="outline" className="text-emerald-600 border-emerald-200 bg-emerald-50">Settled</Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" className="h-8 w-8 p-0">
                              <span className="sr-only">Open menu</span>
                              <MoreHorizontal className="h-4 w-4" />
                            </Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end">
                            {party.currentBalance !== 0 && (
                              <DropdownMenuItem onClick={() => handleSendReminder(party)}>
                                <FaWhatsapp className="h-4 w-4 mr-2 text-emerald-500" />
                                Send Reminder
                              </DropdownMenuItem>
                            )}
                            <DropdownMenuItem onClick={() => openPaymentModal(party, 'payment_in')}>
                              <ArrowDownLeft className="h-4 w-4 mr-2 text-emerald-500" />
                              Receive Payment
                            </DropdownMenuItem>
                            <DropdownMenuItem onClick={() => openPaymentModal(party, 'payment_out')}>
                              <ArrowUpRight className="h-4 w-4 mr-2 text-rose-500" />
                              Make Payment
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Unified Payment Modal */}
      <Dialog open={paymentModal.isOpen} onOpenChange={(open) => {
        if(!open) setPaymentModal({ isOpen: false, type: 'payment_in', party: null });
      }}>
        <DialogContent className="sm:max-w-[425px]">
          <form onSubmit={handlePaymentSubmit}>
            <DialogHeader>
              <DialogTitle className="flex items-center gap-2">
                {paymentModal.type === 'payment_in' ? (
                  <><ArrowDownLeft className="h-5 w-5 text-emerald-500" /> Receive Payment</>
                ) : (
                  <><ArrowUpRight className="h-5 w-5 text-rose-500" /> Make Payment</>
                )}
              </DialogTitle>
              <DialogDescription>
                {paymentModal.type === 'payment_in' 
                  ? `Record money received from ${paymentModal.party?.name}. This will create an Accounting Receipt.`
                  : `Record money paid to ${paymentModal.party?.name}. This will create an Accounting Payment.`
                }
              </DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="space-y-2">
                <Label>Party</Label>
                <div className="p-2 bg-muted rounded-md text-sm font-medium flex justify-between">
                  <span>{paymentModal.party?.name}</span>
                  <Badge variant="outline" className="capitalize">{paymentModal.party?.partyType}</Badge>
                </div>
              </div>
              <div className="space-y-2">
                <Label>Current Balance</Label>
                <div className="text-sm">
                  {paymentModal.party && paymentModal.party.currentBalance > 0 
                    ? <span className="text-emerald-600 font-semibold">₹{paymentModal.party.currentBalance} (Receivable)</span>
                    : paymentModal.party && paymentModal.party.currentBalance < 0
                    ? <span className="text-rose-600 font-semibold">₹{Math.abs(paymentModal.party.currentBalance)} (Payable)</span>
                    : <span className="text-muted-foreground">₹0 (Settled)</span>
                  }
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="amount">Amount (₹)</Label>
                <Input
                  id="amount"
                  type="number"
                  placeholder="e.g. 500"
                  value={paymentAmount}
                  onChange={(e) => setPaymentAmount(e.target.value)}
                  required
                  min="1"
                />
              </div>
              <div className="space-y-2">
                <Label htmlFor="notes">Notes (Optional)</Label>
                <Input
                  id="notes"
                  type="text"
                  placeholder="e.g. Partial payment received"
                  value={paymentNotes}
                  onChange={(e) => setPaymentNotes(e.target.value)}
                />
              </div>
            </div>
            <DialogFooter>
              <Button type="button" variant="outline" onClick={() => setPaymentModal({ isOpen: false, type: 'payment_in', party: null })}>
                Cancel
              </Button>
              <Button type="submit" disabled={paymentMutation.isPending}>
                {paymentMutation.isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                {paymentModal.type === 'payment_in' ? 'Save Receipt' : 'Save Payment'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
