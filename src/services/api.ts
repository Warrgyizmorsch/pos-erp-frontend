import axios from "axios";
import { API_BASE_URL } from "@/constants";

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Request interceptor for auth token
api.interceptors.request.use(
  (config) => {
    if (typeof window !== "undefined") {
      const token = localStorage.getItem("pos-token");
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    }
    
    // For FormData uploads, remove Content-Type so axios sets multipart/form-data automatically
    if (config.data instanceof FormData) {
      delete config.headers["Content-Type"];
    }
    
    return config;
  },
  (error) => Promise.reject(error)
);

let isRefreshing = false;
let failedQueue: Array<{ resolve: (value?: unknown) => void; reject: (reason?: any) => void }> = [];

const processQueue = (error: any, token: string | null = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error);
    } else {
      prom.resolve(token);
    }
  });
  failedQueue = [];
};

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;
    
    if (error.response?.status === 401) {
      if (typeof window !== "undefined") {
        const isLoginRequest = originalRequest.url?.includes('/auth/login');
        const isRefreshRequest = originalRequest.url?.includes('/auth/refresh');
        
        if (!isLoginRequest && !isRefreshRequest && window.location.pathname !== '/login') {
          if (!originalRequest._retry) {
            if (isRefreshing) {
              return new Promise(function(resolve, reject) {
                failedQueue.push({ resolve, reject });
              }).then(token => {
                originalRequest.headers['Authorization'] = 'Bearer ' + token;
                return api(originalRequest);
              }).catch(err => {
                return Promise.reject(err);
              });
            }

            originalRequest._retry = true;
            isRefreshing = true;

            try {
              const res = await axios.post(`${API_BASE_URL}/auth/refresh`, {}, { withCredentials: true });
              const { token } = res.data;
              
              localStorage.setItem("pos-token", token);
              api.defaults.headers.common['Authorization'] = 'Bearer ' + token;
              originalRequest.headers['Authorization'] = 'Bearer ' + token;
              
              processQueue(null, token);
              return api(originalRequest);
            } catch (refreshError) {
              processQueue(refreshError, null);
              localStorage.removeItem("pos-token");
              localStorage.removeItem("pos-user");
              window.location.href = "/login";
              return Promise.reject(refreshError);
            } finally {
              isRefreshing = false;
            }
          }
        }
      }
    }
    return Promise.reject(error);
  }
);

export default api;
