import 'react-native-url-polyfill/auto';
import React, { useEffect } from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { TamaguiProvider } from 'tamagui';
import { useFonts } from 'expo-font';
import { Platform } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import * as SplashScreen from 'expo-splash-screen';

import config from './tamagui.config';
import AppNavigation from './app/navigation';

// Conditionally import LogBox for native platforms only
if (Platform.OS !== 'web') {
  // Import LogBox and ignore specific warnings
  const { LogBox } = require('react-native');
  LogBox.ignoreLogs([
    'ViewPropTypes will be removed',
    'ColorPropType will be removed',
  ]);
}

// Keep the splash screen visible while we fetch resources
SplashScreen.preventAutoHideAsync();

export default function App() {
  // Load fonts
  const [fontsLoaded, fontError] = useFonts({
    Inter: require('@tamagui/font-inter/otf/Inter-Medium.otf'),
    InterBold: require('@tamagui/font-inter/otf/Inter-Bold.otf'),
    InterMedium: require('@tamagui/font-inter/otf/Inter-Medium.otf'),
  });

  useEffect(() => {
    // Hide splash screen once fonts are loaded or there's an error
    if (fontsLoaded || fontError) {
      SplashScreen.hideAsync();
    }
  }, [fontsLoaded, fontError]);

  // Return a loading screen while fonts load
  if (!fontsLoaded && !fontError) {
    return null;
  }

  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <TamaguiProvider config={config} defaultTheme="light">
        <SafeAreaProvider>
          <AppNavigation />
          <StatusBar style="dark" />
        </SafeAreaProvider>
      </TamaguiProvider>
    </GestureHandlerRootView>
  );
} 