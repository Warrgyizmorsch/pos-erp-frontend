"use client";

import { useEffect, useState } from "react";
import { motion } from "framer-motion";
import { Plug, MessageCircle, Mail, Loader2, Save } from "lucide-react";
import { toast } from "sonner";
import { PageHeader } from "@/components/shared/PageHeader";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { integrationService, Integration } from "@/services/integrationService";

export default function IntegrationsPage() {
  const [integration, setIntegration] = useState<Integration | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [twilioContentSid, setTwilioContentSid] = useState("");

  useEffect(() => {
    fetchIntegrations();
  }, []);

  const fetchIntegrations = async () => {
    try {
      setLoading(true);
      const res = await integrationService.getIntegrations();
      if (res.success) {
        setIntegration(res.data);
        if (res.data?.whatsapp) {
          setTwilioContentSid(res.data.whatsapp.twilioContentSid || "");
        }
      }
    } catch (error) {
      toast.error("Failed to load integrations");
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (section: keyof Integration) => {
    try {
      setSaving(true);
      if (!integration) return;

      const res = await integrationService.updateIntegrations({
        [section]: integration[section]
      });
      
      if (res.success) {
        setIntegration(res.data);
        toast.success(`${section} settings saved successfully`);
      }
    } catch (error) {
      toast.error("Failed to save integration settings");
    } finally {
      setSaving(false);
    }
  };

  const updateWhatsApp = (field: string, value: any) => {
    setIntegration(prev => prev ? {
      ...prev,
      whatsapp: { ...prev.whatsapp, [field]: value } as any
    } : null);
  };

  if (loading) {
    return (
      <div className="flex items-center justify-center h-96">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
      </div>
    );
  }

  return (
    <div className="space-y-6 w-full max-w-5xl mx-auto">
      <PageHeader title="Integrations" description="Manage third-party connections and APIs" icon={Plug} />

      <Tabs defaultValue="whatsapp" className="w-full flex flex-col md:flex-row gap-6">
        <TabsList className="flex flex-row md:flex-col justify-start h-auto w-full md:w-64 bg-muted/50 p-2 space-x-2 md:space-x-0 md:space-y-2">
          <TabsTrigger value="whatsapp" className="w-full justify-start gap-2 px-4 py-3 data-[state=active]:bg-background data-[state=active]:shadow-sm">
            <MessageCircle className="h-4 w-4" />
            WhatsApp
          </TabsTrigger>
          <TabsTrigger value="email" className="w-full justify-start gap-2 px-4 py-3 data-[state=active]:bg-background data-[state=active]:shadow-sm">
            <Mail className="h-4 w-4" />
            Email (SMTP)
          </TabsTrigger>
        </TabsList>

        <div className="flex-1">
          <TabsContent value="whatsapp" className="m-0 focus-visible:outline-none">
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
              <Card>
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div>
                      <CardTitle>WhatsApp Integration</CardTitle>
                      <CardDescription>Send automated bills and notifications via WhatsApp</CardDescription>
                    </div>
                    <Switch 
                      checked={integration?.whatsapp?.isActive || false}
                      onCheckedChange={(val) => updateWhatsApp('isActive', val)}
                    />
                  </div>
                </CardHeader>
                <CardContent className="space-y-6">
                  <div className="space-y-2">
                    <Label>Provider</Label>
                    <Select 
                      value={integration?.whatsapp?.provider || 'kapso'} 
                      onValueChange={(val) => updateWhatsApp('provider', val)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Provider" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="kapso">Kapso WhatsApp API</SelectItem>
                        <SelectItem value="twilio" disabled>Twilio (Disabled)</SelectItem>
                        <SelectItem value="meta" disabled>Meta Cloud API (Coming Soon)</SelectItem>
                        <SelectItem value="wati" disabled>WATI (Coming Soon)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  {integration?.whatsapp?.provider === 'twilio' && (
                    <div className="space-y-4 p-4 border rounded-lg bg-muted/20">
                      <h4 className="font-medium text-sm">Twilio Credentials</h4>
                      <div className="space-y-2">
                        <Label>Account SID</Label>
                        <Input 
                          placeholder="ACxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
                          value={integration?.whatsapp?.twilioSid || ''}
                          onChange={(e) => updateWhatsApp('twilioSid', e.target.value)}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Auth Token</Label>
                        <Input 
                          type="password" 
                          placeholder="Your Twilio Auth Token" 
                          value={integration?.whatsapp?.twilioAuthToken || ''}
                          onChange={(e) => updateWhatsApp('twilioAuthToken', e.target.value)}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Twilio WhatsApp Number</Label>
                        <Input 
                          placeholder="e.g. +14155238886" 
                          value={integration?.whatsapp?.twilioNumber || ''}
                          onChange={(e) => updateWhatsApp('twilioNumber', e.target.value)}
                        />
                        <p className="text-[10px] text-muted-foreground mt-1">Include country code without spaces.</p>
                      </div>
                      <div className="space-y-2">
                        <Label>Template SID (Optional for Sandbox)</Label>
                        <Input 
                          placeholder="HXxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
                          value={integration?.whatsapp?.twilioContentSid || ''}
                          onChange={(e) => updateWhatsApp('twilioContentSid', e.target.value)}
                        />
                        <p className="text-[10px] text-muted-foreground mt-1">If your Twilio Sandbox forces Content API, paste the Template SID here.</p>
                      </div>
                    </div>
                  )}

                  {integration?.whatsapp?.provider === 'kapso' && (
                    <div className="space-y-4 p-4 border rounded-lg bg-muted/20">
                      <h4 className="font-medium text-sm">Kapso Credentials</h4>
                      <div className="space-y-2">
                        <Label>Kapso API Key</Label>
                        <Input 
                          placeholder="Your Kapso Project API Key" 
                          value={integration?.whatsapp?.kapsoApiKey || ''}
                          onChange={(e) => updateWhatsApp('kapsoApiKey', e.target.value)}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label>Phone Number ID</Label>
                        <Input 
                          placeholder="Your WhatsApp Business Phone Number ID" 
                          value={integration?.whatsapp?.kapsoPhoneNumberId || ''}
                          onChange={(e) => updateWhatsApp('kapsoPhoneNumberId', e.target.value)}
                        />
                      </div>
                    </div>
                  )}

                  <div className="flex justify-end pt-4">
                    <Button onClick={() => handleSave('whatsapp')} disabled={saving} className="gap-2">
                      {saving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
                      Save WhatsApp Settings
                    </Button>
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </TabsContent>

          <TabsContent value="email" className="m-0 focus-visible:outline-none">
            <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }}>
              <Card>
                <CardHeader>
                  <CardTitle>Email Settings</CardTitle>
                  <CardDescription>Configure SMTP server to send emails</CardDescription>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center justify-center p-12 text-muted-foreground bg-muted/20 rounded-lg border border-dashed">
                    This module will be activated in the next phase.
                  </div>
                </CardContent>
              </Card>
            </motion.div>
          </TabsContent>
        </div>
      </Tabs>
    </div>
  );
}
