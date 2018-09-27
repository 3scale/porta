const testsContext = require.context('../', true, /^(.+.spec.js)$/)
testsContext.keys().forEach(function(key) {
  testsContext(key)
})
