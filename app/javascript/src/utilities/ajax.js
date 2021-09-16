// @flow

export type Method = 'GET' | 'POST' | 'DELETE'

type FetchOptions = { method: Method, body?: URLSearchParams, signal?: AbortSignal }
type FetchFunction = (url: string, opts: FetchOptions) => Promise<Response>

const _ajax = (headers: { [key: string]: string }) => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token = (meta && meta.getAttribute('content')) || ''

  return function (url, { method, body, signal }) {
    return fetch(url, {
      method: method,
      headers: { ...headers, 'X-CSRF-Token': token },
      body,
      signal
    })
  }
}

const ajax: FetchFunction = _ajax({ 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' })
const ajaxJSON: FetchFunction = _ajax({ 'Content-Type': 'application/json; charset=UTF-8' })

export { ajax, ajaxJSON }
