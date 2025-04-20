import React, { useState } from 'react';
import { KeyboardAvoidingView, Platform } from 'react-native';
import { 
  H3, 
  Button, 
  YStack, 
  Text, 
  XStack, 
  Input,
  Spinner
} from 'tamagui';
import { useNavigation } from '@react-navigation/native';
import { StackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '@lib/types';
import { useAuthStore } from '@store/auth';
import { colors } from '../../../tamagui.config';

type PhoneVerificationScreenNavigationProp = StackNavigationProp<
  RootStackParamList,
  'PhoneVerification'
>;

export default function PhoneVerificationScreen() {
  const navigation = useNavigation<PhoneVerificationScreenNavigationProp>();
  const [phoneNumber, setPhoneNumber] = useState('');
  const [error, setError] = useState<string | null>(null);
  
  const { signInWithPhone, isLoading } = useAuthStore();

  const handleContinue = async () => {
    if (!phoneNumber) {
      setError('Please enter your phone number');
      return;
    }

    // Format phone number - ensure it has country code
    let formattedPhone = phoneNumber.trim();
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = `+1${formattedPhone}`; // Default to US
    }

    const { error } = await signInWithPhone(formattedPhone);
    
    if (error) {
      setError(error.message);
    } else {
      // Navigate to OTP verification
      navigation.navigate('OtpVerification', { phone: formattedPhone });
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
            Enter your phone number
          </H3>
          <Text
            textAlign="center"
            color="$gray9"
            maxWidth={300}
          >
            We'll send you a verification code via SMS.
          </Text>
        </YStack>

        <YStack space="$4" width="100%" maxWidth={350}>
          <Input
            placeholder="Phone number (with country code)"
            defaultValue="+1"
            value={phoneNumber}
            onChangeText={setPhoneNumber}
            keyboardType="phone-pad"
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
            onPress={handleContinue}
            disabled={isLoading || !phoneNumber}
          >
            {isLoading ? <Spinner color={colors.onPrimary} /> : 'Continue'}
          </Button>

          <XStack alignItems="center" justifyContent="center" marginVertical="$2">
            <Text color="$gray9" textAlign="center" fontSize="$2">
              By continuing, you'll receive an SMS for verification.
            </Text>
          </XStack>
        </YStack>
      </YStack>
    </KeyboardAvoidingView>
  );
} 