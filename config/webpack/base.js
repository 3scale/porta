const { join, resolve } = require('path');
const fs = require('fs');
const {
  additionalPaths,
  publicOutputPath,
  publicRootPath,
  sourceEntryPath,
  sourcePath,
} = require('./config');
const getRules = require('./rules');

const getEntryObject = () => {
  const packsPath = resolve(process.cwd(), join(sourcePath, sourceEntryPath));
  const entryPoints = {};

  fs.readdirSync(packsPath).forEach((packNameWithExtension) => {
    const packName = packNameWithExtension.replace('.js', '').replace('.scss', '');

    if (entryPoints[packName]) {
      entryPoints[packName] = [entryPoints[packName], packsPath + '/' + packNameWithExtension];
    } else {
      entryPoints[packName] = packsPath + '/' + packNameWithExtension;
    };
  });

  return entryPoints;
};

const getModulePaths = () => {
  const result = [resolve(process.cwd(), sourcePath)];

  additionalPaths.forEach((additionalPath) => {
    result.push(resolve(process.cwd(), additionalPath));
  });

  result.push('node_modules');

  return result;
};

const sharedWebpackConfig = () => ({
  mode: 'production',
  entry: getEntryObject(),
  optimization: {
    runtimeChunk: 'single',
    splitChunks: {
      chunks(chunk) {
        return chunk.name !== 'patternfly_base';
      },
    },
  },
  resolve: {
    extensions: [
      '.ts',
      '.tsx',
      '.js',
      '.jsx',
      '.scss',
      '.yaml',
    ],
    modules: getModulePaths(),
  },
  resolveLoader: {
    modules: ['node_modules'],
  },
  module: {
    strictExportPresence: true,
    rules: getRules(),
  },
  output: {
    filename: 'js/[name]-[contenthash].js',
    chunkFilename: 'js/[name]-[contenthash].chunk.js',
    hotUpdateChunkFilename: 'js/[id]-[hash].hot-update.js',
    path: resolve(process.cwd(), `${publicRootPath}/${publicOutputPath}`),
    publicPath: `/${publicOutputPath}/`,
  },
});

module.exports = sharedWebpackConfig;
