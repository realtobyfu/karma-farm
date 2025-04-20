import React, { useEffect, useRef } from 'react';
import { Animated, StyleSheet, View } from 'react-native';
import { Text, XStack, Circle, styled } from 'tamagui';
import { colors } from '../../tamagui.config';

interface KarmaCounterProps {
  value: number;
  previousValue?: number;
  size?: 'sm' | 'md' | 'lg';
  showIcon?: boolean;
}

const CounterContainer = styled(XStack, {
  alignItems: 'center',
  gap: 4,
  variants: {
    size: {
      sm: {},
      md: {},
      lg: {},
    },
  } as const,
  defaultVariants: {
    size: 'md',
  },
});

const KarmaIcon = styled(Circle, {
  backgroundColor: colors.primary,
  alignItems: 'center',
  justifyContent: 'center',
  variants: {
    size: {
      sm: {
        size: 16,
      },
      md: {
        size: 24,
      },
      lg: {
        size: 32,
      },
    },
  } as const,
  defaultVariants: {
    size: 'md',
  },
});

export const KarmaCounter: React.FC<KarmaCounterProps> = ({
  value,
  previousValue,
  size = 'md',
  showIcon = true,
}) => {
  const scaleAnim = useRef(new Animated.Value(1)).current;
  const opacityAnim = useRef(new Animated.Value(0)).current;

  // Determine font size based on size prop
  const getFontSize = () => {
    switch (size) {
      case 'sm':
        return 12;
      case 'lg':
        return 18;
      default:
        return 14;
    }
  };

  // Animate when karma increases
  useEffect(() => {
    if (previousValue !== undefined && value > previousValue) {
      // Reset animations
      opacityAnim.setValue(0);
      scaleAnim.setValue(1);

      // Start animations
      Animated.sequence([
        Animated.parallel([
          Animated.timing(scaleAnim, {
            toValue: 1.3,
            duration: 300,
            useNativeDriver: true,
          }),
          Animated.timing(opacityAnim, {
            toValue: 1,
            duration: 200,
            useNativeDriver: true,
          }),
        ]),
        Animated.timing(scaleAnim, {
          toValue: 1,
          duration: 200,
          useNativeDriver: true,
        }),
        Animated.timing(opacityAnim, {
          toValue: 0,
          duration: 200,
          useNativeDriver: true,
        }),
      ]).start();
    }
  }, [value, previousValue, scaleAnim, opacityAnim]);

  return (
    <View style={styles.container}>
      <CounterContainer size={size}>
        {showIcon && (
          <KarmaIcon size={size}>
            <Text color="white" fontWeight="bold" fontSize={getFontSize() - 2}>
              K
            </Text>
          </KarmaIcon>
        )}
        <Animated.View
          style={[
            styles.valueContainer,
            { transform: [{ scale: scaleAnim }] },
          ]}
        >
          <Text
            color={colors.text}
            fontWeight="600"
            fontSize={getFontSize()}
          >
            {value}
          </Text>
        </Animated.View>
      </CounterContainer>

      {/* Animated +1 indicator */}
      <Animated.Text
        style={[
          styles.incrementText,
          {
            opacity: opacityAnim,
            transform: [
              { translateY: opacityAnim.interpolate({
                inputRange: [0, 1],
                outputRange: [0, -20]
              }) },
            ],
          },
        ]}
      >
        +{previousValue !== undefined ? value - previousValue : 1}
      </Animated.Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'relative',
  },
  valueContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  incrementText: {
    position: 'absolute',
    color: colors.primary,
    fontWeight: 'bold',
    right: 0,
    fontSize: 12,
  },
}); 