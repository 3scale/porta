import { fetchPaginated } from 'utilities/ajax'

import type { FetchPaginatedParams, FetchItemsResponse } from 'utilities/ajax'
import type { Product } from 'NewApplication/types'

const fetchPaginatedProducts = (path: string, params: FetchPaginatedParams): FetchItemsResponse<Product> => fetchPaginated(path, params)

export { fetchPaginatedProducts }
