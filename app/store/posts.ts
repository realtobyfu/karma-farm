import { create } from 'zustand';
import { supabase } from '@lib/supabase';
import { Post, PostWithUser, PostFilters, GeoPoint, NewPost } from '@lib/types';
import * as Location from 'expo-location';

interface PostsState {
  posts: PostWithUser[];
  currentPost: PostWithUser | null;
  isLoading: boolean;
  error: Error | null;
  filters: PostFilters;
  userLocation: Location.LocationObject | null;
  fetchPosts: () => Promise<void>;
  fetchPostById: (id: string) => Promise<PostWithUser | null>;
  createPost: (post: NewPost) => Promise<{ error: Error | null; post: Post | null }>;
  updatePost: (id: string, updates: Partial<Post>) => Promise<{ error: Error | null }>;
  deletePost: (id: string) => Promise<{ error: Error | null }>;
  markPostCompleted: (id: string, receiverId: string, karmaAmount: number) => Promise<{ error: Error | null }>;
  setFilters: (filters: Partial<PostFilters>) => void;
  getUserLocation: () => Promise<Location.LocationObject | null>;
  pointToGeoPoint: (latitude: number, longitude: number) => GeoPoint;
}

export const usePostsStore = create<PostsState>((set, get) => ({
  posts: [],
  currentPost: null,
  isLoading: false,
  error: null,
  filters: {
    radius: 10, // 10km by default
  },
  userLocation: null,

  fetchPosts: async () => {
    set({ isLoading: true, error: null });
    try {
      // Start with a base query
      let query = supabase
        .from('posts')
        .select(`
          *,
          user:users(
            id, public_name, avatar_url, is_tufts, is_verified, karma_total, about, created_at
          )
        `)
        .order('created_at', { ascending: false });

      // Apply filters if any
      const filters = get().filters;
      
      if (filters.type) {
        query = query.eq('type', filters.type);
      }
      
      if (filters.mode) {
        query = query.eq('mode', filters.mode);
      }
      
      if (filters.is_online !== undefined) {
        query = query.eq('is_online', filters.is_online);
      }
      
      if (filters.is_completed !== undefined) {
        query = query.eq('is_completed', filters.is_completed);
      }
      
      // Filter by expiration (only show posts that have not expired)
      query = query.or(`expires_at.is.null,expires_at.gt.${new Date().toISOString()}`);
      
      // Apply geospatial filter if we have user location and radius
      const userLocation = get().userLocation;
      const radius = filters.radius || 10; // default 10km
      
      if (userLocation && !filters.is_online) {
        const geoPoint = get().pointToGeoPoint(userLocation.coords.latitude, userLocation.coords.longitude);
        // Filter by distance (if not online and we have user location)
        query = query.or(`is_online.eq.true,st_dwithin(geom, st_makepoint(${geoPoint.coordinates[0]}, ${geoPoint.coordinates[1]}), ${radius * 1000})`);
      }

      const { data, error } = await query;

      if (error) throw error;

      set({ posts: data as PostWithUser[], isLoading: false });
    } catch (error) {
      set({ error: error as Error, isLoading: false });
      console.error('Error fetching posts:', error);
    }
  },

  fetchPostById: async (id: string) => {
    set({ isLoading: true, error: null });
    try {
      const { data, error } = await supabase
        .from('posts')
        .select(`
          *,
          user:users(
            id, public_name, avatar_url, is_tufts, is_verified, karma_total, about, created_at
          )
        `)
        .eq('id', id)
        .single();

      if (error) throw error;

      set({ currentPost: data as PostWithUser, isLoading: false });
      return data as PostWithUser;
    } catch (error) {
      set({ error: error as Error, isLoading: false });
      console.error('Error fetching post by ID:', error);
      return null;
    }
  },

  createPost: async (post: NewPost) => {
    set({ isLoading: true, error: null });
    try {
      const { data, error } = await supabase
        .from('posts')
        .insert(post)
        .select()
        .single();

      if (error) throw error;

      // Refresh the posts list
      get().fetchPosts();

      return { error: null, post: data as Post };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error, post: null };
    } finally {
      set({ isLoading: false });
    }
  },

  updatePost: async (id: string, updates: Partial<Post>) => {
    set({ isLoading: true, error: null });
    try {
      const { error } = await supabase
        .from('posts')
        .update(updates)
        .eq('id', id);

      if (error) throw error;

      // Refresh the posts list and current post
      get().fetchPosts();
      if (get().currentPost?.id === id) {
        get().fetchPostById(id);
      }

      return { error: null };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error };
    } finally {
      set({ isLoading: false });
    }
  },

  deletePost: async (id: string) => {
    set({ isLoading: true, error: null });
    try {
      const { error } = await supabase
        .from('posts')
        .delete()
        .eq('id', id);

      if (error) throw error;

      // Remove the post from the state
      set((state) => ({
        posts: state.posts.filter((post) => post.id !== id),
        currentPost: state.currentPost?.id === id ? null : state.currentPost,
      }));

      return { error: null };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error };
    } finally {
      set({ isLoading: false });
    }
  },

  markPostCompleted: async (id: string, receiverId: string, karmaAmount: number) => {
    set({ isLoading: true, error: null });
    try {
      // First mark the post as completed
      const { error: updateError } = await supabase
        .from('posts')
        .update({ is_completed: true })
        .eq('id', id);

      if (updateError) throw updateError;

      // Then award karma to the recipient
      const { error: rpcError } = await supabase.rpc('award_karma', {
        sender_id: supabase.auth.getSession().then(({ data }) => data.session?.user.id),
        receiver_id: receiverId,
        amount: karmaAmount,
        reason: `Completed post ${id}`,
      });

      if (rpcError) throw rpcError;

      // Refresh the posts list and current post
      get().fetchPosts();
      if (get().currentPost?.id === id) {
        get().fetchPostById(id);
      }

      return { error: null };
    } catch (error) {
      set({ error: error as Error });
      return { error: error as Error };
    } finally {
      set({ isLoading: false });
    }
  },

  setFilters: (filters: Partial<PostFilters>) => {
    set((state) => ({
      filters: { ...state.filters, ...filters },
    }));
    // Fetch posts with the new filters
    get().fetchPosts();
  },

  getUserLocation: async () => {
    try {
      // Check for permissions
      const { status } = await Location.requestForegroundPermissionsAsync();
      
      if (status !== 'granted') {
        throw new Error('Permission to access location was denied');
      }

      // Get the current location
      const location = await Location.getCurrentPositionAsync({});
      set({ userLocation: location });
      return location;
    } catch (error) {
      console.error('Error getting location:', error);
      return null;
    }
  },

  pointToGeoPoint: (latitude: number, longitude: number): GeoPoint => {
    return {
      type: 'Point',
      coordinates: [longitude, latitude], // Note: GeoJSON uses [longitude, latitude]
      crs: {
        type: 'name',
        properties: {
          name: 'urn:ogc:def:crs:EPSG::4326',
        },
      },
    };
  },
})); 