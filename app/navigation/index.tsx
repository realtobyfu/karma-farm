import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { Ionicons } from '@expo/vector-icons';
import { supabase } from '@lib/supabase';
import { useAuthStore } from '@store/auth';
import { RootStackParamList, TabParamList } from '@lib/types';
import { colors } from '../../tamagui.config';

// Auth Screens
import AuthScreen from '@screens/auth/AuthScreen';
import PhoneVerificationScreen from '@screens/auth/PhoneVerificationScreen';
import OtpVerificationScreen from '@screens/auth/OtpVerificationScreen';
import EmailVerificationScreen from '@screens/auth/EmailVerificationScreen';
import FaceVerificationScreen from '@screens/auth/FaceVerificationScreen';
import ProfileSetupScreen from '@screens/auth/ProfileSetupScreen';

// Tab Screens and their Stacks
import MapScreen from '@screens/map/MapScreen';
import PostDetailsScreen from '@screens/shared/PostDetailsScreen';
import FeedScreen from '@screens/feed/FeedScreen';
import NewPostScreen from '@screens/post/NewPostScreen';
import LocationPickerScreen from '@screens/post/LocationPickerScreen';
import ChatListScreen from '@screens/chat/ChatListScreen';
import ChatRoomScreen from '@screens/chat/ChatRoomScreen';
import ProfileScreen from '@screens/profile/ProfileScreen';
import EditProfileScreen from '@screens/profile/EditProfileScreen';
import KarmaHistoryScreen from '@screens/profile/KarmaHistoryScreen';
import ReviewsScreen from '@screens/profile/ReviewsScreen';
import SettingsScreen from '@screens/profile/SettingsScreen';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tab = createBottomTabNavigator<TabParamList>();

const MapStack = createNativeStackNavigator();
const FeedStack = createNativeStackNavigator();
const ChatStack = createNativeStackNavigator();
const ProfileStack = createNativeStackNavigator();
const NewPostStack = createNativeStackNavigator();

const MapStackNavigator = () => (
  <MapStack.Navigator
    screenOptions={{ 
      headerShown: true,
      headerStyle: { backgroundColor: colors.background },
      headerTintColor: colors.text,
      headerTitleStyle: { fontWeight: '600' },
    }}
  >
    <MapStack.Screen name="MapScreen" component={MapScreen} options={{ title: 'Map' }} />
    <MapStack.Screen 
      name="PostDetails" 
      component={PostDetailsScreen} 
      options={{ title: 'Post Details' }}
    />
  </MapStack.Navigator>
);

const FeedStackNavigator = () => (
  <FeedStack.Navigator
    screenOptions={{ 
      headerShown: true,
      headerStyle: { backgroundColor: colors.background },
      headerTintColor: colors.text,
      headerTitleStyle: { fontWeight: '600' },
    }}
  >
    <FeedStack.Screen name="FeedScreen" component={FeedScreen} options={{ title: 'Feed' }} />
    <FeedStack.Screen 
      name="PostDetails" 
      component={PostDetailsScreen} 
      options={{ title: 'Post Details' }} 
    />
  </FeedStack.Navigator>
);

const ChatStackNavigator = () => (
  <ChatStack.Navigator
    screenOptions={{ 
      headerShown: true,
      headerStyle: { backgroundColor: colors.background },
      headerTintColor: colors.text,
      headerTitleStyle: { fontWeight: '600' },
    }}
  >
    <ChatStack.Screen name="ChatList" component={ChatListScreen} options={{ title: 'Chats' }} />
    <ChatStack.Screen 
      name="ChatRoom" 
      component={ChatRoomScreen} 
      options={({ route }) => ({ 
        title: route.params?.name || 'Chat',
      })} 
    />
  </ChatStack.Navigator>
);

const ProfileStackNavigator = () => (
  <ProfileStack.Navigator
    screenOptions={{ 
      headerShown: true,
      headerStyle: { backgroundColor: colors.background },
      headerTintColor: colors.text,
      headerTitleStyle: { fontWeight: '600' },
    }}
  >
    <ProfileStack.Screen 
      name="ProfileScreen" 
      component={ProfileScreen} 
      options={{ title: 'Profile' }} 
    />
    <ProfileStack.Screen 
      name="EditProfile" 
      component={EditProfileScreen} 
      options={{ title: 'Edit Profile' }} 
    />
    <ProfileStack.Screen 
      name="KarmaHistory" 
      component={KarmaHistoryScreen} 
      options={{ title: 'Karma History' }} 
    />
    <ProfileStack.Screen 
      name="Reviews" 
      component={ReviewsScreen} 
      options={{ title: 'Reviews' }} 
    />
    <ProfileStack.Screen 
      name="Settings" 
      component={SettingsScreen} 
      options={{ title: 'Settings' }} 
    />
  </ProfileStack.Navigator>
);

const NewPostStackNavigator = () => (
  <NewPostStack.Navigator
    screenOptions={{ 
      headerShown: true,
      headerStyle: { backgroundColor: colors.background },
      headerTintColor: colors.text,
      headerTitleStyle: { fontWeight: '600' },
      presentation: 'modal',
    }}
  >
    <NewPostStack.Screen 
      name="NewPostScreen" 
      component={NewPostScreen} 
      options={{ title: 'New Post' }} 
    />
    <NewPostStack.Screen 
      name="LocationPicker" 
      component={LocationPickerScreen} 
      options={{ title: 'Choose Location' }} 
    />
  </NewPostStack.Navigator>
);

const TabNavigator = () => (
  <Tab.Navigator
    screenOptions={({ route }) => ({
      tabBarIcon: ({ focused, color, size }) => {
        let iconName;

        if (route.name === 'Map') {
          iconName = focused ? 'map' : 'map-outline';
        } else if (route.name === 'Feed') {
          iconName = focused ? 'list' : 'list-outline';
        } else if (route.name === 'NewPost') {
          iconName = focused ? 'add-circle' : 'add-circle-outline';
        } else if (route.name === 'Chat') {
          iconName = focused ? 'chatbubbles' : 'chatbubbles-outline';
        } else if (route.name === 'Profile') {
          iconName = focused ? 'person' : 'person-outline';
        }

        return <Ionicons name={iconName as any} size={size} color={color} />;
      },
      tabBarActiveTintColor: colors.primary,
      tabBarInactiveTintColor: 'gray',
      headerShown: false,
    })}
  >
    <Tab.Screen name="Map" component={MapStackNavigator} />
    <Tab.Screen name="Feed" component={FeedStackNavigator} />
    <Tab.Screen name="NewPost" component={NewPostStackNavigator} options={{ tabBarLabel: 'Post' }} />
    <Tab.Screen name="Chat" component={ChatStackNavigator} />
    <Tab.Screen name="Profile" component={ProfileStackNavigator} />
  </Tab.Navigator>
);

export default function AppNavigation() {
  const { session, setSession, setUser, initialized, setInitialized } = useAuthStore();

  useEffect(() => {
    // Check for an existing session on startup
    const checkSession = async () => {
      const { data } = await supabase.auth.getSession();
      setSession(data.session);

      if (data.session?.user) {
        // Get user profile
        const { data: user } = await supabase
          .from('users')
          .select('*')
          .eq('id', data.session.user.id)
          .single();
        
        if (user) {
          setUser(user);
        }
      }

      setInitialized(true);
    };

    checkSession();

    // Listen for auth changes
    const { data: authListener } = supabase.auth.onAuthStateChange(
      async (event, newSession) => {
        setSession(newSession);

        if (newSession?.user) {
          // Get user profile or create one if it doesn't exist
          const { data: existingUser } = await supabase
            .from('users')
            .select('*')
            .eq('id', newSession.user.id)
            .single();

          if (existingUser) {
            setUser(existingUser);
          }
        }
      }
    );

    return () => {
      authListener.subscription.unsubscribe();
    };
  }, []);

  // Show loading or splash screen while initializing
  if (!initialized) {
    return null; // or a loading component
  }

  return (
    <NavigationContainer>
      <Stack.Navigator screenOptions={{ headerShown: false }}>
        {session && session.user ? (
          // User is signed in
          <Stack.Screen name="Main" component={TabNavigator} />
        ) : (
          // Auth screens
          <>
            <Stack.Screen name="Auth" component={AuthScreen} />
            <Stack.Screen name="PhoneVerification" component={PhoneVerificationScreen} />
            <Stack.Screen name="OtpVerification" component={OtpVerificationScreen} />
            <Stack.Screen name="EmailVerification" component={EmailVerificationScreen} />
            <Stack.Screen name="FaceVerification" component={FaceVerificationScreen} />
            <Stack.Screen name="ProfileSetup" component={ProfileSetupScreen} />
          </>
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
} 