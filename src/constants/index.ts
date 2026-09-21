export const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:5500/api";


export const PAYMENT_METHODS = [
  { value: "cash", label: "Cash", icon: "Banknote" },
  { value: "card", label: "Card", icon: "CreditCard" },
  { value: "upi", label: "UPI", icon: "Smartphone" },
] as const;

export const TAX_RATE = 18; // GST percentage
