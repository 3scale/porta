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
    '<rootDir>/spec/javascripts/setupTests.js',
    '<rootDir>/spec/javascripts/__mocks__/global-mocks.js'
  ],
  snapshotSerializers: [
    'enzyme-to-json/serializer'
  ],
  moduleDirectories: [
    'node_modules',
    'app/javascript/src',
    'app/javascript/packs'
  ],
  transform: {
    '^.+\\.jsx?$': './node_modules/babel-jest',
    // Png and svg imports fails in jest, workaround found in:
    // https://github.com/facebook/jest/issues/2663#issuecomment-369040789
    '.+\\.(png|svg)$': 'jest-transform-stub'
  },
  modulePathIgnorePatterns: [
    '__snapshots__'
  ],
  testURL: 'http://localhost',
  testRegex: ['.*.spec.js', '.*.spec.jsx'],
  verbose: true
}
