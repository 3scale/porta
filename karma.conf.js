const { resolve } = require('path')
var webpackConfig = require('./config/webpack/test.js')

module.exports = function (config) {
  'use strict'

  config.set({
    basePath: '',
    autoWatch: true,
    singleRun: true,

    frameworks: ['jquery-3.2.1', 'jasmine-jquery', 'jasmine', 'fixture'],

    preprocessors: {
      'spec/javascripts/karma/index.spec.js': ['webpack']
    },

    files: [
      'spec/javascripts/karma/jasmine.js',
      'spec/javascripts/karma/fixtures.js',
      'spec/javascripts/karma/index.spec.js'
    ],

    webpack: {
      mode: 'production',
      output: {
        path: resolve(__dirname, 'public/packs-test')
      },
      devtool: webpackConfig.devtool,
      module: webpackConfig.module,
      resolve: webpackConfig.resolve
    },

    webpackMiddleware: {
      quiet: true,
      stats: {
        colors: true
      }
    },

    plugins: [
      'karma-jasmine',
      '@metahub/karma-jasmine-jquery',
      'karma-jquery',
      'karma-fixture',
      'karma-webpack',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-junit-reporter'
    ],

    browserNoActivityTimeout: 60000,

    browsers: ['ChromeHeadless', 'FirefoxHeadless'],

    reporters: ['progress'],

    junitReporter: {
      outputDir: 'tmp/junit/karma'
    }

  })
}
