// @flow

export type Method = 'GET' | 'POST' | 'DELETE'

const ajax = (url: string, method: Method, body?: URLSearchParams): Promise<Response> => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token = (meta && meta.getAttribute('content')) || ''

  return fetch(url, {
    method: method,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
      'X-CSRF-Token': token
    },
    body
  })
}

const post = (url: string, body?: URLSearchParams): Promise<Response> => {
  return ajax(url, 'POST', body)
}

const ajaxJSON = (url: string, method: Method, body?: URLSearchParams): Promise<Response> => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token = (meta && meta.getAttribute('content')) || ''

  return fetch(url, {
    method: method,
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'X-CSRF-Token': token
    },
    body
  })
}

const getJSON = (url: string): Promise<Response> => {
  return ajaxJSON(url, 'GET')
}

export { ajax, post, getJSON }
