"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Megaphone, Send } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { marketingService } from "@/services/marketingService";
import { toast } from "sonner";

export default function CreateCampaign() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    name: "",
    targetAudience: "all_customers",
    messageTemplate: "",
  });

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!formData.name || !formData.messageTemplate) {
      return toast.error("Please fill all required fields");
    }

    setLoading(true);
    try {
      await marketingService.createCampaign(formData);
      toast.success("Campaign started successfully!");
      router.push("/marketing");
    } catch (error: any) {
      toast.error(error.response?.data?.message || "Failed to start campaign");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-3xl mx-auto space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Create Campaign</h1>
        <p className="text-muted-foreground">Setup your bulk WhatsApp message.</p>
      </div>

      <div className="bg-amber-500/10 border border-amber-500/20 rounded-lg p-4 flex gap-3 items-start">
        <Megaphone className="h-5 w-5 text-amber-500 shrink-0 mt-0.5" />
        <div>
          <h5 className="font-medium text-amber-700 dark:text-amber-500">Important Note on WhatsApp Limits</h5>
          <p className="text-sm text-amber-700/80 dark:text-amber-500/80 mt-1">
            Since there are no approved templates currently configured, messages sent to customers who haven't interacted with your business in the last 24 hours might fail due to WhatsApp API restrictions. 
          </p>
        </div>
      </div>

      <Card>
        <form onSubmit={handleSubmit}>
          <CardHeader>
            <CardTitle>Campaign Details</CardTitle>
            <CardDescription>Define who will receive this message and what it will say.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            <div className="space-y-2">
              <Label>Campaign Name</Label>
              <Input 
                placeholder="e.g. Diwali Mega Sale 2026" 
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                required
              />
            </div>

            <div className="space-y-2">
              <Label>Target Audience</Label>
              <Select 
                value={formData.targetAudience} 
                onValueChange={(val) => setFormData({ ...formData, targetAudience: val })}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Select audience" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all_customers">All Customers</SelectItem>
                  <SelectItem value="top_spenders">Top Spenders (&gt; ₹10,000)</SelectItem>
                  <SelectItem value="inactive">Inactive Customers</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label>Message Content</Label>
              <Textarea 
                placeholder="Type your promotional message here..." 
                className="min-h-[150px]"
                value={formData.messageTemplate}
                onChange={(e) => setFormData({ ...formData, messageTemplate: e.target.value })}
                required
              />
              <p className="text-xs text-muted-foreground">
                For best results, keep your message clear and include a call to action.
              </p>
            </div>
          </CardContent>
          <CardFooter className="flex justify-end gap-3 border-t p-6">
            <Button variant="outline" type="button" onClick={() => router.back()}>Cancel</Button>
            <Button type="submit" className="gap-2" disabled={loading}>
              <Send className="h-4 w-4" />
              {loading ? "Processing..." : "Start Campaign"}
            </Button>
          </CardFooter>
        </form>
      </Card>
    </div>
  );
}
