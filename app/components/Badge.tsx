import React from 'react';
import { Text, XStack, styled } from 'tamagui';
import { colors } from '../../tamagui.config';

type BadgeType = 'tufts' | 'verified' | 'karma';

interface BadgeProps {
  type: BadgeType;
  value?: number;
  size?: 'sm' | 'md' | 'lg';
}

const BadgeContainer = styled(XStack, {
  borderRadius: 12,
  paddingHorizontal: 8,
  paddingVertical: 4,
  alignItems: 'center',
  justifyContent: 'center',
  borderWidth: 1,
  borderColor: 'transparent',
  variants: {
    type: {
      tufts: {
        backgroundColor: '#3E8EDE', // Tufts blue
      },
      verified: {
        backgroundColor: colors.primary,
      },
      karma: {
        backgroundColor: colors.background,
        borderColor: colors.primary,
      },
    },
    size: {
      sm: {
        borderRadius: 8,
        paddingHorizontal: 6,
        paddingVertical: 2,
      },
      md: {
        borderRadius: 12,
        paddingHorizontal: 8,
        paddingVertical: 4,
      },
      lg: {
        borderRadius: 16,
        paddingHorizontal: 10,
        paddingVertical: 6,
      },
    },
  } as const,
  defaultVariants: {
    size: 'md',
  },
});

export const Badge: React.FC<BadgeProps> = ({ 
  type, 
  value,
  size = 'md' 
}) => {
  const getBadgeText = () => {
    switch (type) {
      case 'tufts':
        return 'Tufts';
      case 'verified':
        return 'Verified';
      case 'karma':
        return `${value} Karma`;
      default:
        return '';
    }
  };

  return (
    <BadgeContainer type={type} size={size}>
      <Text
        color={type === 'karma' ? colors.primary : 'white'}
        fontWeight="500"
        fontSize={size === 'sm' ? 10 : size === 'md' ? 12 : 14}
      >
        {getBadgeText()}
      </Text>
    </BadgeContainer>
  );
}; 