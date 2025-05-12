import React, { useState } from 'react';
import { KeyboardAvoidingView, Platform } from 'react-native';
import { 
  H3, 
  Button, 
  YStack, 
  Text, 
  Input,
  Spinner
} from 'tamagui';
import { useNavigation, useRoute } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@lib/types';
import { useAuthStore } from '@store/auth';
import { colors } from '../../../tamagui.config';

type OtpVerificationScreenNavigationProp = NativeStackNavigationProp<
  RootStackParamList,
  'OtpVerification'
>;

export default function OtpVerificationScreen() {
  const navigation = useNavigation<OtpVerificationScreenNavigationProp>();
  const route = useRoute();
  const [otp, setOtp] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  
  // Use session directly from auth store instead of signIn
  const { session, setSession } = useAuthStore();
  
  // Access the phone parameter if it exists
  const phone = route.params && 'phone' in route.params ? route.params.phone : '';

  const handleVerify = async () => {
    if (!otp) {
      setError('Please enter verification code');
      return;
    }

    try {
      setIsLoading(true);
      // For now just simulate sign in by showing a message since we haven't implemented the actual verification
      console.log(`Verifying OTP ${otp} for phone ${phone}`);
      
      // Simulate successful login by creating a dummy session
      // This is just a placeholder and will be replaced with actual implementation
      setTimeout(() => {
        // Just use any object to simulate a session
        setSession({ user: { id: 'dummy-user-id' } } as any);
        setIsLoading(false);
      }, 1500);
      
    } catch (error) {
      console.error('Error verifying OTP:', error);
      setError('Failed to verify code. Please try again.');
      setIsLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      style={{ flex: 1 }}
    >
      <YStack
        flex={1}
        alignItems="center"
        justifyContent="center"
        padding="$4"
        backgroundColor={colors.background}
        space="$4"
      >
        <YStack alignItems="center" marginBottom="$6" space="$2">
          <H3 textAlign="center" color={colors.text}>
            Enter verification code
          </H3>
          <Text
            textAlign="center"
            color="$gray9"
            maxWidth={300}
          >
            We've sent a verification code to {phone}
          </Text>
        </YStack>

        <YStack space="$4" width="100%" maxWidth={350}>
          <Input
            placeholder="Enter verification code"
            value={otp}
            onChangeText={setOtp}
            keyboardType="number-pad"
            autoFocus
            size="$5"
            borderColor={error ? colors.error : undefined}
            backgroundColor="$gray2"
          />

          {error && (
            <Text color={colors.error} fontSize="$2">
              {error}
            </Text>
          )}

          <Button
            backgroundColor={colors.primary}
            color={colors.onPrimary}
            size="$5"
            fontWeight="600"
            onPress={handleVerify}
            disabled={isLoading || !otp}
          >
            {isLoading ? <Spinner color={colors.onPrimary} /> : 'Verify'}
          </Button>
        </YStack>
      </YStack>
    </KeyboardAvoidingView>
  );
} 