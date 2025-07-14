const { EsbuildPlugin } = require('esbuild-loader');
const CompressionPlugin = require('compression-webpack-plugin');

const baseConfig = require('./base');
const getPlugins = require('./plugins');
const { esbuildTarget } = require('./config');

module.exports = (_, _argv) => {
  const webpackConfig = baseConfig();

  webpackConfig.mode = 'production';

  webpackConfig.bail = true;
  webpackConfig.devtool = 'source-map';

  webpackConfig.optimization.minimizer = [
    new EsbuildPlugin({
      target: esbuildTarget,
      css: true,
    }),
  ];

  webpackConfig.plugins = [
    ...getPlugins(true),
    new CompressionPlugin({
      filename: '[path][base].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/,
    }),
  ];

  return webpackConfig;
};
