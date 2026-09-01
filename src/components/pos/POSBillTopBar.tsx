import React, { useState, useEffect, useRef } from "react";
import { Plus, X, User, ChevronDown, Calendar, PackagePlus } from "lucide-react";
import { usePOSStore, WALK_IN_CUSTOMER } from "@/store/posStore";
import { customerService } from "@/services/customerService";
import { CustomerModal } from "@/components/shared/CustomerModal";
import type { Customer } from "@/types";
import { cn } from "@/lib/utils";

interface POSBillTopBarProps {
  onAddCustomItem: () => void;
}

export function POSBillTopBar({ onAddCustomItem }: POSBillTopBarProps) {
  const { bills, activeBillId, setActiveBill, createNewBill, closeBill, getActiveBill, setCustomer } = usePOSStore();
  const bill = getActiveBill();

  const [customers, setCustomers] = useState<Customer[]>([]);
  const [custSearch, setCustSearch] = useState("");
  const [showDD, setShowDD] = useState(false);
  const [showCustomerModal, setShowCustomerModal] = useState(false);
  const wrapperRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const h = (e: KeyboardEvent) => {
      if (e.ctrlKey && e.key === "t") {
        e.preventDefault();
        createNewBill();
      }
      if (e.ctrlKey && e.key === "w") {
        e.preventDefault();
        if (activeBillId) closeBill(activeBillId);
      }
    };
    window.addEventListener("keydown", h);
    return () => window.removeEventListener("keydown", h);
  }, [activeBillId, createNewBill, closeBill]);

  useEffect(() => {
    customerService.getAll({ limit: 200 }).then(r => {
      setCustomers(r.data);
    }).catch(() => {});
  }, []);

  useEffect(() => {
    const handleOutsideClick = (e: MouseEvent) => {
      if (wrapperRef.current && !wrapperRef.current.contains(e.target as Node)) {
        setShowDD(false);
      }
    };
    document.addEventListener("mousedown", handleOutsideClick);
    return () => document.removeEventListener("mousedown", handleOutsideClick);
  }, []);

  const filtered = custSearch.trim()
    ? customers.filter(c => c.name.toLowerCase().includes(custSearch.toLowerCase()) || (c.phone && c.phone.includes(custSearch)))
    : customers;

  const isWalkIn = !bill?.customer || bill.customer._id === "walk-in";
  const customerDisplayName = isWalkIn ? "" : (bill?.customer?.name || "");

  return (
    <div className="relative flex shrink-0 flex-col border-b border-border/70 bg-card">
      <div className="flex h-12 items-center gap-2 px-3 py-1.5">
        
        <div className="flex shrink-0 items-center gap-1 overflow-x-auto pb-1 no-scrollbar lg:pb-0">
          {bills.map((b) => {
            const active = b.id === activeBillId;
            return (
              <button
                key={b.id}
                onClick={() => setActiveBill(b.id)}
                className={cn(
                  "group flex h-8 shrink-0 items-center gap-1 rounded-md px-2.5 text-xs font-bold transition-all",
                  active
                    ? "bg-primary text-primary-foreground shadow-md shadow-primary/25"
                    : "text-muted-foreground hover:bg-muted"
                )}
              >
                <span>#{b.billNo}</span>
                {active && <span className="text-[9px] opacity-70 font-mono hidden sm:inline">CTRL+W</span>}
                {bills.length > 1 && (
                  <span
                    onClick={(e) => { e.stopPropagation(); closeBill(b.id); }}
                    className={cn(
                      "rounded-full p-0.5 transition-all",
                      active ? "hover:bg-white/20" : "opacity-0 group-hover:opacity-100 hover:bg-muted-foreground/20"
                    )}
                  >
                    <X className="h-3 w-3" />
                  </span>
                )}
              </button>
            );
          })}
          <button
            onClick={createNewBill}
            className="flex h-8 shrink-0 items-center gap-1.5 rounded-md bg-primary px-2.5 text-xs font-bold text-primary-foreground shadow-sm transition-colors hover:bg-primary/90"
          >
            <Plus className="h-3.5 w-3.5" />
            New Bill
            <span className="text-[9px] opacity-70 font-mono ml-0.5 hidden sm:inline">Ctrl+T</span>
          </button>
          <button
            onClick={onAddCustomItem}
            className="flex h-8 shrink-0 items-center gap-1.5 rounded-md border border-border/70 bg-card px-2.5 text-xs font-bold text-foreground shadow-sm transition-colors hover:bg-muted"
          >
            <PackagePlus className="h-3.5 w-3.5" />
            Add Custom Item
          </button>
        </div>

        <div className="flex-1" />

        <div className="relative hidden md:block min-w-[150px] max-w-[220px]" ref={wrapperRef}>
          <div className="relative flex items-center">
            <User className="absolute left-2.5 h-3.5 w-3.5 text-muted-foreground pointer-events-none z-10" />
            <input
              data-pos-customer-input="true"
              value={isWalkIn ? custSearch : customerDisplayName}
              onChange={(e) => { setCustSearch(e.target.value); setShowDD(true); if (!isWalkIn) setCustomer(WALK_IN_CUSTOMER); }}
              onFocus={() => setShowDD(true)}
              placeholder="Walk-in Customer"
              className="h-8 w-full rounded-md border border-border/60 bg-muted/25 pl-8 pr-7 text-xs font-semibold transition-all placeholder:text-muted-foreground/60 focus:outline-none focus:ring-2 focus:ring-primary/20"
            />
            {!isWalkIn ? (
              <button
                onClick={(e) => { e.stopPropagation(); setCustomer(WALK_IN_CUSTOMER); setCustSearch(""); setShowDD(true); }}
                className="absolute right-2 p-0.5 hover:bg-muted rounded-full text-muted-foreground hover:text-foreground transition-all z-10"
              >
                <X className="h-3 w-3" />
              </button>
            ) : (
              <ChevronDown className="absolute right-2 h-3.5 w-3.5 text-muted-foreground pointer-events-none" />
            )}
          </div>

          {showDD && (
            <div className="absolute left-0 right-0 top-full mt-1 bg-card border border-border rounded-xl shadow-xl max-h-56 overflow-y-auto z-50 flex flex-col min-w-[240px]">
              <button
                onClick={() => { setShowCustomerModal(true); setShowDD(false); setCustSearch(""); }}
                className="px-3 py-2 text-left text-xs font-bold text-primary hover:bg-primary/10 border-b border-border/50 sticky top-0 bg-card z-10 flex items-center gap-2"
              >
                <Plus className="h-3.5 w-3.5" /> Add New Customer
              </button>
              <button
                onClick={() => { setCustomer(WALK_IN_CUSTOMER); setShowDD(false); setCustSearch(""); }}
                className={cn(
                  "w-full px-3 py-2 text-left text-xs hover:bg-muted/50 transition-colors flex justify-between border-b border-border/20",
                  isWalkIn && "bg-primary/5"
                )}
              >
                <span className="font-medium text-muted-foreground">Walk-in Customer</span>
                <span className="text-[10px] text-muted-foreground/50">Default</span>
              </button>
              {filtered.slice(0, 6).map(c => (
                <button
                  key={c._id}
                  onClick={() => { setCustomer(c); setShowDD(false); setCustSearch(""); }}
                  className="w-full px-3 py-2 text-left text-xs hover:bg-muted/50 transition-colors flex justify-between"
                >
                  <span className="font-medium">{c.name}</span>
                  {c.phone && <span className="text-[10px] text-muted-foreground">{c.phone}</span>}
                </button>
              ))}
              {filtered.length === 0 && <div className="p-3 text-center text-xs text-muted-foreground">No customer found</div>}
            </div>
          )}
        </div>

        <div className="relative shrink-0 hidden md:block">
          <Calendar className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground pointer-events-none" />
          <input
            type="date"
            defaultValue={new Date().toISOString().split("T")[0]}
            className="h-8 w-[135px] rounded-md border border-border/60 bg-muted/25 pl-8 pr-2 text-xs font-semibold transition-all focus:outline-none focus:ring-2 focus:ring-primary/20"
          />
        </div>
      </div>

      {showCustomerModal && (
        <CustomerModal
          open={showCustomerModal}
          onOpenChange={setShowCustomerModal}
          onSuccess={(customer) => {
            if (customer) {
              setCustomers(prev => [...prev, customer]);
              setCustomer(customer);
            }
            setShowCustomerModal(false);
          }}
        />
      )}
    </div>
  );
}
