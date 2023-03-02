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

// HACK: this removes transpilation errors in tests during development. tsconfig includes them so
// that VS Code can work with imports. Ideally we should have a specific config for VS Code but
// the plugin automatically picks `tsconfig.json` and doesn't support a custom filename.
const tsLoader = environment.loaders.get('ts')
tsLoader.options.reportFiles = [/!(spec\/javascripts)/]

module.exports = environment.toWebpackConfig()
