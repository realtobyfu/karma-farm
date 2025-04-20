import React, { useEffect, useState } from 'react';
import { FlatList, RefreshControl } from 'react-native';
import { YStack, Spinner, Text, Button, XStack } from 'tamagui';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/native-stack';
import { Ionicons } from '@expo/vector-icons';
import { FeedStackParamList, PostType, PostMode } from '@lib/types';
import { usePostsStore } from '@store/posts';
import { PostCard } from '@components/PostCard';
import { colors } from '../../../tamagui.config';

type FeedScreenNavigationProp = StackNavigationProp<FeedStackParamList, 'FeedScreen'>;

type FilterChip = {
  label: string;
  value: PostType | PostMode | null;
  type: 'type' | 'mode';
};

export default function FeedScreen() {
  const navigation = useNavigation<FeedScreenNavigationProp>();
  const [refreshing, setRefreshing] = useState(false);
  const { posts, isLoading, fetchPosts, filters, setFilters } = usePostsStore();

  // Define filter chips
  const filterChips: FilterChip[] = [
    { label: 'All', value: null, type: 'type' },
    { label: 'Skillshare', value: 'skillshare', type: 'type' },
    { label: 'Tasks', value: 'task', type: 'type' },
    { label: 'Interests', value: 'interest', type: 'type' },
    { label: 'Offers', value: 'offer', type: 'mode' },
    { label: 'Requests', value: 'request', type: 'mode' },
  ];

  useEffect(() => {
    fetchPosts();
  }, []);

  const handleRefresh = async () => {
    setRefreshing(true);
    await fetchPosts();
    setRefreshing(false);
  };

  const handlePostPress = (postId: string) => {
    navigation.navigate('PostDetails', { postId });
  };

  const handleFilter = (filter: FilterChip) => {
    // If it's the "All" filter, clear the relevant type of filter
    if (filter.value === null) {
      const updatedFilters = { ...filters };
      delete updatedFilters[filter.type];
      setFilters(updatedFilters);
      return;
    }

    // Otherwise, apply the filter
    if (filter.type === 'type') {
      setFilters({ ...filters, type: filter.value as PostType });
    } else if (filter.type === 'mode') {
      setFilters({ ...filters, mode: filter.value as PostMode });
    }
  };

  // Check if a filter is active
  const isFilterActive = (filter: FilterChip) => {
    if (filter.value === null) {
      // The "All" filter is active if no filter of its type is set
      return !filters[filter.type];
    }
    return filters[filter.type] === filter.value;
  };

  // Get filter chip color based on type
  const getFilterColor = (filter: FilterChip) => {
    if (filter.type === 'type') {
      switch(filter.value) {
        case 'skillshare': return '#9C27B0';
        case 'task': return '#2196F3';
        case 'interest': return '#FF9800';
        default: return colors.primary;
      }
    } else if (filter.type === 'mode') {
      return filter.value === 'offer' ? colors.primary : colors.warning;
    }
    return colors.primary;
  };

  return (
    <YStack flex={1} backgroundColor={colors.background}>
      {/* Filter chips */}
      <XStack padding="$2" paddingHorizontal="$3" gap="$2" flexWrap="wrap">
        {filterChips.map((filter) => (
          <Button
            key={`${filter.type}-${filter.value}`}
            size="$2"
            backgroundColor={isFilterActive(filter) ? getFilterColor(filter) : '$gray3'}
            color={isFilterActive(filter) ? 'white' : colors.text}
            borderRadius={16}
            fontWeight="500"
            onPress={() => handleFilter(filter)}
          >
            {filter.label}
          </Button>
        ))}
      </XStack>

      {isLoading && !refreshing ? (
        <YStack flex={1} justifyContent="center" alignItems="center">
          <Spinner size="large" color={colors.primary} />
        </YStack>
      ) : posts.length === 0 ? (
        <YStack flex={1} justifyContent="center" alignItems="center" padding="$4">
          <Ionicons name="search-outline" size={48} color={colors.primary} />
          <Text textAlign="center" fontSize="$4" fontWeight="600" color={colors.text} marginTop="$2">
            No posts found
          </Text>
          <Text textAlign="center" fontSize="$2" color="$gray9" marginTop="$1">
            Try changing your filters or check back later.
          </Text>
          <Button 
            marginTop="$4" 
            backgroundColor={colors.primary} 
            color="white"
            onPress={handleRefresh}
          >
            Refresh
          </Button>
        </YStack>
      ) : (
        <FlatList
          data={posts}
          keyExtractor={(item) => item.id}
          renderItem={({ item }) => (
            <PostCard
              post={item}
              onPress={() => handlePostPress(item.id)}
              onMessagePress={() => navigation.navigate('PostDetails', { postId: item.id })}
            />
          )}
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={handleRefresh}
              tintColor={colors.primary}
              colors={[colors.primary]}
            />
          }
          contentContainerStyle={{ paddingBottom: 20 }}
        />
      )}
    </YStack>
  );
} 