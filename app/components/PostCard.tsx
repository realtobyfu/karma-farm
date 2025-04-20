import React from 'react';
import { TouchableOpacity } from 'react-native';
import { Card, Text, YStack, XStack, Stack, Paragraph, Button } from 'tamagui';
import { formatDistanceToNow } from 'date-fns';
import { PostWithUser } from '@lib/types';
import { Avatar } from './Avatar';
import { Badge } from './Badge';
import { colors } from '../../tamagui.config';

interface PostCardProps {
  post: PostWithUser;
  onPress: (post: PostWithUser) => void;
  onMessagePress?: (post: PostWithUser) => void;
  showDistance?: boolean;
  distance?: number;
}

export const PostCard: React.FC<PostCardProps> = ({
  post,
  onPress,
  onMessagePress,
  showDistance = false,
  distance,
}) => {
  // Get relative time from post creation date
  const timeAgo = formatDistanceToNow(new Date(post.created_at), { addSuffix: true });

  // Get badge color based on post type
  const getTypeColor = () => {
    switch (post.type) {
      case 'skillshare':
        return '#9C27B0'; // Purple for skillshare
      case 'task':
        return '#2196F3'; // Blue for task
      case 'interest':
        return '#FF9800'; // Orange for interest
      default:
        return colors.primary;
    }
  };

  // Format post type for display
  const getTypeLabel = () => {
    switch (post.type) {
      case 'skillshare':
        return 'Skillshare';
      case 'task':
        return 'Task';
      case 'interest':
        return 'Interest';
      default:
        return '';
    }
  };

  // Format mode for display
  const getModeLabel = () => {
    return post.mode === 'offer' ? 'Offering' : 'Requesting';
  };

  return (
    <TouchableOpacity onPress={() => onPress(post)} activeOpacity={0.7}>
      <Card
        bordered
        elevate
        size="$4"
        animation="bouncy"
        scale={0.95}
        bordered={post.is_completed}
        borderColor={post.is_completed ? colors.primary : undefined}
        opacity={post.is_completed ? 0.8 : 1}
        backgroundColor={colors.card}
        margin={8}
      >
        <Card.Header padded>
          <XStack flex={1} gap="$3" alignItems="center">
            <Avatar
              uri={post.user.avatar_url}
              name={post.user.public_name}
              showBadge
              isTufts={post.user.is_tufts}
              isVerified={post.user.is_verified}
            />
            <YStack flex={1}>
              <Text fontWeight="600" fontSize={16} color={colors.text}>
                {post.user.public_name}
              </Text>
              <Text fontSize={12} color="$gray9">
                {timeAgo}
              </Text>
            </YStack>
            <Stack>
              <XStack gap="$2">
                <Badge
                  type="karma"
                  value={post.karma_value}
                  size="sm"
                />
                {showDistance && distance !== undefined && (
                  <Text fontSize={12} color="$gray9">
                    {distance < 1 ? `${Math.round(distance * 1000)}m` : `${distance.toFixed(1)}km`}
                  </Text>
                )}
              </XStack>
            </Stack>
          </XStack>
        </Card.Header>

        <Card.Footer padded gap="$2">
          <XStack gap="$2" marginBottom="$2">
            <Badge
              type="verified"
              size="sm"
            />
            <Text
              backgroundColor={getTypeColor()}
              color="white"
              paddingHorizontal={8}
              paddingVertical={2}
              borderRadius={8}
              fontSize={10}
            >
              {getTypeLabel()}
            </Text>
            <Text
              backgroundColor={post.mode === 'offer' ? colors.primary : colors.warning}
              color="white"
              paddingHorizontal={8}
              paddingVertical={2}
              borderRadius={8}
              fontSize={10}
            >
              {getModeLabel()}
            </Text>
            {post.is_online && (
              <Text
                backgroundColor="$blue9"
                color="white"
                paddingHorizontal={8}
                paddingVertical={2}
                borderRadius={8}
                fontSize={10}
              >
                Online
              </Text>
            )}
          </XStack>

          <Text fontWeight="700" fontSize={18} marginBottom="$1" color={colors.text}>
            {post.title}
          </Text>
          <Paragraph size="$2" numberOfLines={3} marginBottom="$2" color={colors.text}>
            {post.text}
          </Paragraph>

          {onMessagePress && (
            <Button
              backgroundColor={colors.primary}
              color="white"
              onPress={() => onMessagePress(post)}
              size="$3"
              fontSize={14}
              fontWeight="600"
              borderRadius={8}
            >
              Message
            </Button>
          )}
        </Card.Footer>
      </Card>
    </TouchableOpacity>
  );
};