"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { Plus, Megaphone, Users, CheckCircle2, XCircle, Clock } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { marketingService, type Campaign } from "@/services/marketingService";
import { format } from "date-fns";

export default function MarketingDashboard() {
  const [campaigns, setCampaigns] = useState<Campaign[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchCampaigns();
  }, []);

  const fetchCampaigns = async () => {
    try {
      const res = await marketingService.getCampaigns();
      setCampaigns(res.data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case 'completed': return <Badge variant="default" className="bg-green-500 hover:bg-green-600">Completed</Badge>;
      case 'processing': return <Badge variant="secondary" className="bg-blue-100 text-blue-800">Processing...</Badge>;
      case 'draft': return <Badge variant="outline">Draft</Badge>;
      case 'failed': return <Badge variant="destructive">Failed</Badge>;
      default: return <Badge variant="outline">{status}</Badge>;
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Marketing & Promotions</h1>
          <p className="text-muted-foreground">Manage your bulk WhatsApp campaigns and engage with customers.</p>
        </div>
        <Link href="/marketing/create">
          <Button className="gap-2">
            <Plus className="h-4 w-4" />
            New Campaign
          </Button>
        </Link>
      </div>

      <div className="grid gap-6">
        {loading ? (
          <p>Loading campaigns...</p>
        ) : campaigns.length === 0 ? (
          <Card className="flex flex-col items-center justify-center p-12 text-center">
            <Megaphone className="h-12 w-12 text-muted-foreground/50 mb-4" />
            <h3 className="text-lg font-semibold">No campaigns yet</h3>
            <p className="text-sm text-muted-foreground mb-4">Start reaching out to your customers with special offers.</p>
            <Link href="/marketing/create"><Button variant="outline">Create your first campaign</Button></Link>
          </Card>
        ) : (
          campaigns.map((c) => (
            <Card key={c._id}>
              <CardHeader className="pb-3 flex flex-row items-center justify-between">
                <div>
                  <CardTitle className="text-xl flex items-center gap-2">
                    {c.name}
                    {getStatusBadge(c.status)}
                  </CardTitle>
                  <p className="text-sm text-muted-foreground mt-1">
                    Created on {format(new Date(c.createdAt), "dd MMM yyyy, hh:mm a")}
                  </p>
                </div>
              </CardHeader>
              <CardContent>
                <div className="bg-muted/50 p-4 rounded-md text-sm mb-4">
                  {c.messageTemplate}
                </div>
                <div className="flex items-center gap-6 text-sm">
                  <div className="flex items-center gap-2">
                    <Users className="h-4 w-4 text-muted-foreground" />
                    <span className="font-medium">{c.totalRecipients}</span> Recipients
                  </div>
                  <div className="flex items-center gap-2">
                    <CheckCircle2 className="h-4 w-4 text-green-500" />
                    <span className="font-medium text-green-600">{c.successfulDeliveries || 0}</span> Delivered
                  </div>
                  <div className="flex items-center gap-2">
                    <XCircle className="h-4 w-4 text-red-500" />
                    <span className="font-medium text-red-600">{c.failedDeliveries || 0}</span> Failed
                  </div>
                  {(c.status === 'processing' || c.status === 'draft') && (
                    <div className="flex items-center gap-2">
                      <Clock className="h-4 w-4 text-blue-500" />
                      <span className="font-medium text-blue-600">
                        {c.totalRecipients - ((c.successfulDeliveries || 0) + (c.failedDeliveries || 0))}
                      </span> Pending
                    </div>
                  )}
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  );
}
