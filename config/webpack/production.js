const environment = require('./environment')

const customRules = {
  module: {
    rules: [
      {
        test: /\.jsx?|.es6?|.spec.js?$/,
        exclude: /(node_modules)/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: ['es2015', 'react'],
              plugins: ['transform-object-rest-spread', 'transform-class-properties', 'transform-es2015-destructuring']
            }
          }
        ]
      },
      {
        test: /(\.css|\.scss|\.sass)$/,
        loader: 'style-loader!css-loader!sass-loader?modules&localIdentName=[name]---[local]---[hash:base64:5]'
      },
      {
        test: /\.(png|jpe?g|gif|svg|woff|woff2|ttf|eot|ico)$/,
        loader: 'file-loader?name=assets/[name].[hash].[ext]'
      }
    ]
  }
}

module.exports = Object.assign({}, environment, customRules)
