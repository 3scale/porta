// @flow

// TODO: remove this workaround, necessary for module.hot to work
declare var module: {
  hot: {
    accept(path: string, callback: () => void): void
  }
}

// TODO: remove these module declarations when not failing
declare module 'whatwg-fetch' {
  declare module.exports: fetch
}

declare module 'core-js/fn/symbol' {

}

export type Window = any
