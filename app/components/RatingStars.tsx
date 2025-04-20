import React from 'react';
import { TouchableOpacity, StyleSheet } from 'react-native';
import { XStack, Text } from 'tamagui';
import { colors } from '../../tamagui.config';

interface RatingStarsProps {
  rating: number;
  maxRating?: number;
  size?: number;
  onChange?: (rating: number) => void;
  readOnly?: boolean;
}

export const RatingStars: React.FC<RatingStarsProps> = ({
  rating,
  maxRating = 5,
  size = 24,
  onChange,
  readOnly = false,
}) => {
  const renderStar = (index: number) => {
    // Check if the current star should be filled
    const filled = index < rating;

    // Determine star character based on filled status
    const starChar = filled ? '★' : '☆';

    // Determine star color based on filled status
    const starColor = filled ? colors.warning : '#CCCCCC';

    if (readOnly) {
      return (
        <Text
          key={`star-${index}`}
          style={[styles.star, { color: starColor, fontSize: size }]}
        >
          {starChar}
        </Text>
      );
    }

    return (
      <TouchableOpacity
        key={`star-${index}`}
        onPress={() => onChange && onChange(index + 1)}
        style={styles.starButton}
      >
        <Text style={[styles.star, { color: starColor, fontSize: size }]}>
          {starChar}
        </Text>
      </TouchableOpacity>
    );
  };

  return (
    <XStack space="$0.5">
      {Array.from({ length: maxRating }).map((_, index) => renderStar(index))}
    </XStack>
  );
};

const styles = StyleSheet.create({
  star: {
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 1,
    textShadowColor: 'rgba(0, 0, 0, 0.15)',
  },
  starButton: {
    padding: 2,
  },
}); 