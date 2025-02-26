const { resolve } = require("path");
const {
  esbuildTarget,
  sourcePath,
  additionalPaths,
} = require("./config");
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const moduleJavascriptPath = resolve(__dirname, '../../app/javascript');
const moduleStatsPath = resolve(__dirname, '../../app/javascript/src/Stats');

module.exports = () => [
  // File
  {
    test: /(.jpg|.jpeg|.png|.gif|.tiff|.ico|.svg|.eot|.otf|.ttf|.woff|.woff2)$/i,
    include: moduleJavascriptPath,
    type: 'asset/resource',
    generator: {
      filename: 'static/[fullhash][ext][query]',
    },
  },
  // CSS
  {
    test: /\.css$/,
    include: [
      /node_modules\/highlight.js\/styles/,
      /node_modules\/@patternfly/,
      /node_modules\/jquery-ui/,
      /node_modules\/swagger-ui/,
    ],
    use: [
      MiniCssExtractPlugin.loader,
      'css-loader',
    ],
  },
  // SASS
  {
    test: /\.(sass|scss)$/,
    include: moduleJavascriptPath,
    use: [
      MiniCssExtractPlugin.loader,
      'css-loader',
      {
        loader: 'sass-loader',
        options: {
          sassOptions: {
            includePaths: additionalPaths,
            silenceDeprecations: [
                'legacy-js-api',
                'import',
                'global-builtin',
                'color-functions',
            ],
          },
        },
      },
    ],
  },
  // Esbuild
  {
    test: /\.(js|jsx|ts|tsx)$/,
    include: [sourcePath, ...additionalPaths].map((path) => resolve(process.cwd(), path)),
    exclude: [/node_modules/, moduleStatsPath],
    use: [
      {
        loader: 'esbuild-loader',
        options: {
          target: esbuildTarget,
        },
      },
    ],
  },
  // Stats
  {
    test: /\.js$/,
    include: moduleStatsPath,
    use: [
      {
        loader: 'esbuild-loader',
        options: {
          loader: "jsx",
          target: esbuildTarget,
        },
      },
    ],
  },
  {
    test: /\.ya?ml$/,
    include: resolve(__dirname, '../../app/javascript/src/QuickStarts/templates'),
    type: 'json',
    use: [{
      loader: 'yaml-loader',
      options: {
        asJSON: true,
      },
    }],
  },
];
