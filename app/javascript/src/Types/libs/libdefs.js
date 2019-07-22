// @flow

// TODO: remove this workaround, necessary for module.hot to work
declare var module: {
  hot: {
    accept(path: string, callback: () => void): void
  }
}

// TODO: remove these module declarations when not failing
declare module 'whatwg-fetch' {
  declare type Options = {
    method?: string,
    body?: string,
    headers?: Object,
    credentials?: 'omit' | 'same-origin' | 'include'
  }
  declare type Response = {
    status: number,
    statusText: string,
    ok: boolean,
    headers: any,
    url: string,
    text: () => Promise<string>,
    json: () => Promise<Object>
  }
  declare export function fetch (url: string, options: ?Options): Promise<Response>
}

declare module 'core-js/fn/symbol' {

}

export type Window = any
