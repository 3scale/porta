const { environment } = require('@rails/webpacker')
const path = require('path')

// Add global webpack configs here

environment.loaders.delete('css')
environment.loaders.delete('moduleCss')
environment.loaders.delete('sass')
environment.loaders.delete('moduleSass')

environment.loaders.append('ts', {
  test: /.(ts|tsx)$/,
  include: path.resolve(__dirname, '../../app/javascript'),
  loader: 'ts-loader'
})

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

environment.loaders.append('yaml', {
  test: /\.ya?ml$/,
  use: 'yaml-loader',
  include: path.resolve(__dirname, '../../app/javascript'),
  type: 'json'
})

module.exports = environment
