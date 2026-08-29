import api from "./api";

export interface Integration {
  _id?: string;
  whatsapp?: {
    provider: string;
    isActive: boolean;
    twilioSid?: string;
    twilioAuthToken?: string;
    twilioNumber?: string;
    twilioContentSid?: string;
    kapsoApiKey?: string;
    kapsoPhoneNumberId?: string;
  };
  email?: {
    provider: string;
    isActive: boolean;
    host?: string;
    port?: number;
    user?: string;
    password?: string;
    sendgridApiKey?: string;
  };
}

export const integrationService = {
  getIntegrations: async (): Promise<{ success: boolean; data: Integration }> => {
    const { data } = await api.get("/integrations");
    return data;
  },

  updateIntegrations: async (payload: Partial<Integration>): Promise<{ success: boolean; data: Integration }> => {
    const { data } = await api.put("/integrations", payload);
    return data;
  },
};
