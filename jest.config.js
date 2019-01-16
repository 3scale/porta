module.exports = {
  roots: ['<rootDir>/spec/javascripts'],
  moduleNameMapper: {
    'c3': '<rootDir>/__mocks__/c3.js',
    '\\.(css|less|sass|scss)$': '<rootDir>/spec/javascripts/__mocks__/styleMock.js',
    '\\.(gif|ttf|eot|svg)$': '<rootDir>/spec/javascripts/__mocks__/fileMock.js'
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
    '^.+\\.jsx?$': './node_modules/babel-jest'
  },
  testURL: 'http://localhost',
  testRegex: '.*.spec.jsx',
  verbose: true
}
