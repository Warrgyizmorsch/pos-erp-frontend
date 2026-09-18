"use client";

import { PageHeader } from "@/components/shared/PageHeader";
import { WhatsAppSettings } from "@/components/settings/WhatsAppSettings";
import { motion } from "framer-motion";

export default function WhatsAppPage() {
  return (
    <div className="flex-1 space-y-4 p-4 md:p-6 max-w-7xl mx-auto w-full">
      <PageHeader 
        title="WhatsApp Integration" 
        description="Manage your WhatsApp connection for automated messaging and invoices."
      />

      <motion.div 
        initial={{ opacity: 0, y: 20 }} 
        animate={{ opacity: 1, y: 0 }} 
        transition={{ duration: 0.4 }}
      >
        <WhatsAppSettings />
      </motion.div>
    </div>
  );
}
