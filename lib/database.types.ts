export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      chats: {
        Row: {
          created_at: string
          id: string
          post_id: string
          user_a: string
          user_b: string
        }
        Insert: {
          created_at?: string
          id?: string
          post_id: string
          user_a: string
          user_b: string
        }
        Update: {
          created_at?: string
          id?: string
          post_id?: string
          user_a?: string
          user_b?: string
        }
        Relationships: [
          {
            foreignKeyName: "chats_post_id_fkey"
            columns: ["post_id"]
            isOneToOne: false
            referencedRelation: "posts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chats_user_a_fkey"
            columns: ["user_a"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "chats_user_b_fkey"
            columns: ["user_b"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      karma_transactions: {
        Row: {
          amount: number
          created_at: string
          id: string
          reason: string | null
          receiver_id: string
          sender_id: string
        }
        Insert: {
          amount: number
          created_at?: string
          id?: string
          reason?: string | null
          receiver_id: string
          sender_id: string
        }
        Update: {
          amount?: number
          created_at?: string
          id?: string
          reason?: string | null
          receiver_id?: string
          sender_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "karma_transactions_receiver_id_fkey"
            columns: ["receiver_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "karma_transactions_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      messages: {
        Row: {
          chat_id: string
          created_at: string
          id: string
          sender_id: string
          text: string
        }
        Insert: {
          chat_id: string
          created_at?: string
          id?: string
          sender_id: string
          text: string
        }
        Update: {
          chat_id?: string
          created_at?: string
          id?: string
          sender_id?: string
          text?: string
        }
        Relationships: [
          {
            foreignKeyName: "messages_chat_id_fkey"
            columns: ["chat_id"]
            isOneToOne: false
            referencedRelation: "chats"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "messages_sender_id_fkey"
            columns: ["sender_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      posts: {
        Row: {
          created_at: string
          expires_at: string | null
          geom: unknown | null
          id: string
          is_completed: boolean
          is_online: boolean
          karma_value: number
          mode: Database["public"]["Enums"]["post_mode"]
          text: string
          title: string
          type: Database["public"]["Enums"]["post_type"]
          updated_at: string
          user_id: string
        }
        Insert: {
          created_at?: string
          expires_at?: string | null
          geom?: unknown | null
          id?: string
          is_completed?: boolean
          is_online?: boolean
          karma_value: number
          mode: Database["public"]["Enums"]["post_mode"]
          text: string
          title: string
          type: Database["public"]["Enums"]["post_type"]
          updated_at?: string
          user_id: string
        }
        Update: {
          created_at?: string
          expires_at?: string | null
          geom?: unknown | null
          id?: string
          is_completed?: boolean
          is_online?: boolean
          karma_value?: number
          mode?: Database["public"]["Enums"]["post_mode"]
          text?: string
          title?: string
          type?: Database["public"]["Enums"]["post_type"]
          updated_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "posts_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      reviews: {
        Row: {
          created_at: string
          id: string
          rating: number
          reviewee_id: string
          reviewer_id: string
          text: string | null
        }
        Insert: {
          created_at?: string
          id?: string
          rating: number
          reviewee_id: string
          reviewer_id: string
          text?: string | null
        }
        Update: {
          created_at?: string
          id?: string
          rating?: number
          reviewee_id?: string
          reviewer_id?: string
          text?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "reviews_reviewee_id_fkey"
            columns: ["reviewee_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_reviewer_id_fkey"
            columns: ["reviewer_id"]
            isOneToOne: false
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
      users: {
        Row: {
          about: string | null
          avatar_url: string | null
          created_at: string
          email: string | null
          id: string
          is_tufts: boolean
          is_verified: boolean
          karma_total: number
          phone_number: string | null
          public_name: string
          updated_at: string
        }
        Insert: {
          about?: string | null
          avatar_url?: string | null
          created_at?: string
          email?: string | null
          id: string
          is_tufts?: boolean
          is_verified?: boolean
          karma_total?: number
          phone_number?: string | null
          public_name: string
          updated_at?: string
        }
        Update: {
          about?: string | null
          avatar_url?: string | null
          created_at?: string
          email?: string | null
          id?: string
          is_tufts?: boolean
          is_verified?: boolean
          karma_total?: number
          phone_number?: string | null
          public_name?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "users_id_fkey"
            columns: ["id"]
            isOneToOne: true
            referencedRelation: "users"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      award_karma: {
        Args: {
          sender_id: string
          receiver_id: string
          amount: number
          reason?: string
        }
        Returns: undefined
      }
    }
    Enums: {
      post_mode: "request" | "offer"
      post_type: "skillshare" | "task" | "interest"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
} 