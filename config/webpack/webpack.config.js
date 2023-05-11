const { webpackConfig: baseWebpackConfig, merge, env } = require('shakapacker')
const { resolve } = require('path')
const { existsSync } = require('fs')

/**
 * We use tsc for both typescript compilation and type checking and let babel handle React.
 */
const tsRule = {
  test: /\.(ts|tsx)$/,
  include: resolve(__dirname, '../../app/javascript'),
  options: {
    configFile: resolve(__dirname, env.isDevelopment ? '../../tsconfig.json' : '../../tsconfig.prod.json'),
    // HACK: this removes transpilation errors in tests during development. tsconfig includes them so
    // that VS Code can work with imports. Ideally we should have a specific config for VS Code but
    // the plugin automatically picks `tsconfig.json` and doesn't support a custom filename.
    reportFiles: env.isDevelopment ? [/!(spec\/javascripts)/] : undefined
  },
  loader: 'ts-loader'
}

/**
 * Remove styles added automatically by @patternfly/react because it messes up our own styles.
 * We import the necessary styles manually in our .scss files and that way it works.
 */
const nullRule = {
  test: /\.css$/,
  include: stylesheet => stylesheet.indexOf('@patternfly/react-styles/css/') > -1,
  use: ['null-loader']
}

/**
 * Quickstarts' guides are written in YAML for convenience (QuickStarts/templates), then this loader
 * allow us to import them as JSON and pass them to the React component (QuickStartContainer).
 */
const yamlRule = {
  test: /\.ya?ml$/,
  use: 'yaml-loader',
  include: resolve(__dirname, '../../app/javascript/src/QuickStarts/templates'),
  type: 'json'
}

const customConfig = {
  module: {
    rules: [yamlRule, nullRule, tsRule]
  },
  // TODO: maybe this is required by quickstarts, when we make it work
  // resolve: {
  //   fallback: {
  //     stream: false // Polyfill used by @patternfly/quickstarts
  //   }
  // }
}

const envSpecificConfig = () => {
  const path = resolve(__dirname, `${env.nodeEnv}.js`)
  if (existsSync(path)) {
    console.log(`Loading ENV specific webpack configuration file ${path}`)
    return require(path)
  } else {
    // Probably an error if the file for the NODE_ENV does not exist
    throw new Error(`Got Error with NODE_ENV = ${env.nodeEnv}`);
  }
}

module.exports = merge(baseWebpackConfig, customConfig, envSpecificConfig())
