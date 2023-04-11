process.env.NODE_ENV = process.env.NODE_ENV || 'development'

const TerserPlugin = require('terser-webpack-plugin')
const environment = require('./environment')

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

module.exports = environment.toWebpackConfig()
