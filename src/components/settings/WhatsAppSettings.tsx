"use client";

import { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Loader2, QrCode, LogOut } from "lucide-react";
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

  return (
    <Card>
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          <FaWhatsapp className="h-5 w-5 text-green-500" />
          WhatsApp Integration
        </CardTitle>
        <CardDescription>Connect your WhatsApp to send invoices directly to customers</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="font-medium">Connection Status</p>
            <div className="mt-1">
              {status === "connected" ? (
                <Badge className="bg-green-500 hover:bg-green-600 text-white">Connected</Badge>
              ) : status === "qr" ? (
                <Badge variant="outline" className="text-yellow-600 border-yellow-600">Waiting for Scan</Badge>
              ) : (
                <Badge variant="secondary">Disconnected</Badge>
              )}
            </div>
          </div>
          <div>
            {status === "connected" ? (
              <Button variant="destructive" onClick={handleDisconnect} disabled={loading} size="sm">
                {loading ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : <LogOut className="h-4 w-4 mr-2" />}
                Disconnect
              </Button>
            ) : status === "qr" ? (
              <Button variant="outline" onClick={handleDisconnect} disabled={loading} size="sm">
                Cancel
              </Button>
            ) : (
              <Button onClick={() => handleConnect(false)} disabled={loading} size="sm" className="bg-green-600 hover:bg-green-700">
                {loading ? <Loader2 className="h-4 w-4 animate-spin mr-2" /> : <QrCode className="h-4 w-4 mr-2" />}
                Connect WhatsApp
              </Button>
            )}
          </div>
        </div>

        {status === "qr" && qrCode && (
          <div className="mt-4 flex flex-col items-center justify-center p-4 border rounded-lg bg-gray-50 dark:bg-gray-900">
            <p className="text-sm text-center mb-4 text-muted-foreground">
              Open WhatsApp on your phone &rarr; Linked Devices &rarr; Link a Device &rarr; Scan this QR Code
            </p>
            <div className="bg-white p-2 rounded-lg">
              <Image src={qrCode} alt="WhatsApp QR Code" width={256} height={256} />
            </div>
          </div>
        )}
      </CardContent>
    </Card>
  );
}
