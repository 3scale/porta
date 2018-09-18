module.exports = {
  // automock: false,
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
