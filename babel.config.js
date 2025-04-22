module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
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