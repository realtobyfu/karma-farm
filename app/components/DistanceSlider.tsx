import React, { useState } from 'react';
import { StyleSheet } from 'react-native';
import { Slider, Text, YStack, XStack, Circle } from 'tamagui';
import { colors } from '../../tamagui.config';

interface DistanceSliderProps {
  value: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
  step?: number;
}

export const DistanceSlider: React.FC<DistanceSliderProps> = ({
  value,
  onChange,
  min = 1,
  max = 50,
  step = 1,
}) => {
  const [sliderValue, setSliderValue] = useState(value);

  const handleValueChange = (val: number) => {
    setSliderValue(val);
  };

  const handleSlidingComplete = (val: number) => {
    onChange(val);
  };

  // Format the label based on the distance
  const getDistanceLabel = (distance: number) => {
    if (distance < 1) {
      return `${distance * 1000}m`;
    }
    return `${distance}km`;
  };

  return (
    <YStack space="$2" width="100%" paddingHorizontal="$4">
      <XStack justifyContent="space-between" alignItems="center">
        <Text fontWeight="500" color={colors.text}>
          Distance
        </Text>
        <XStack 
          backgroundColor="$gray3" 
          paddingHorizontal="$2" 
          paddingVertical="$1" 
          borderRadius={16}
          alignItems="center"
          gap="$1"
        >
          <Circle size={8} backgroundColor={colors.primary} />
          <Text fontWeight="600" color={colors.text}>
            {getDistanceLabel(sliderValue)}
          </Text>
        </XStack>
      </XStack>
      <Slider
        defaultValue={[value]}
        min={min}
        max={max}
        step={step}
        onValueChange={(vals) => handleValueChange(vals[0])}
        onSlideEnd={(vals) => handleSlidingComplete(vals[0])}
        width="100%"
      >
        <Slider.Track backgroundColor="$gray5">
          <Slider.TrackActive backgroundColor={colors.primary} />
        </Slider.Track>
        <Slider.Thumb 
          index={0} 
          size="$4" 
          circular
          backgroundColor="white"
          borderWidth={2}
          borderColor={colors.primary}
        />
      </Slider>
      <XStack justifyContent="space-between">
        <Text fontSize="$1" color="$gray9">
          {min}km
        </Text>
        <Text fontSize="$1" color="$gray9">
          {max}km
        </Text>
      </XStack>
    </YStack>
  );
}; 