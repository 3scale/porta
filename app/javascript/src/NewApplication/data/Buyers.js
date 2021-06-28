// @flow

import { getJSON } from 'utilities'

import type { Buyer, FetchItemsRequestParams, FetchItemsResponse } from 'NewApplication/types'

const fetchPaginatedBuyers = (path: string, params: FetchItemsRequestParams): FetchItemsResponse<Buyer> => {
  const { page, perPage, query = '' } = params

  const searchParams = new URLSearchParams({
    // $FlowIgnore[incompatible-call] bullshit
    page,
    // $FlowIgnore[incompatible-call] bullshit
    per_page: perPage,
    sort: 'created_at',
    direction: 'desc'
  })

  if (query !== '') {
    searchParams.append('search[query]', query)
    searchParams.append('utf8', '✓')
  }

  const url = `${path}?${searchParams.toString()}`

  return getJSON(url).then(data => data.json())
}

export { fetchPaginatedBuyers }
