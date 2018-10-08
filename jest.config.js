module.exports = {
  roots: ['<rootDir>/spec/javascripts'],
  moduleNameMapper: {
    '\\.(css|less|sass|scss)$': '<rootDir>/spec/javascripts/__mocks__/styleMock.js',
    '\\.(gif|ttf|eot|svg)$': '<rootDir>/spec/javascripts/__mocks__/fileMock.js'
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
  testRegex: '.*.spec.jsx',
  verbose: true
}
