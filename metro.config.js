const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const config = getDefaultConfig(__dirname);

// 1. Watch all files in the project directory
config.watchFolders = [path.resolve(__dirname)];

// 2. Enable CSS and custom modules support needed by Tamagui
config.resolver.sourceExts = ['jsx', 'js', 'ts', 'tsx', 'json', 'cjs', 'mjs', 'css'];
config.resolver.assetExts = ['png', 'jpg', 'jpeg', 'gif', 'svg', 'ttf', 'otf'];

// 3. Add resolution for @babel/runtime package with more specific path
config.resolver.extraNodeModules = {
  '@babel/runtime': path.resolve(__dirname, 'node_modules/@babel/runtime'),
};

// 4. Add resolution for Tamagui modules
config.resolver.nodeModulesPaths = [
  path.resolve(__dirname, 'node_modules'),
];

// 5. Enable symlinks for better Tamagui workspace support
config.resolver.resolveRequest = (context, moduleName, platform) => {
  // Logic for custom module resolution
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config; 