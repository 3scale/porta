/* eslint-disable @typescript-eslint/naming-convention */
interface ResponseBody { redirect?: string }
interface APIResponse<T> extends Response { json: () => Promise<ResponseBody & T> }
type FetchFunction = <T>(url: string, opts: RequestInit) => Promise<APIResponse<T>>

// eslint-disable-next-line @typescript-eslint/sort-type-constituents -- We want Record after
export type FetchPaginatedParams = { page: number; perPage: number; query?: string } & Record<string, number | string>
export type FetchItemsResponse<T> = Promise<{ items: T[]; count: number }>

export type PatchResponse = Promise<{ success: boolean; message: string }>

const _ajax = (headers: Record<string, string>) => {
  const meta = document.querySelector('meta[name="csrf-token"]')
  const token: string = meta?.getAttribute('content') ?? ''

  return function (url: string, { method, body, signal }: RequestInit) {
    return fetch(url, {
      method: method,
      headers: { ...headers, 'X-CSRF-Token': token },
      body,
      signal
    })
  }
}

const ajax: FetchFunction = _ajax({ 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' })
const ajaxJSON: FetchFunction = _ajax({ 'Content-Type': 'application/json; charset=UTF-8', 'Accept': 'application/json; charset=UTF-8' })

async function fetchPaginated<T> (path: string, params: FetchPaginatedParams): FetchItemsResponse<T> {
  const { page, perPage, query = '', ...rest } = params

  const searchParams = new URLSearchParams({
    page: String(page),
    per_page: String(perPage)
  })

  if (query !== '') {
    searchParams.append('search[query]', query)
    searchParams.append('utf8', '✓')
  }

  for (const param in rest) {
    searchParams.append(param, String(rest[param]))
  }

  const url = `${path}?${searchParams.toString()}`

  return ajaxJSON<{ count: number; items: string }>(url, { method: 'GET' })
    .then(data => data.json())
    .then(({ count, items }) => ({
      count,
      items: JSON.parse(items) as T[]
    }))
}

/**
 *
 * @param path The full path to the endpoint (starts with a dash)
 * @param record The hash that will be used by the controller to update the record (watch the case is correct!)
 * @returns success state and a message to show in a toast
 */
async function patch (path: string, record: unknown): PatchResponse {
  return ajaxJSON(path, {
    method: 'PATCH',
    body: JSON.stringify(record)
  }).then(response => response.json() as PatchResponse)
}

export { ajax, ajaxJSON, fetchPaginated, patch }
