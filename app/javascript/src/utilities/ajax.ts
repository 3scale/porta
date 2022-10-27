/* eslint-disable @typescript-eslint/naming-convention */
export type Method = 'DELETE' | 'GET' | 'POST'

interface FetchOptions { method: Method; body?: URLSearchParams; signal?: AbortSignal }
type FetchFunction = (url: string, opts: FetchOptions) => Promise<Response>

export interface FetchItemsRequestParams { page: number; perPage: number; query?: string }
export type FetchItemsResponse<T> = Promise<{ items: T[]; count: number }>

const _ajax = (headers: Record<string, string>) => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token: string = meta?.getAttribute('content') ?? ''

  return function (url: string, { method, body, signal }: FetchOptions) {
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

async function fetchPaginated<T> (path: string, params: FetchItemsRequestParams): FetchItemsResponse<T> {
  const { page, perPage, query = '' } = params

  const searchParams = new URLSearchParams({
    page: String(page),
    per_page: String(perPage)
  })

  if (query !== '') {
    searchParams.append('search[query]', query)
    searchParams.append('utf8', '✓')
  }

  const url = `${path}?${searchParams.toString()}`

  return ajaxJSON(url, { method: 'GET' }).then(data => data.json())
    .then(({ count, items }: { count: number; items: string }) => ({
      count,
      items: JSON.parse(items) as T[]
    }))
}

export { ajax, ajaxJSON, fetchPaginated }
