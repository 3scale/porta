const { devServerManifestPublicPath } = require("./config");
const WebpackAssetsManifest = require('webpack-assets-manifest');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const RemoveEmptyScriptsPlugin = require('webpack-remove-empty-scripts');

module.exports = (isProduction) => {
  const hash = isProduction ? '-[contenthash:8]' : '';

  const plugins = [
    new WebpackAssetsManifest({
      output: "manifest.json",
      writeToDisk: true,
      publicPath: isProduction ? true : devServerManifestPublicPath,
      entrypoints: true,
      entrypointsUseAssets: false,
      contextRelativeKeys: true
    }),
    new RemoveEmptyScriptsPlugin(),
    new MiniCssExtractPlugin({
      filename: `css/[name]${hash}.css`,
      ignoreOrder: false,
      chunkFilename: `css/[name]${hash}.chunk.css`
    })
  ];

  return plugins;
};
