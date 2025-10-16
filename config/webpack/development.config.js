const path = require('path');

const { devServerPort, publicRootPath, publicOutputPath, devServerManifestPublicPath } = require('./config');
const baseConfig = require('./base');
const getPlugins = require('./plugins');

module.exports = (_, _argv) => {
  const webpackConfig = baseConfig();

  webpackConfig.mode = 'development';

  webpackConfig.devtool = 'cheap-module-source-map';

  webpackConfig.devServer = {
    host: 'localhost',
    port: devServerPort,
    hot: false,
    client: {
      overlay: false,
    },
    compress: true,
    allowedHosts: 'all',
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
    static: {
      publicPath: path.resolve(process.cwd(), `${publicRootPath}/${publicOutputPath}`),
      watch: {
        ignored: '**/node_modules/**',
      },
    },
    devMiddleware: {
      publicPath: `/${publicOutputPath}/`,
    },
    liveReload: true,
    historyApiFallback: {
      disableDotRule: true,
    },
  };

  /**
   * These 2 are production defaults but we need to include it for development, reason:
   * https://github.com/webpack/webpack/discussions/18808
   */
  webpackConfig.optimization.usedExports = true;
  webpackConfig.optimization.innerGraph = true;
  /** */

  webpackConfig.output.publicPath = devServerManifestPublicPath;

  webpackConfig.plugins = getPlugins(false);

  return webpackConfig;
};
