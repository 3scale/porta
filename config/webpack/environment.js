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

environment.loaders.append('yaml', {
  test: /\.ya?ml$/,
  use: 'yaml-loader',
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

module.exports = environment
