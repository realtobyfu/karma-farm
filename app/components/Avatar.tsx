import React from 'react';
import { Image } from 'react-native';
import { Text, Circle, Stack, styled } from 'tamagui';
import { colors } from '../../tamagui.config';

interface AvatarProps {
  uri?: string | null;
  name: string;
  size?: number;
  showBadge?: boolean;
  isTufts?: boolean;
  isVerified?: boolean;
}

const StyledAvatar = styled(Circle, {
  overflow: 'hidden',
  backgroundColor: colors.primary,
  alignItems: 'center',
  justifyContent: 'center',
  borderWidth: 2,
  borderColor: 'white',
});

const TuftsBadge = styled(Circle, {
  position: 'absolute',
  right: 2,
  bottom: 2,
  backgroundColor: '#3E8EDE', // Tufts blue
  borderWidth: 1,
  borderColor: 'white',
  alignItems: 'center',
  justifyContent: 'center',
});

const VerifiedBadge = styled(Circle, {
  position: 'absolute',
  right: 2,
  bottom: 2,
  backgroundColor: colors.primary,
  borderWidth: 1,
  borderColor: 'white',
  alignItems: 'center',
  justifyContent: 'center',
});

export const Avatar: React.FC<AvatarProps> = ({ 
  uri, 
  name, 
  size = 40, 
  showBadge = false, 
  isTufts = false, 
  isVerified = false 
}) => {
  // Generate initials from the name
  const initials = name
    .split(' ')
    .map((n) => n[0])
    .join('')
    .toUpperCase()
    .substring(0, 2);

  // Determine which badge to show (if any)
  // Priority: Tufts > Verified
  const badgeType = showBadge && (isTufts ? 'tufts' : isVerified ? 'verified' : null);

  return (
    <Stack position="relative">
      <StyledAvatar size={size}>
        {uri ? (
          <Image
            source={{ uri }}
            style={{ width: size, height: size }}
            resizeMode="cover"
          />
        ) : (
          <Text color="white" fontWeight="500" fontSize={size / 3}>
            {initials}
          </Text>
        )}
      </StyledAvatar>

      {badgeType === 'tufts' && (
        <TuftsBadge size={size / 3.5}>
          <Text color="white" fontSize={size / 7} fontWeight="bold">
            T
          </Text>
        </TuftsBadge>
      )}

      {badgeType === 'verified' && (
        <VerifiedBadge size={size / 3.5}>
          <Text color="white" fontSize={size / 7} fontWeight="bold">
            ✓
          </Text>
        </VerifiedBadge>
      )}
    </Stack>
  );
}; 