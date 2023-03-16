const { webpackConfig, merge, env } = require('shakapacker')
const { resolve } = require('path')

// See the shakacode/shakapacker README and docs directory for advice on customizing your webpackConfig.

webpackConfig.module.rules = webpackConfig.module.rules.filter(rule => {
  return !rule.test.test('.css') && !rule.test.test('.scss')
})

// const cssRule = webpackConfig.module.rules.find(rule => rule.test.test('.css'))
// const scssRule = webpackConfig.module.rules.find(rule => rule.test.test('.scss'))

// cssRule.include = [
//   resolve(__dirname, '../../app/javascript'),
//   resolve(__dirname, '../../node_modules/swagger-ui'),
//   resolve(__dirname, '../../node_modules/@patternfly')
// ]
// scssRule.include = resolve(__dirname, '../../app/javascript') // TODO: is this correct?


// // FIXME: mini-css-extract-plugin breaks compilation. Make it work.
// // FIXME: postcss-loader also breaks compilation. Make it work
// function filterOutLoaders (rule, ...loaders) {
//   return rule.use.filter(use => !loaders.some(loader => {
//     return typeof use === 'object' ? use.loader.includes(loader) : use.includes(loader)
//   }))
// }

// cssRule.use = filterOutLoaders(cssRule, 'mini-css-extract-plugin', 'postcss-loader')
// scssRule.use = filterOutLoaders(scssRule, 'mini-css-extract-plugin', 'postcss-loader')

const customConfig = {
  module: {
    rules: [
      {
        test: /\.(ts|tsx)$/,
        options: {},
        loader: 'ts-loader'
      },
      {
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
        ],
        include: [
          resolve(__dirname, '../../app/javascript'),
          resolve(__dirname, '../../node_modules/swagger-ui'),
          resolve(__dirname, '../../node_modules/@patternfly')
        ]
      },
      {
        test: /\.ya?ml$/,
        use: 'yaml-loader',
        include: [
          resolve(__dirname, '../../app/javascript/src/QuickStarts/templates')
        ],
        type: 'json'
      }
    ]
  },
  resolve: {
    extensions: [
      '.ts',
      '.tsx',
      '.css',
      '.scss',
      '.yml'
    ],
    fallback: {
      stream: false // Polyfill used by @patternfly/quickstarts
    }
  }
}

let mergedConfig = merge(webpackConfig, customConfig)

if (env.nodeEnv === 'development') {
  // HACK: ignore compilation errors in tests
  const tsLoader = mergedConfig.module.rules.find(rule => rule.loader === 'ts-loader');
  tsLoader.options.reportFiles = [/!(spec\/javascripts)/]

  const developmentConfig = {
    module: {
      rules: [
        {
          test: /\.(ts|tsx)$/,
          enforce: 'pre',
          loader: 'eslint-loader',
          options: {
            eslintPath: 'eslint',
            configFile: '.eslintrc'
          }
        }
      ]
    },
    devServer: {
      client: {
        overlay: { errors: true, warnings: false },
      },
    },
  }

  mergedConfig = merge(mergedConfig, developmentConfig)
}

console.log(mergedConfig.module.rules)

module.exports = mergedConfig
