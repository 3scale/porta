const { resolve } = require("path");
const {
  esbuildTarget,
  sourcePath,
  additionalPaths
} = require("./config")

// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

const getCssLoader = () => {
  return {
    loader: require.resolve('css-loader'),
    options: {
      sourceMap: true,
      importLoaders: 2
    }
  }
}

module.exports = () => [
  // File
  {
    test: /(.jpg|.jpeg|.png|.gif|.tiff|.ico|.svg|.eot|.otf|.ttf|.woff|.woff2)$/i,
    include: resolve(__dirname, '../../app/javascript'),
    type: 'asset/resource',
    generator: {
      filename: 'static/[hash][ext][query]'
    }
  },
  // CSS
  {
    test: /\.css$/,
    include: [
      /node_modules\/@patternfly/,
      /node_modules\/jquery-ui/,
      /node_modules\/swagger-ui/,
    ],
    use: [
      MiniCssExtractPlugin.loader,
      getCssLoader(),
      {
        loader: require.resolve('esbuild-loader'),
        options: {
          minify: true,
          target: esbuildTarget
        }
      }
    ]
  },
  // SASS
  {
    test: /\.(sass|scss)$/,
    include: resolve(__dirname, '../../app/javascript'),
    use: [
      MiniCssExtractPlugin.loader,
      getCssLoader(),
      {
        loader: require.resolve('sass-loader'),
        options: {
          sassOptions: {
            includePaths: additionalPaths
          }
        }
      }
    ]
  },
  // Esbuild
  {
    test: /\.(js|jsx)$/,
    include: [sourcePath, ...additionalPaths].map((path) => resolve(process.cwd(), path)),
    exclude: [/node_modules/, /app\/javascript\/src\/Stats/],
    use: [
      {
        loader: require.resolve('esbuild-loader'),
        options: { target: "es2016" }
      }
    ]
  },
  // Stats
  {
    test: /\.js$/,
    include: resolve(__dirname, '../../app/javascript/src/Stats'),
    use: [
      {
        loader: require.resolve('esbuild-loader'),
        options: {
          loader: "jsx",
          target: "es2016"
        }
      }
    ]
  },
  // Typescript
  {
    test: /\.(ts|tsx)$/,
    include: resolve(__dirname, '../../app/javascript'),
    use: 'ts-loader'
  },
  // YAML
  {
    test: /\.ya?ml$/,
    include: resolve(__dirname, '../../app/javascript/src/QuickStarts/templates'),
    type: 'json',
    use: [{
      loader: 'yaml-loader',
      options: {
        asJSON: true
      }
    }]
  },
]
