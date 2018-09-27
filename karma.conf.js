/* global module */
var webpackConfig = require('./config/webpack/test.js')
module.exports = function (config) {
  'use strict'

  config.set({
    basePath: "",
    autoWatch: true,
    singleRun: true,

    frameworks: ['jquery-3.2.1', 'jasmine-jquery', 'jasmine', 'fixture'],

    preprocessors: {
      'spec/javascripts/karma/index.spec.js': [ 'webpack' ]
    },

    files: [
      'spec/javascripts/karma/jasmine.js',
      'spec/javascripts/karma/fixtures.js',
      'spec/javascripts/karma/index.spec.js'
      //{ pattern: 'app/javascript/src/**/*.jsx', watched: false }

    ],

    webpack: webpackConfig,

    webpackMiddleware: {
    },

    plugins: [
      'karma-jasmine',
      'karma-jasmine-jquery',
      'karma-jquery',
      'karma-fixture',
      'karma-webpack',
      'karma-chrome-launcher',
      'karma-firefox-launcher',
      'karma-junit-reporter'
    ],

    browserNoActivityTimeout: 60000,

    browsers: ['Chrome'],

    reporters: ['progress'],

    junitReporter: {
      outputDir: 'tmp/junit/karma'
    }

  })
}
