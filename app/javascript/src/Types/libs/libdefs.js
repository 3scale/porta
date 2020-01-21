// @flow

// Disabling all weak-type checks since this file is a workaround for missing types
/* eslint-disable flowtype/no-weak-types */

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

declare module 'swagger-ui-react' {
  declare module.exports: any;
}

export type Window = any
