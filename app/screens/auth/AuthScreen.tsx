import React from 'react';
import { Image } from 'react-native';
import { H1, Button, YStack, Text, XStack } from 'tamagui';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@lib/types';
import { colors } from '../../../tamagui.config';

type AuthScreenNavigationProp = StackNavigationProp<RootStackParamList, 'Auth'>;

export default function AuthScreen() {
  const navigation = useNavigation<AuthScreenNavigationProp>();

  return (
    <YStack
      flex={1}
      alignItems="center"
      justifyContent="center"
      padding="$4"
      backgroundColor={colors.background}
      space="$4"
    >
      <YStack alignItems="center" marginBottom="$6">
        <Image
          source={require('../../../assets/logo.png')}
          style={{ width: 120, height: 120, marginBottom: 20 }}
          resizeMode="contain"
        />
        <H1 textAlign="center" color={colors.text}>
          Welcome to Karma Farm
        </H1>
        <Text
          textAlign="center"
          marginTop="$2"
          color="$gray9"
          maxWidth={300}
        >
          Help others, earn karma, build community.
        </Text>
      </YStack>

      <YStack space="$4" width="100%" maxWidth={350}>
        <Button
          backgroundColor={colors.primary}
          color={colors.onPrimary}
          size="$5"
          fontWeight="600"
          onPress={() => navigation.navigate('PhoneVerification')}
        >
          Continue with Phone
        </Button>

        <XStack alignItems="center" justifyContent="center" marginVertical="$2">
          <Text color="$gray9" textAlign="center" fontSize="$2">
            By continuing, you agree to our Terms of Service and Privacy Policy
          </Text>
        </XStack>
      </YStack>
    </YStack>
  );
} 