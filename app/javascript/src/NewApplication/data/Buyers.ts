import { fetchPaginated } from 'utilities/ajax'

import type { FetchPaginatedParams, FetchItemsResponse } from 'utilities/ajax'
import type { Buyer } from 'NewApplication/types'

const fetchPaginatedBuyers = (path: string, params: FetchPaginatedParams): FetchItemsResponse<Buyer> => fetchPaginated(path, params)

export { fetchPaginatedBuyers }
