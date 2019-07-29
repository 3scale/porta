const { environment } = require('@rails/webpacker')

// Add global webpack configs here

const babelLoader = environment.loaders.get('babel')
babelLoader.test = /\.jsx?|.spec.js?$/

environment.loaders.delete('css')
environment.loaders.delete('moduleCss')
environment.loaders.delete('sass')
environment.loaders.delete('moduleSass')

environment.loaders.append('null', {
  test: /\.css$/,
  include: stylesheet => stylesheet.indexOf('@patternfly/react-styles/css/') > -1,
  use: ['null-loader']
})

environment.loaders.append('style', {
  test: /(\.css|\.scss|\.sass)$/,
  use: [
    { loader: 'style-loader' },
    { loader: 'css-loader' },
    {
      loader: 'sass-loader',
      options: {
        modules: true,
        localIdentName: '[name]---[local]---[hash:base64:5]'
      }
    }
  ]
})

module.exports = environment
