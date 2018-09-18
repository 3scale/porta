/* global module */
module.exports = function (config) {
  'use strict'

  config.set({
    autoWatch: true,
    singleRun: true,

    frameworks: ['jspm', 'fixture', 'jasmine'],

    files: [
      'node_modules/babel-polyfill/dist/polyfill.js',
      'spec/support/jasmine.js',
      'spec/support/fixtures.js',
      'spec/support/jquery.js',
      'spec/support/jasmine-jquery.js',
    ],

    jspm: {
      stripExtension: false,
      browserConfig: 'assets/jspm.browser.js',
      jspmConfig: 'assets/jspm.config.js',
      files: [
        'assets/**/*.es6',
        { pattern: 'spec/javascripts/**/*.spec.js', included: true }
      ]
    },

    browserNoActivityTimeout: 60000,

    proxies: {
      '/assets/': '/base/assets/',
      '/assets/spec/': '/base/spec/',
      '/jspm_packages/': '/assets/jspm_packages/'
    },

    browsers: ['Chrome'],

    reporters: ['progress'],

    junitReporter: {
      outputDir: 'tmp/junit/karma'
    }

  })
}
