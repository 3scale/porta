// @flow

export type Method = 'GET' | 'POST' | 'DELETE'

type FetchFunction = (url: string, method: Method, body?: URLSearchParams) => Promise<Response>

const { signal, abort }: AbortController = new AbortController()

const _ajax = (headers: { [key: string]: string }) => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token = (meta && meta.getAttribute('content')) || ''

  return function (url, method, body?) {
    return fetch(url, {
      signal,
      method: method,
      headers: { ...headers, 'X-CSRF-Token': token },
      body
    })
  }
}

const ajax: FetchFunction = _ajax({ 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' })
const ajaxJSON: FetchFunction = _ajax({ 'Content-Type': 'application/json; charset=UTF-8' })

export { ajax, ajaxJSON, abort as ajaxAbort }
