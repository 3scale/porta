module.exports = {
  roots: ['<rootDir>/spec/javascripts'],
  moduleNameMapper: {
    'c3': '<rootDir>/__mocks__/c3.js',
    '\\.(css|less|sass|scss)$': '<rootDir>/spec/javascripts/__mocks__/styleMock.js',
    '\\.(gif|ttf|eot)$': '<rootDir>/spec/javascripts/__mocks__/fileMock.js'
  },
  moduleFileExtensions: [
    'jsx',
    'js'
  ],
  setupFiles: [
    '<rootDir>/spec/javascripts/__mocks__/global-mocks.js'
  ],
  moduleDirectories: [
    'node_modules',
    'app/javascript/src'
  ],
  transform: {
    '^.+\\.jsx?$': './node_modules/babel-jest',
    // Png and svg imports fails in jest, workaround found in:
    // https://github.com/facebook/jest/issues/2663#issuecomment-369040789
    '.+\\.(png|svg)$': 'jest-transform-stub'
  },
  testURL: 'http://localhost',
  testRegex: '.*.spec.jsx',
  verbose: true
}
