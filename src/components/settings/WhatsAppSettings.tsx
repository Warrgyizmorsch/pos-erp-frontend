"use client";

import { useState, useEffect } from "react";
import { Loader2, Lock, ArrowUpRight } from "lucide-react";
import { FaWhatsapp } from "react-icons/fa";
import api from "@/services/api";
import { toast } from "sonner";
import Image from "next/image";

export function WhatsAppSettings() {
  const [status, setStatus] = useState<"disconnected" | "qr" | "connected">("disconnected");
  const [qrCode, setQrCode] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [polling, setPolling] = useState(false);

  const fetchStatus = async () => {
    try {
      const res = await api.get("/whatsapp/status");
      if (res.data.success) {
        setStatus(res.data.status);
        if (res.data.qr) {
          setQrCode(res.data.qr);
        }
        return res.data.status;
      }
    } catch (err) {
      console.error("Failed to fetch WhatsApp status", err);
    }
    return null;
  };

  useEffect(() => {
    fetchStatus().then((currentStatus) => {
      if (currentStatus === "disconnected") {
        handleConnect(true);
      }
    });
  }, []);

  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (polling || status === "qr") {
      interval = setInterval(() => {
        fetchStatus();
      }, 3000);
    }
    return () => clearInterval(interval);
  }, [polling, status]);

  const handleConnect = async (isAuto = false) => {
    try {
      setLoading(true);
      const res = await api.post("/whatsapp/connect");
      if (res.data.success) {
        setPolling(true);
        if (!isAuto) toast.success("Connection started. Please wait for QR code.");
      }
    } catch (err) {
      if (!isAuto) toast.error("Failed to start connection.");
    } finally {
      setLoading(false);
    }
  };

  const handleDisconnect = async () => {
    try {
      setLoading(true);
      await api.post("/whatsapp/disconnect");
      setStatus("disconnected");
      setQrCode(null);
      setPolling(false);
      toast.success("Disconnected successfully.");
    } catch (err) {
      toast.error("Failed to disconnect.");
    } finally {
      setLoading(false);
    }
  };

  if (status === "connected") {
    return (
      <div className="w-full flex items-center justify-center p-8 font-sans">
        <div className="bg-card text-card-foreground shadow-sm border border-border rounded-3xl p-10 max-w-xl w-full text-center space-y-6">
          <div className="mx-auto w-24 h-24 bg-green-500/10 rounded-full flex items-center justify-center">
            <FaWhatsapp className="h-12 w-12 text-green-500" />
          </div>
          <div>
            <h2 className="text-2xl font-normal text-foreground">WhatsApp is Connected</h2>
            <p className="text-muted-foreground mt-3 leading-relaxed">
              Your WhatsApp account is active and ready to send automated messages and invoices.
            </p>
          </div>
          <button 
            onClick={handleDisconnect} 
            disabled={loading}
            className="px-8 py-3 mt-4 rounded-full border border-red-500/50 text-red-500 hover:bg-red-50 dark:hover:bg-red-950/20 font-medium transition-colors inline-flex items-center"
          >
            {loading ? <Loader2 className="h-5 w-5 animate-spin mr-2" /> : null}
            Log out
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="w-full flex flex-col items-center pt-6 font-sans">
      <div className="bg-card text-card-foreground rounded-[24px] shadow-sm border border-border max-w-[850px] w-full p-10 md:p-[32px]">
        
        <div className="flex flex-col-reverse md:flex-row gap-12 md:gap-20 justify-between items-start">
          
          {/* Left Column: Instructions */}
          <div className="flex-1 space-y-8">
            <h1 className="text-[28px] font-normal text-foreground leading-tight">
              Scan to log in
            </h1>
            
            <div className="space-y-6 text-muted-foreground text-[17px] leading-relaxed">
              <div className="flex gap-4 items-start">
                <span className="flex-shrink-0 w-6 h-6 rounded-full border border-border flex items-center justify-center text-[13px] font-medium mt-0.5 text-foreground">1</span>
                <p>Scan the QR code with your phone&apos;s camera</p>
              </div>
              <div className="flex gap-4 items-start">
                <span className="flex-shrink-0 w-6 h-6 rounded-full border border-border flex items-center justify-center text-[13px] font-medium mt-0.5 text-foreground">2</span>
                <p>
                  Tap the link to open <strong>WhatsApp</strong> <FaWhatsapp className="inline text-green-500 w-5 h-5 ml-0.5 relative -top-[1px]" />
                </p>
              </div>
              <div className="flex gap-4 items-start">
                <span className="flex-shrink-0 w-6 h-6 rounded-full border border-border flex items-center justify-center text-[13px] font-medium mt-0.5 text-foreground">3</span>
                <p>Scan the QR code again to link to your account</p>
              </div>
            </div>

            <div className="pt-0 flex items-center gap-3 text-foreground text-[15px] font-medium">
              <div className="w-[18px] h-[18px] rounded-[4px] flex flex-shrink-0 items-center justify-center bg-primary text-primary-foreground">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" className="w-3 h-3"><polyline points="20 6 9 17 4 12"></polyline></svg>
              </div>
              <span>Stay logged in on this browser</span>
              <div className="w-4 h-4 ml-1 rounded-full border border-border flex items-center justify-center text-muted-foreground text-[10px]">i</div>
            </div>
          </div>

          {/* Right Column: QR Code */}
          <div className="flex-shrink-0 flex items-center justify-center pt-2">
            <div className="w-[264px] h-[264px] rounded-xl overflow-hidden relative bg-white flex items-center justify-center shadow-sm border border-border">
              {status === "qr" && qrCode ? (
                <>
                  <Image src={qrCode} alt="WhatsApp QR Code" width={264} height={264} className="opacity-95" />
                  <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                    <div className="bg-white rounded-full p-2 shadow-md flex items-center justify-center">
                       <div className="w-8 h-8 rounded-full border-2 border-white bg-foreground flex items-center justify-center">
                          <FaWhatsapp className="text-background w-5 h-5" />
                       </div>
                    </div>
                  </div>
                </>
              ) : (
                <div className="flex flex-col items-center justify-center text-muted-foreground">
                  <Loader2 className="w-10 h-10 animate-spin mb-4" />
                  <span className="text-sm">Generating code...</span>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Footer Text */}
      <div className="mt-4 space-y-8 text-center w-full max-w-[850px]">
        
        <div className="flex items-center justify-center gap-2 text-muted-foreground/80 text-[13px]">
          <Lock className="w-[14px] h-[14px]" />
          <span>Your personal messages are end-to-end encrypted</span>
        </div>
        
        <p className="text-muted-foreground/60 text-[13px] pt-4">
          Terms & Privacy Policy
        </p>
      </div>
    </div>
  );
}
