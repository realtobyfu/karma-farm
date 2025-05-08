module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      // React Native Reanimated plugin should be last
      'react-native-reanimated/plugin',
      [
        '@babel/plugin-transform-runtime',
        {
          helpers: true,
          regenerator: true,
        },
      ],
      [
        '@tamagui/babel-plugin',
        {
          components: ['tamagui'],
          config: './tamagui.config.ts',
          logTimings: true,
          disableExtraction: process.env.NODE_ENV === 'development',
        },
      ],
      [
        'transform-inline-environment-variables',
        {
          include: 'TAMAGUI_TARGET',
        },
      ],
      [
        'module-resolver',
        {
          root: ['./'],
          alias: {
            '@': './',
            '@app': './app',
            '@components': './app/components',
            '@screens': './app/screens',
            '@lib': './lib',
            '@store': './app/store',
            '@hooks': './app/hooks',
            '@utils': './app/utils',
            '@assets': './assets',
          },
        },
      ],
    ],
  };
}; 