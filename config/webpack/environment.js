const { environment } = require('@rails/webpacker')
const path = require('path')

// Add global webpack configs here

// It seems webpacker handles stylesheets in a less performant way, so we override the loaders
environment.loaders.delete('css')
environment.loaders.delete('sass')
environment.loaders.append('css', {
  test: /(\.css)$/,
  use: [
    { loader: 'style-loader' },
    { loader: 'css-loader' }
  ]
})
environment.loaders.append('sass', {
  test: /(\.scss|\.sass)$/,
  use: [
    { loader: 'style-loader' },
    { loader: 'css-loader' },
    { loader: 'sass-loader' }
  ]
})

// We don't use css modules so these can go
environment.loaders.delete('moduleCss')
environment.loaders.delete('moduleSass')

// We use tsc for both typescript compilation and type checking and let babel handle React.
environment.loaders.append('ts', {
  test: /\.(ts|tsx)$/,
  include: path.resolve(__dirname, '../../app/javascript'),
  options: {},
  loader: 'ts-loader'
})

// Remove styles added automatically by @patternfly/react because it messes up our own styles.
// We import the necessary styles manually in our .scss files and that way it works.
environment.loaders.append('null', {
  test: /\.css$/,
  include: stylesheet => stylesheet.indexOf('@patternfly/react-styles/css/') > -1,
  use: ['null-loader']
})

// Quickstarts' guides are written in YAML for convenience (QuickStarts/templates), then this loader
// allow us to import them as JSON and pass them to the React component (QuickStartContainer).
environment.loaders.append('yaml', {
  test: /\.ya?ml$/,
  use: 'yaml-loader',
  include: path.resolve(__dirname, '../../app/javascript/src/QuickStarts/templates'),
  type: 'json'
})

/* The CDN url must be hardcoded at settings.yml:asset_host during assets compilation in order to get static assets
 * like CSS files point to the CDN. Otherwise, the assets are generated with relative paths and are not loaded from
 * the CDN, even when settings.yml:asset_host is set during runtime. We don't want to have to provide any CDN url when
 * building porta container images in order to get the assets correctly precompiled. To avoid that, this trick assumes
 * the assets are generated with relative paths (settings.yml:asset_host = null during compilation time). The next code
 * is executed by webpack when compiling the assets, and sets the variable `postTransformPublicPath` to an arrow
 * function which will prepend the CDN url in runtime.
 *
 * https://github.com/3scale/porta/pull/3072
 */
const { output } = environment.config;
const oldPublicPath = output.publicPath
output.publicPath = '';

const fileLoader = environment.loaders.get('file');
Object.assign(fileLoader.use[0].options, {
  publicPath: oldPublicPath,
  postTransformPublicPath: (p) => `window.rails_asset_host + ${p}`
});

environment.config.merge({
  optimization: {
    splitChunks: {
      chunks: 'all',
    }
  }
})

module.exports = environment
