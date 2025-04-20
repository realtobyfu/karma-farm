import React, { useEffect, useState } from 'react';
import { ScrollView, StyleSheet } from 'react-native';
import { 
  YStack, 
  XStack, 
  Text, 
  Separator, 
  Button,
  Card,
  Image,
} from 'tamagui';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { supabase } from '@lib/supabase';
import { KarmaTransaction, ProfileStackParamList, Review } from '@lib/types';
import { useAuthStore } from '@store/auth';
import { Avatar } from '@components/Avatar';
import { Badge } from '@components/Badge';
import { KarmaCounter } from '@components/KarmaCounter';
import { RatingStars } from '@components/RatingStars';
import { colors } from '../../../tamagui.config';

type ProfileScreenNavigationProp = StackNavigationProp<ProfileStackParamList, 'ProfileScreen'>;

export default function ProfileScreen() {
  const navigation = useNavigation<ProfileScreenNavigationProp>();
  const { user, signOut } = useAuthStore();
  const [karmaTransactions, setKarmaTransactions] = useState<KarmaTransaction[]>([]);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [averageRating, setAverageRating] = useState(0);

  useEffect(() => {
    if (user) {
      fetchKarmaTransactions();
      fetchReviews();
    }
  }, [user]);

  const fetchKarmaTransactions = async () => {
    if (!user) return;
    
    try {
      const { data, error } = await supabase
        .from('karma_transactions')
        .select('*')
        .or(`sender_id.eq.${user.id},receiver_id.eq.${user.id}`)
        .order('created_at', { ascending: false })
        .limit(5);
        
      if (error) throw error;
      
      setKarmaTransactions(data);
    } catch (error) {
      console.error('Error fetching karma transactions:', error);
    }
  };

  const fetchReviews = async () => {
    if (!user) return;
    
    try {
      const { data, error } = await supabase
        .from('reviews')
        .select('*')
        .eq('reviewee_id', user.id)
        .order('created_at', { ascending: false });
        
      if (error) throw error;
      
      setReviews(data);
      
      // Calculate average rating
      if (data.length > 0) {
        const avgRating = data.reduce((sum, review) => sum + review.rating, 0) / data.length;
        setAverageRating(Math.round(avgRating * 10) / 10);
      }
    } catch (error) {
      console.error('Error fetching reviews:', error);
    }
  };

  const handleEditProfile = () => {
    navigation.navigate('EditProfile');
  };

  const handleViewKarmaHistory = () => {
    navigation.navigate('KarmaHistory');
  };

  const handleViewReviews = () => {
    navigation.navigate('Reviews');
  };

  const handleSettings = () => {
    navigation.navigate('Settings');
  };

  const handleSignOut = async () => {
    await signOut();
  };

  if (!user) {
    return (
      <YStack flex={1} justifyContent="center" alignItems="center">
        <Text>Loading profile...</Text>
      </YStack>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <YStack padding="$4" space="$4">
        {/* Profile Header */}
        <XStack space="$4" alignItems="center">
          <Avatar 
            uri={user.avatar_url} 
            name={user.public_name}
            size={80}
            showBadge
            isTufts={user.is_tufts}
            isVerified={user.is_verified}
          />
          
          <YStack flex={1} space="$1">
            <Text fontSize="$6" fontWeight="700" color={colors.text}>
              {user.public_name}
            </Text>
            
            <XStack space="$2" flexWrap="wrap">
              {user.is_tufts && <Badge type="tufts" size="sm" />}
              {user.is_verified && <Badge type="verified" size="sm" />}
              
              <XStack space="$1" alignItems="center">
                <RatingStars rating={averageRating} size={16} readOnly />
                <Text fontSize="$2" color="$gray9">({reviews.length})</Text>
              </XStack>
            </XStack>
            
            <Text fontSize="$3" marginTop="$1">
              Joined {new Date(user.created_at).toLocaleDateString()}
            </Text>
          </YStack>
        </XStack>
        
        {/* Karma Total Card */}
        <Card backgroundColor={colors.surface} padding="$4" borderRadius={16}>
          <XStack alignItems="center" justifyContent="space-between">
            <YStack>
              <Text fontSize="$4" fontWeight="600" color={colors.text}>
                Karma Balance
              </Text>
              <Text fontSize="$2" color="$gray9">
                Your total earned karma
              </Text>
            </YStack>
            
            <KarmaCounter value={user.karma_total} size="lg" />
          </XStack>
          
          <Button 
            marginTop="$3" 
            backgroundColor="transparent" 
            color={colors.primary}
            borderColor={colors.primary}
            borderWidth={1}
            onPress={handleViewKarmaHistory}
          >
            View History
          </Button>
        </Card>
        
        {/* About Me */}
        {user.about && (
          <YStack space="$2">
            <Text fontSize="$4" fontWeight="600" color={colors.text}>
              About Me
            </Text>
            <Text fontSize="$3" color={colors.text}>
              {user.about}
            </Text>
          </YStack>
        )}
        
        {/* Recent Karma Activity */}
        <YStack space="$2">
          <XStack justifyContent="space-between" alignItems="center">
            <Text fontSize="$4" fontWeight="600" color={colors.text}>
              Recent Karma Activity
            </Text>
            <Button size="$2" backgroundColor="transparent" color={colors.primary} onPress={handleViewKarmaHistory}>
              See All
            </Button>
          </XStack>
          
          {karmaTransactions.length > 0 ? (
            karmaTransactions.map((transaction) => (
              <Card key={transaction.id} padding="$3" marginVertical="$1">
                <XStack justifyContent="space-between" alignItems="center">
                  <YStack>
                    <Text fontSize="$3" fontWeight="500" color={colors.text}>
                      {transaction.receiver_id === user.id ? 'Received' : 'Sent'} Karma
                    </Text>
                    {transaction.reason && (
                      <Text fontSize="$2" color="$gray9" numberOfLines={1}>
                        {transaction.reason}
                      </Text>
                    )}
                  </YStack>
                  <Text 
                    fontSize="$4" 
                    fontWeight="bold" 
                    color={transaction.receiver_id === user.id ? colors.primary : colors.text}
                  >
                    {transaction.receiver_id === user.id ? '+' : '-'}{transaction.amount}
                  </Text>
                </XStack>
              </Card>
            ))
          ) : (
            <Text color="$gray9" textAlign="center" padding="$2">
              No karma transactions yet.
            </Text>
          )}
        </YStack>
        
        {/* Reviews */}
        <YStack space="$2">
          <XStack justifyContent="space-between" alignItems="center">
            <Text fontSize="$4" fontWeight="600" color={colors.text}>
              Reviews ({reviews.length})
            </Text>
            <Button size="$2" backgroundColor="transparent" color={colors.primary} onPress={handleViewReviews}>
              See All
            </Button>
          </XStack>
          
          {reviews.length > 0 ? (
            reviews.slice(0, 2).map((review) => (
              <Card key={review.id} padding="$3" marginVertical="$1">
                <YStack space="$1">
                  <RatingStars rating={review.rating} size={16} readOnly />
                  {review.text && (
                    <Text fontSize="$3" color={colors.text} numberOfLines={2}>
                      {review.text}
                    </Text>
                  )}
                </YStack>
              </Card>
            ))
          ) : (
            <Text color="$gray9" textAlign="center" padding="$2">
              No reviews yet.
            </Text>
          )}
        </YStack>
        
        {/* Actions */}
        <YStack space="$3" marginTop="$2">
          <Button 
            backgroundColor={colors.primary}
            color={colors.onPrimary}
            size="$4"
            icon={<Ionicons name="create-outline" size={18} color={colors.onPrimary} />}
            onPress={handleEditProfile}
          >
            Edit Profile
          </Button>
          
          <Button 
            backgroundColor={colors.surface}
            color={colors.text}
            size="$4"
            icon={<Ionicons name="settings-outline" size={18} color={colors.text} />}
            onPress={handleSettings}
          >
            Settings
          </Button>
          
          <Button 
            backgroundColor="$gray3"
            color="$red9"
            size="$4"
            icon={<Ionicons name="log-out-outline" size={18} color="$red9" />}
            onPress={handleSignOut}
          >
            Sign Out
          </Button>
        </YStack>
      </YStack>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
}); 