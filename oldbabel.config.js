// {
//   "plugins": [
//     "@babel/plugin-syntax-dynamic-import",
//     "@babel/plugin-transform-runtime",
//     "@babel/plugin-proposal-class-properties",
//     "@babel/plugin-transform-template-literals",
//     "@babel/plugin-proposal-object-rest-spread",
//     "@babel/plugin-transform-destructuring"
//   ],
//   "presets": [
//     [
//       "@babel/preset-env",
//       {
//         "useBuiltIns": "entry",
//         "corejs": "2",
//         "targets": {
//           "node": "current",
//           "ie": "11",
//           "firefox": "67",
//           "chrome": "75",
//           "edge": "44"
//         }
//       }
//     ],
//     "@babel/react",
//     "@babel/flow"
//   ]
// }

// babel.config.js
module.exports = function (api) {
  const defaultConfigFunc = require('shakapacker/package/babel/preset.js')
  const resultConfig = defaultConfigFunc(api)
  const isDevelopmentEnv = api.env('development')
  const isProductionEnv = api.env('production')
  const isTestEnv = api.env('test')

  const changesOnDefault = {
    presets: [
      '@babel/preset-flow',
      [
        '@babel/preset-react',
        {
          development: isDevelopmentEnv || isTestEnv,
          useBuiltIns: true
        }
      ]
    ].filter(Boolean),
    plugins: [
      isProductionEnv && ['babel-plugin-transform-react-remove-prop-types',
        {
          removeImport: true
        }
      ],
      process.env.WEBPACK_SERVE && 'react-refresh/babel'
    ].filter(Boolean)
  }

  resultConfig.presets = [...resultConfig.presets, ...changesOnDefault.presets]
  resultConfig.plugins = [...resultConfig.plugins, ...changesOnDefault.plugins]

  return resultConfig
}
