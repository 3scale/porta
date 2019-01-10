const environment = require('./environment')

// Add Webpack custom configs here
environment.loaders.append('eslint', {
  test: /\.jsx?$/,
  exclude: /(node_modules)/,
  enforce: 'pre',
  loader: 'eslint-loader',
  options: {
    configFile: '.eslintrc'
  }
})

module.exports = environment.toWebpackConfig()
