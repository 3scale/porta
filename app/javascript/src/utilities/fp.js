const switchCase = cases => defaultCase => key =>
  cases.hasOwnProperty(key) ? cases[key] : defaultCase

const filterKeys = (source) => (allowed) => Object.keys(source)
  .filter(key => allowed.includes(key))
  .reduce((obj, key) => {
    obj[key] = source[key]
    return obj
  }, {})
export {
  switchCase,
  filterKeys
}
