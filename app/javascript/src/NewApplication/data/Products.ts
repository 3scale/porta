import { fetchPaginated } from 'utilities/ajax'
import type { FetchItemsRequestParams, FetchItemsResponse } from 'utilities/ajax'

import type { Product } from 'NewApplication/types'

const fetchPaginatedProducts = (path: string, params: FetchItemsRequestParams): FetchItemsResponse<Product> => fetchPaginated(path, params)

export { fetchPaginatedProducts }
