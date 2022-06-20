const { webpackConfig, merge } = require('shakapacker')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

// HACK: by default, shakapacker uses mini-css-extract-plugin with sass files but it prevents our styles from working. Next line replaces this loader with style-loader. If simply merged, both loaders will be used and webpack won't even compile.
webpackConfig.module.rules[3].use[0] = 'style-loader'

const customConfig = {
  module: {
    rules: [
      {
        test: /\.ya?ml$/,
        use: 'yaml-loader',
        type: 'json'
      }
    ]
  },
  resolve: {
    extensions: ['.scss']
  }
}

const newWebpackConfig = merge({}, webpackConfig, customConfig)

module.exports = newWebpackConfig
