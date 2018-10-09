module.exports = {
  // automock: false,
  roots: ['<rootDir>/spec/javascript'],
  moduleNameMapper: {
    '\\.(css|less|sass|scss)$': '<rootDir>/spec/javascript/__mocks__/styleMock.js',
    '\\.(gif|ttf|eot|svg)$': '<rootDir>/spec/javascript/__mocks__/fileMock.js'
  },
  moduleFileExtensions: [
    'jsx',
    'js'
  ],
  moduleDirectories: [
    'node_modules',
    'app/javascript/src'
  ],
  transform: {
    '^.+\\.jsx?$': './node_modules/babel-jest'
  },
  testURL: 'http://localhost',
  testRegex: '.*.spec.js',
  verbose: true
}
