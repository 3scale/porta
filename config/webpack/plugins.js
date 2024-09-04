const { devServerManifestPublicPath } = require('./config');
const WebpackAssetsManifest = require('webpack-assets-manifest');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = (isProduction) => {
  const plugins = [
    new WebpackAssetsManifest({
      output: 'manifest.json',
      writeToDisk: true,
      publicPath: isProduction ? true : devServerManifestPublicPath,
      entrypoints: true,
      entrypointsUseAssets: false,
      contextRelativeKeys: true,
    }),
    new MiniCssExtractPlugin({
      filename: 'css/[name]-[contenthash].css',
      ignoreOrder: true,
      chunkFilename: 'css/[name]-[contenthash].chunk.css',
    }),
  ];

  return plugins;
};
