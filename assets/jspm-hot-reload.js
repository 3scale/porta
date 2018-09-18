System.trace = true
System.import('systemjs-hot-reloader').then(function (HotReloader) {
  return new HotReloader.default('/') // eslint-disable-line new-cap
})
