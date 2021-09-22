// @flow

export type FetchItemsRequestParams = $Exact<{
  page: number,
  perPage: number,
  query?: string
}>

export type FetchItemsResponse<T> = Promise<{ items: T[], count: number }>
