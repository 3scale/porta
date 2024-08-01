const path = require("path");
const {
  devServerPort,
  publicRootPath,
  publicOutputPath,
  devServerManifestPublicPath
} = require("./config");

module.exports = (webpackConfig) => {
  webpackConfig.devtool = "cheap-module-source-map";

  webpackConfig.stats = {
    colors: true,
    entrypoints: false,
    errorDetails: true,
    modules: false,
    moduleTrace: false
  };

  webpackConfig.devServer = {
    https: false,
    host: 'localhost',
    port: devServerPort,
    hot: false,
    client: {
      overlay: false,
    },
    compress: true,
    allowedHosts: "all",
    headers: {
      "Access-Control-Allow-Origin": "*"
    },
    static: {
      publicPath: path.resolve(process.cwd(), `${publicRootPath}/${publicOutputPath}`),
      watch: {
        ignored: "**/node_modules/**"
      }
    },
    devMiddleware: {
      publicPath: `/${publicOutputPath}/`
    },
    liveReload: true,
    historyApiFallback: {
      disableDotRule: true
    }
  };

  webpackConfig.output.publicPath = devServerManifestPublicPath;

  return webpackConfig;
};
