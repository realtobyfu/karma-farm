import { create } from 'zustand';
import { supabase } from '@lib/supabase';
import { Chat, ChatWithDetails, Message, NewMessage, UserProfile } from '@lib/types';
import { RealtimeChannel } from '@supabase/supabase-js';

interface ChatState {
  chats: ChatWithDetails[];
  currentChat: ChatWithDetails | null;
  messages: Message[];
  isLoading: boolean;
  error: Error | null;
  messagesChannel: RealtimeChannel | null;
  fetchChats: () => Promise<void>;
  fetchChatById: (chatId: string) => Promise<ChatWithDetails | null>;
  fetchMessages: (chatId: string) => Promise<Message[]>;
  sendMessage: (message: NewMessage) => Promise<Message | null>;
  createChat: (postId: string, otherUserId: string) => Promise<Chat | null>;
  subscribeToMessages: (chatId: string) => void;
  unsubscribeFromMessages: () => void;
}

export const useChatStore = create<ChatState>((set, get) => ({
  chats: [],
  currentChat: null,
  messages: [],
  isLoading: false,
  error: null,
  messagesChannel: null,

  fetchChats: async () => {
    set({ isLoading: true, error: null });
    try {
      const { data: session } = await supabase.auth.getSession();
      if (!session.session) throw new Error('No active session');

      const userId = session.session.user.id;

      const { data, error } = await supabase
        .from('chats')
        .select(`
          *,
          post:posts(*),
          user_a:users!chats_user_a_fkey(id, public_name, avatar_url, is_tufts, is_verified, karma_total, about, created_at),
          user_b:users!chats_user_b_fkey(id, public_name, avatar_url, is_tufts, is_verified, karma_total, about, created_at)
        `)
        .or(`user_a.eq.${userId},user_b.eq.${userId}`)
        .order('created_at', { ascending: false });

      if (error) throw error;

      // Process data to get the "other user" in each chat
      const chatsWithDetails = data.map((chat: any) => {
        const otherUser = chat.user_a.id === userId ? chat.user_b : chat.user_a;
        return {
          ...chat,
          other_user: otherUser as UserProfile,
        };
      });

      // Fetch last message for each chat
      const chatsWithLastMessage = await Promise.all(
        chatsWithDetails.map(async (chat) => {
          const { data: messages } = await supabase
            .from('messages')
            .select('*')
            .eq('chat_id', chat.id)
            .order('created_at', { ascending: false })
            .limit(1);

          return {
            ...chat,
            last_message: messages && messages.length > 0 ? messages[0] : undefined,
          };
        })
      );

      set({ 
        chats: chatsWithLastMessage as ChatWithDetails[], 
        isLoading: false 
      });
    } catch (error) {
      set({ error: error as Error, isLoading: false });
      console.error('Error fetching chats:', error);
    }
  },

  fetchChatById: async (chatId: string) => {
    set({ isLoading: true, error: null });
    try {
      const { data: session } = await supabase.auth.getSession();
      if (!session.session) throw new Error('No active session');

      const userId = session.session.user.id;

      const { data, error } = await supabase
        .from('chats')
        .select(`
          *,
          post:posts(*),
          user_a:users!chats_user_a_fkey(id, public_name, avatar_url, is_tufts, is_verified, karma_total, about, created_at),
          user_b:users!chats_user_b_fkey(id, public_name, avatar_url, is_tufts, is_verified, karma_total, about, created_at)
        `)
        .eq('id', chatId)
        .single();

      if (error) throw error;

      // Determine the other user
      const otherUser = data.user_a.id === userId ? data.user_b : data.user_a;
      
      const chatDetails = {
        ...data,
        other_user: otherUser as UserProfile,
      };

      set({ currentChat: chatDetails as ChatWithDetails, isLoading: false });
      
      // Subscribe to messages for this chat
      get().subscribeToMessages(chatId);
      
      // Load messages
      await get().fetchMessages(chatId);
      
      return chatDetails as ChatWithDetails;
    } catch (error) {
      set({ error: error as Error, isLoading: false });
      console.error('Error fetching chat by ID:', error);
      return null;
    }
  },

  fetchMessages: async (chatId: string) => {
    set({ isLoading: true, error: null });
    try {
      const { data, error } = await supabase
        .from('messages')
        .select('*')
        .eq('chat_id', chatId)
        .order('created_at', { ascending: true });

      if (error) throw error;

      set({ messages: data as Message[], isLoading: false });
      return data as Message[];
    } catch (error) {
      set({ error: error as Error, isLoading: false });
      console.error('Error fetching messages:', error);
      return [];
    }
  },

  sendMessage: async (message: NewMessage) => {
    set({ isLoading: true, error: null });
    try {
      const { data, error } = await supabase
        .from('messages')
        .insert(message)
        .select()
        .single();

      if (error) throw error;

      // Add the message to the local state immediately (even though we'll get it via realtime)
      set((state) => ({
        messages: [...state.messages, data as Message],
      }));

      return data as Message;
    } catch (error) {
      set({ error: error as Error });
      console.error('Error sending message:', error);
      return null;
    } finally {
      set({ isLoading: false });
    }
  },

  createChat: async (postId: string, otherUserId: string) => {
    set({ isLoading: true, error: null });
    try {
      const { data: session } = await supabase.auth.getSession();
      if (!session.session) throw new Error('No active session');

      const userId = session.session.user.id;

      // Check if chat already exists
      const { data: existingChats, error: fetchError } = await supabase
        .from('chats')
        .select('*')
        .eq('post_id', postId)
        .or(`and(user_a.eq.${userId},user_b.eq.${otherUserId}),and(user_a.eq.${otherUserId},user_b.eq.${userId})`);

      if (fetchError) throw fetchError;

      // If chat exists, return it
      if (existingChats && existingChats.length > 0) {
        return existingChats[0] as Chat;
      }

      // Create a new chat
      const { data, error } = await supabase
        .from('chats')
        .insert({
          post_id: postId,
          user_a: userId,
          user_b: otherUserId,
        })
        .select()
        .single();

      if (error) throw error;

      // Refresh chats list
      get().fetchChats();

      return data as Chat;
    } catch (error) {
      set({ error: error as Error });
      console.error('Error creating chat:', error);
      return null;
    } finally {
      set({ isLoading: false });
    }
  },

  subscribeToMessages: (chatId: string) => {
    // Unsubscribe from any existing subscription
    get().unsubscribeFromMessages();

    // Create a new subscription
    const messagesChannel = supabase
      .channel(`messages:${chatId}`)
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'messages',
          filter: `chat_id=eq.${chatId}`,
        },
        (payload) => {
          const newMessage = payload.new as Message;
          
          set((state) => ({
            messages: [...state.messages, newMessage],
          }));
        }
      )
      .subscribe();

    set({ messagesChannel });
  },

  unsubscribeFromMessages: () => {
    const { messagesChannel } = get();
    if (messagesChannel) {
      messagesChannel.unsubscribe();
      set({ messagesChannel: null });
    }
  },
})); 