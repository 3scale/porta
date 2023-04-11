process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const ForkTsCheckerWebpackPlugin = require("fork-ts-checker-webpack-plugin")
const path = require('path')

// The default installation (by webpacker) only transpiles TS code using Babel. This enables type
// checking as part of the Webpack compilation process (i.e. fail the build if there are TS errors).
environment.plugins.append(
  "ForkTsCheckerWebpackPlugin",
  new ForkTsCheckerWebpackPlugin({
    typescript: {
      configFile: path.resolve(__dirname, "../../tsconfig.prod.json"),
    },
    async: false,
  })
)

module.exports = environment.toWebpackConfig()
