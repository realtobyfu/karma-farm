// Updated metro.config.js
const { getDefaultConfig } = require('expo/metro-config');
const path = require('path');

const projectRoot = __dirname;
const config = getDefaultConfig(projectRoot);

// Add additional watch folders
config.watchFolders = [
  path.resolve(projectRoot, 'node_modules'),
];

// Enable CSS and custom modules support needed by Tamagui
config.resolver.sourceExts = ['jsx', 'js', 'ts', 'tsx', 'json', 'cjs', 'mjs', 'css'];
config.resolver.assetExts = ['png', 'jpg', 'jpeg', 'gif', 'svg', 'ttf', 'otf'];

// Fix module resolution for Node built-ins and Tamagui config
config.resolver.extraNodeModules = {
  ...config.resolver.extraNodeModules,
  '@babel/runtime': path.resolve(__dirname, 'node_modules/@babel/runtime'),
  ws: path.resolve(projectRoot, 'emptyModule.js'),
  stream: path.resolve(projectRoot, 'emptyModule.js'),
  http: path.resolve(projectRoot, 'emptyModule.js'),
  https: path.resolve(projectRoot, 'emptyModule.js'),
  crypto: path.resolve(projectRoot, 'emptyModule.js'),
};

// Ensure tamagui.config.ts is properly resolved
config.resolver.resolveRequest = (context, moduleName, platform) => {
  // Handle tamagui config imports
  if (
    moduleName === 'tamagui.config' || 
    moduleName === './tamagui.config' || 
    moduleName === '../tamagui.config' || 
    moduleName === '../../tamagui.config' || 
    moduleName === '../../../tamagui.config'
  ) {
    return {
      filePath: path.resolve(projectRoot, 'tamagui.config.ts'),
      type: 'sourceFile',
    };
  }
  return context.resolveRequest(context, moduleName, platform);
};

module.exports = config;
