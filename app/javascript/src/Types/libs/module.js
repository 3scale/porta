// @flow

// TODO: remove this workaround, necessary for module.hot to work
declare var module: {
  hot: {
    accept(path: string, callback: () => void): void
  }
}
