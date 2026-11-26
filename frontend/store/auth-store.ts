import { create } from 'zustand';
import type { User } from '@/types';

interface AuthState {
  user: User | null;
  accessToken: string | null;
  isInitialized: boolean;
  setAuth: (user: User, accessToken: string) => void;
  setAccessToken: (accessToken: string | null) => void;
  clearAuth: () => void;
  setInitialized: (initialized: boolean) => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  accessToken: null,
  isInitialized: false,
  setAuth: (user, accessToken) => set({ user, accessToken, isInitialized: true }),
  setAccessToken: (accessToken) => set({ accessToken }),
  clearAuth: () => set({ user: null, accessToken: null, isInitialized: true }),
  setInitialized: (isInitialized) => set({ isInitialized }),
}));
