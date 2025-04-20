-- Create extensions
CREATE EXTENSION IF NOT EXISTS "postgis";

-- Create custom types
CREATE TYPE post_type AS ENUM ('skillshare', 'task', 'interest');
CREATE TYPE post_mode AS ENUM ('request', 'offer');

-- Create tables
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  public_name TEXT NOT NULL,
  avatar_url TEXT,
  is_tufts BOOLEAN DEFAULT FALSE,
  is_verified BOOLEAN DEFAULT FALSE,
  karma_total INTEGER DEFAULT 0,
  about TEXT,
  phone_number TEXT UNIQUE,
  email TEXT UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.posts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type post_type NOT NULL,
  mode post_mode NOT NULL,
  karma_value INTEGER NOT NULL CHECK (karma_value > 0),
  title TEXT NOT NULL,
  text TEXT NOT NULL,
  geom GEOMETRY(Point, 4326),
  is_online BOOLEAN DEFAULT FALSE,
  is_completed BOOLEAN DEFAULT FALSE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.chats (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
  user_a UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(post_id, user_a, user_b)
);

CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id UUID NOT NULL REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.karma_transactions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  receiver_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount INTEGER NOT NULL CHECK (amount > 0),
  reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reviewer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  reviewee_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  text TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  UNIQUE(reviewer_id, reviewee_id)
);

-- Create indexes
CREATE INDEX IF NOT EXISTS posts_geom_idx ON public.posts USING GIST (geom);
CREATE INDEX IF NOT EXISTS posts_user_id_idx ON public.posts (user_id);
CREATE INDEX IF NOT EXISTS chats_post_id_idx ON public.chats (post_id);
CREATE INDEX IF NOT EXISTS chats_user_a_idx ON public.chats (user_a);
CREATE INDEX IF NOT EXISTS chats_user_b_idx ON public.chats (user_b);
CREATE INDEX IF NOT EXISTS messages_chat_id_idx ON public.messages (chat_id);
CREATE INDEX IF NOT EXISTS karma_sender_idx ON public.karma_transactions (sender_id);
CREATE INDEX IF NOT EXISTS karma_receiver_idx ON public.karma_transactions (receiver_id);
CREATE INDEX IF NOT EXISTS reviews_reviewee_idx ON public.reviews (reviewee_id);

-- Create functions
CREATE OR REPLACE FUNCTION public.award_karma(sender_id UUID, receiver_id UUID, amount INTEGER, reason TEXT DEFAULT NULL)
RETURNS VOID AS $$
BEGIN
  -- Prevent self-awarding
  IF sender_id = receiver_id THEN
    RAISE EXCEPTION 'Cannot award karma to yourself';
  END IF;

  -- Insert the transaction
  INSERT INTO public.karma_transactions (sender_id, receiver_id, amount, reason)
  VALUES (sender_id, receiver_id, amount, reason);

  -- Update the receiver's karma total
  UPDATE public.users
  SET karma_total = karma_total + amount
  WHERE id = receiver_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create triggers
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE PROCEDURE public.set_updated_at();

CREATE TRIGGER set_posts_updated_at
BEFORE UPDATE ON public.posts
FOR EACH ROW
EXECUTE PROCEDURE public.set_updated_at();

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.karma_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users table policies
CREATE POLICY "Users can view all profiles"
  ON public.users FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON public.users FOR UPDATE
  USING (auth.uid() = id);

-- Posts table policies
CREATE POLICY "Anyone can view posts"
  ON public.posts FOR SELECT
  USING (true);

CREATE POLICY "Users can create posts"
  ON public.posts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
  ON public.posts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
  ON public.posts FOR DELETE
  USING (auth.uid() = user_id);

-- Chats table policies
CREATE POLICY "Users can view own chats"
  ON public.chats FOR SELECT
  USING (auth.uid() = user_a OR auth.uid() = user_b);

CREATE POLICY "Users can create chats with post owners"
  ON public.chats FOR INSERT
  WITH CHECK (
    auth.uid() = user_a OR auth.uid() = user_b
  );

-- Messages table policies
CREATE POLICY "Users can view messages in their chats"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.chats
      WHERE chats.id = messages.chat_id
      AND (chats.user_a = auth.uid() OR chats.user_b = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in their chats"
  ON public.messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.chats
      WHERE chats.id = messages.chat_id
      AND (chats.user_a = auth.uid() OR chats.user_b = auth.uid())
    )
  );

-- Karma transactions policies
CREATE POLICY "Users can view their karma transactions"
  ON public.karma_transactions FOR SELECT
  USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

CREATE POLICY "Users can create karma transactions"
  ON public.karma_transactions FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
  );

-- Reviews policies
CREATE POLICY "Anyone can view reviews"
  ON public.reviews FOR SELECT
  USING (true);

CREATE POLICY "Users can write reviews"
  ON public.reviews FOR INSERT
  WITH CHECK (
    auth.uid() = reviewer_id
  );

CREATE POLICY "Users can update their reviews"
  ON public.reviews FOR UPDATE
  USING (
    auth.uid() = reviewer_id
  );

-- Realtime publication setup
BEGIN;
  -- Publications for realtime subscriptions
  DROP PUBLICATION IF EXISTS supabase_realtime;
  CREATE PUBLICATION supabase_realtime FOR TABLE messages, chats;
COMMIT; 