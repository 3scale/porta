import {fetchPaginated} from 'utilities/ajax';

import type { FetchItemsRequestParams, FetchItemsResponse } from 'utilities/ajax'
import type { Buyer } from 'NewApplication/types'

const fetchPaginatedBuyers = (path: string, params: FetchItemsRequestParams): FetchItemsResponse<Buyer> => fetchPaginated(path, params)

export { fetchPaginatedBuyers }
