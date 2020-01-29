const TerserPlugin = require('terser-webpack-plugin')
const environment = require('./environment')

// Add Webpack custom configs here
environment.config.merge({
  optimization: {
    minimizer: [
      new TerserPlugin({
        parallel: 4
      })
    ]
  }
})

module.exports = environment.toWebpackConfig()
