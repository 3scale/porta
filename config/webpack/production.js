const { EsbuildPlugin } = require('esbuild-loader');
const CompressionPlugin = require('compression-webpack-plugin');
const { esbuildTarget } = require('./config')

module.exports = (webpackConfig) => {
  webpackConfig.devtool = 'source-map';
  webpackConfig.stats = 'normal';
  webpackConfig.bail = true;

  webpackConfig.plugins.push(
    new CompressionPlugin({
      filename: '[path][base].gz[query]',
      algorithm: 'gzip',
      test: /\.(js|css|html|json|ico|svg|eot|otf|ttf|map)$/
    })
  );

  const prodOptimization = {
    minimize: true,
    minimizer: [
      new EsbuildPlugin({
        target: esbuildTarget,
        css: true
      })
    ]
  };

  Object.assign(webpackConfig.optimization, prodOptimization);

  return webpackConfig;
};
