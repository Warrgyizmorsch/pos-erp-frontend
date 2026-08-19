import api from "./api";
import type { User, Role } from "@/types";

interface AuthResponse {
  success: boolean;
  data: User;
  token: string;
  message?: string;
}

export const authService = {
  login: async (email: string, password: string): Promise<AuthResponse> => {
    const { data } = await api.post<AuthResponse>("/auth/login", { email, password });
    return data;
  },

  register: async (payload: {
    name: string;
    email: string;
    password: string;
    role?: string;
    phone?: string;
  }): Promise<AuthResponse> => {
    const { data } = await api.post<AuthResponse>("/auth/register", payload);
    return data;
  },

  getMe: async () => {
    const { data } = await api.get("/auth/me");
    return data;
  },

  updateProfile: async (payload: { name: string; phone?: string }) => {
    const { data } = await api.put("/auth/profile", payload);
    return data;
  },

  changePassword: async (payload: { currentPassword?: string; newPassword?: string }) => {
    const { data } = await api.put("/auth/change-password", payload);
    return data;
  },

  getUsers: async (): Promise<{ success: boolean; data: User[] }> => {
    const { data } = await api.get("/auth/users");
    return data;
  },

  updateUser: async (id: string, payload: Partial<User> & { password?: string }): Promise<{ success: boolean; data: User }> => {
    const { data } = await api.put(`/auth/users/${id}`, payload);
    return data;
  },

  createUser: async (payload: Partial<User> & { password?: string }): Promise<{ success: boolean; data: User }> => {
    const { data } = await api.post(`/auth/users`, payload);
    return data;
  },

  deleteUser: async (id: string): Promise<{ success: boolean; message: string }> => {
    const { data } = await api.delete(`/auth/users/${id}`);
    return data;
  },

  getRoles: async (): Promise<{ success: boolean; data: Role[] }> => {
    const { data } = await api.get("/auth/roles");
    return data;
  },

  updateRolePermissions: async (id: string, permissions: string[]): Promise<{ success: boolean; data: Role }> => {
    const { data } = await api.put(`/auth/roles/${id}`, { permissions });
    return data;
  },
};
