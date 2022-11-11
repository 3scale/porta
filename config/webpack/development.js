const environment = require('./environment')

// Add Webpack custom configs here
environment.loaders.append('eslint', {
  test: /\.tsx?$/,
  exclude: /(node_modules)/,
  enforce: 'pre',
  loader: 'eslint-loader',
  options: {
    eslintPath: 'eslint',
    configFile: '.eslintrc'
  }
})

module.exports = environment.toWebpackConfig()
