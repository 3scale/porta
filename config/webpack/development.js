const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

const eslintRule = {
  test: /\.tsx?$/,
  exclude: /(node_modules)/,
  enforce: 'pre',
  loader: 'eslint-loader',
  options: {
    eslintPath: 'eslint',
    configFile: '.eslintrc'
  }
}

module.exports = {
  module: {
    rules: [eslintRule]
  },
  plugins: [
    new BundleAnalyzerPlugin()
  ],
}
