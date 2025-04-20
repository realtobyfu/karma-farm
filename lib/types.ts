// User types
export type User = {
  id: string;
  public_name: string;
  avatar_url: string | null;
  is_tufts: boolean;
  is_verified: boolean;
  karma_total: number;
  about: string | null;
  phone_number: string | null;
  email: string | null;
  created_at: string;
  updated_at: string;
};

export type UserProfile = {
  id: string;
  public_name: string;
  avatar_url: string | null;
  is_tufts: boolean;
  is_verified: boolean;
  karma_total: number;
  about: string | null;
  created_at: string;
};

// Post types
export type PostType = 'skillshare' | 'task' | 'interest';
export type PostMode = 'request' | 'offer';

export type Post = {
  id: string;
  user_id: string;
  type: PostType;
  mode: PostMode;
  karma_value: number;
  title: string;
  text: string;
  geom: GeoPoint | null;
  is_online: boolean;
  is_completed: boolean;
  expires_at: string | null;
  created_at: string;
  updated_at: string;
};

export type GeoPoint = {
  type: 'Point';
  coordinates: [number, number]; // [longitude, latitude]
  crs: {
    type: 'name';
    properties: {
      name: 'urn:ogc:def:crs:EPSG::4326';
    };
  };
};

export type PostWithUser = Post & {
  user: UserProfile;
};

export type NewPost = Omit<Post, 'id' | 'created_at' | 'updated_at'>;

export type PostFilters = {
  type?: PostType;
  mode?: PostMode;
  radius?: number; // in km
  is_online?: boolean;
  is_completed?: boolean;
};

// Chat types
export type Chat = {
  id: string;
  post_id: string;
  user_a: string;
  user_b: string;
  created_at: string;
};

export type ChatWithDetails = Chat & {
  post: Post;
  other_user: UserProfile;
  last_message?: Message;
};

// Message types
export type Message = {
  id: string;
  chat_id: string;
  sender_id: string;
  text: string;
  created_at: string;
};

export type NewMessage = Omit<Message, 'id' | 'created_at'>;

// Karma types
export type KarmaTransaction = {
  id: string;
  sender_id: string;
  receiver_id: string;
  amount: number;
  reason: string | null;
  created_at: string;
};

export type KarmaTransactionWithUsers = KarmaTransaction & {
  sender: UserProfile;
  receiver: UserProfile;
};

// Review types
export type Review = {
  id: string;
  reviewer_id: string;
  reviewee_id: string;
  rating: 1 | 2 | 3 | 4 | 5;
  text: string | null;
  created_at: string;
};

export type ReviewWithUser = Review & {
  reviewer: UserProfile;
};

export type NewReview = Omit<Review, 'id' | 'created_at'>;

// Auth types
export type PhoneVerificationInput = {
  phone: string;
};

export type OtpVerificationInput = {
  phone: string;
  token: string;
};

export type EmailVerificationInput = {
  email: string;
};

// Navigation types
export type RootStackParamList = {
  Auth: undefined;
  PhoneVerification: undefined;
  OtpVerification: { phone: string };
  EmailVerification: { phone: string };
  FaceVerification: { phone: string; email?: string };
  Main: undefined;
  ProfileSetup: undefined;
};

export type TabParamList = {
  Map: undefined;
  Feed: undefined;
  NewPost: undefined;
  Chat: undefined;
  Profile: undefined;
};

export type MapStackParamList = {
  MapScreen: undefined;
  PostDetails: { postId: string };
};

export type FeedStackParamList = {
  FeedScreen: undefined;
  PostDetails: { postId: string };
};

export type ChatStackParamList = {
  ChatList: undefined;
  ChatRoom: { chatId: string };
};

export type ProfileStackParamList = {
  ProfileScreen: undefined;
  EditProfile: undefined;
  KarmaHistory: undefined;
  Reviews: undefined;
  Settings: undefined;
};

export type NewPostStackParamList = {
  NewPostScreen: undefined;
  LocationPicker: undefined;
}; 