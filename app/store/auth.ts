import { create } from 'zustand';
import { supabase } from '@lib/supabase';
import { User } from '@lib/types';
import { Session } from '@supabase/supabase-js';

interface AuthState {
  session: Session | null;
  user: User | null;
  isLoading: boolean;
  error: Error | null;
  initialized: boolean;
  signInWithPhone: (phone: string) => Promise<{ error: Error | null }>;
  verifyOtp: (phone: string, token: string) => Promise<{ error: Error | null; session: Session | null }>;
  verifyEmail: (email: string) => Promise<{ error: Error | null }>;
  updateUserProfile: (updates: Partial<User>) => Promise<{ error: Error | null; user: User | null }>;
  signOut: () => Promise<void>;
  setSession: (session: Session | null) => void;
  setUser: (user: User | null) => void;
  setInitialized: (initialized: boolean) => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  session: null,
  user: null,
  isLoading: false,
  error: null,
  initialized: false,

  signInWithPhone: async (phone: string) => {
    set({ isLoading: true, error: null });
    try {
      const { error } = await supabase.auth.signInWithOtp({
        phone,
      });

      if (error) throw error;

      return { error: null };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error };
    } finally {
      set({ isLoading: false });
    }
  },

  verifyOtp: async (phone: string, token: string) => {
    set({ isLoading: true, error: null });
    try {
      const { data, error } = await supabase.auth.verifyOtp({
        phone,
        token,
        type: 'sms',
      });

      if (error) throw error;

      // If successful, set the session
      set({ session: data?.session ?? null });

      return { error: null, session: data?.session ?? null };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error, session: null };
    } finally {
      set({ isLoading: false });
    }
  },

  verifyEmail: async (email: string) => {
    set({ isLoading: true, error: null });
    try {
      // Check if the email is from Tufts
      const isTuftsEmail = email.endsWith('@tufts.edu');

      // Get the user's profile
      const { data: user } = await supabase
        .from('users')
        .select('*')
        .eq('id', get().session?.user.id!)
        .single();

      if (user) {
        // Update the profile with the email and Tufts status
        const { error } = await supabase
          .from('users')
          .update({
            email,
            is_tufts: isTuftsEmail,
          })
          .eq('id', get().session?.user.id!);

        if (error) throw error;

        // Update the user in the store
        set({
          user: {
            ...user,
            email,
            is_tufts: isTuftsEmail,
          },
        });
      }

      return { error: null };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error };
    } finally {
      set({ isLoading: false });
    }
  },

  updateUserProfile: async (updates) => {
    set({ isLoading: true, error: null });
    try {
      const { error } = await supabase
        .from('users')
        .update(updates)
        .eq('id', get().session?.user?.id!);

      if (error) throw error;

      const { data: user } = await supabase
        .from('users')
        .select('*')
        .eq('id', get().session?.user?.id!)
        .single();

      set({ user });
      
      return { error: null, user };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error, user: null };
    } finally {
      set({ isLoading: false });
    }
  },

  signOut: async () => {
    set({ isLoading: true });
    try {
      await supabase.auth.signOut();
      set({ session: null, user: null });
    } catch (error) {
      set({ error: error as Error });
    } finally {
      set({ isLoading: false });
    }
  },

  setSession: (session) => set({ session }),
  setUser: (user) => set({ user }),
  setInitialized: (initialized) => set({ initialized }),
})); 