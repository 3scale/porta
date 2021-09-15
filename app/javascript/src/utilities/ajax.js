// @flow

export type Method = 'GET' | 'POST' | 'DELETE'

type FetchFunction = (url: string, method: Method, body?: URLSearchParams) => Promise<Response>

const _ajax = (headers: Object) => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token = (meta && meta.getAttribute('content')) || ''

  return function (url, method, body?) {
    return fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-CSRF-Token': token
      },
      body
    })
  }
}

const ajax: FetchFunction = _ajax({ 'ContentType': 'application/x-www-form-urlencoded; charset=UTF-8' })
const ajaxJSON: FetchFunction = _ajax({ 'Content-Type': 'application/json; charset=UTF-8' })

export { ajax, ajaxJSON }
