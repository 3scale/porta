module.exports = {
  // automock: false,
  moduleNameMapper: {
    "\\.(css|less|sass|scss)$": "<rootDir>/__mocks__/styleMock.js",
    "\\.(gif|ttf|eot|svg)$": "<rootDir>/__mocks__/fileMock.js"
  },
  moduleFileExtensions: [
    "jsx",
    "js"
  ],
  moduleDirectories: [
    "node_modules"
  ],
  transform: {
    "^.+\\.jsx?$": "./node_modules/babel-jest"
  },
  testRegex: ".*.spec.js",
  verbose: true
}
