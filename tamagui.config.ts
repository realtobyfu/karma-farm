/* eslint-disable */
// @ts-nocheck
import { createTamagui } from 'tamagui';
import { createInterFont } from '@tamagui/font-inter';
import { shorthands } from '@tamagui/shorthands';
import { themes, tokens } from '@tamagui/theme-base';

// Define colors
export const colors = {
  primary: '#65D3AA',
  onPrimary: '#FFFFFF',
  surface: '#F1F5F4',
  text: '#293642',
  warning: '#FFBC42',
  error: '#E74C3C',
  background: '#FFFFFF',
  card: '#F9FBFA',
  border: '#E0E5E4',
  notification: '#FF4D4F',
  placeholder: '#9CA3AF',
};

// Define fonts
const headingFont = createInterFont({
  size: {
    1: 12,
    2: 14,
    3: 16,
    4: 18,
    5: 20,
    6: 24,
    7: 28,
    8: 32,
    9: 36,
    10: 40,
    11: 48,
    12: 56,
    13: 64,
    14: 72,
  },
  weight: {
    1: '300',
    2: '400',
    3: '500',
    4: '600',
    5: '700',
    6: '800',
  },
  letterSpacing: {
    1: 0,
    2: -0.5,
    3: -1,
  },
  face: {
    700: { normal: 'InterBold' },
    500: { normal: 'InterMedium' },
    400: { normal: 'Inter' },
  },
});

const bodyFont = createInterFont(
  {
    face: {
      700: { normal: 'InterBold' },
      500: { normal: 'InterMedium' },
      400: { normal: 'Inter' },
    },
  },
  {
    sizeSize: (size: number) => Math.round(size * 1.1),
    sizeLineHeight: (size: number) => Math.round(size * 1.5),
  }
);

// Create and export the config
const config = createTamagui({
  defaultFont: 'body',
  fonts: {
    heading: headingFont,
    body: bodyFont,
  },
  themes: {
    ...themes,
    light: {
      ...themes.light,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      background: colors.background,
      color: colors.text,
    },
    dark: {
      ...themes.dark,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      background: '#1A1A1A',
      color: '#FFFFFF',
    },
  },
  tokens,
  shorthands,
});

export type AppConfig = typeof config;

declare module 'tamagui' {
  interface TamaguiCustomConfig extends AppConfig {}
}

export default config;
export * from './tamagui.config.js'; 