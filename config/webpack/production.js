const environment = require('./environment')
const path = require('path')

// Add Webpack custom configs here

const tsLoader = environment.loaders.get('ts')
tsLoader.options.configFile = path.resolve(__dirname, '../../tsconfig.prod.json')

module.exports = environment.toWebpackConfig()
