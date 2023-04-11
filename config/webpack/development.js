process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin
const environment = require('./environment')
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin")
const path = require('path')

// The default installation (by webpacker) only transpiles TS code using Babel. This enables type
// checking as part of the Webpack compilation process (i.e. fail the build if there are TS errors).
environment.plugins.append(
  "ForkTsCheckerWebpackPlugin",
  new ForkTsCheckerWebpackPlugin({
    eslint: {
      files: [
        './app/javascript/**/*.{ts,tsx}',
        './spec/javascripts/**/*.{ts,tsx}'
      ]
    },
    typescript: {
      configFile: path.resolve(__dirname, "../../tsconfig.json"),
      // TODO: this options is introduces in v8.0.0, it doesn't work yet.
      // Ignore transpilation errors in specs during development. tsconfig includes them so
      // that VS Code can work with imports. Ideally we should have a specific config for VS Code
      // but the extension doesn't support custom config files.
      reportFiles: ['app/javascript/**/*.{ts,tsx}'],
    },
    async: false,
  })
)

environment.plugins.append('BundleAnalyzerPlugin',
  new BundleAnalyzerPlugin()
)

module.exports = environment.toWebpackConfig()
