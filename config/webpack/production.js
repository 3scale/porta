const TerserPlugin = require('terser-webpack-plugin')
const environment = require('./environment')
const path = require('path')

// Add Webpack custom configs here
environment.config.merge({
  optimization: {
    minimizer: [
      new TerserPlugin({
        parallel: 4
      })
    ]
  },
  output: {
    pathinfo: false
  },
  devtool: 'cheap-module-eval-source-map'
})

const tsLoader = environment.loaders.get('ts')
tsLoader.options.configFile = path.resolve(__dirname, '../../tsconfig.prod.json')

module.exports = environment.toWebpackConfig()
