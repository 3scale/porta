import { fetchPaginated, FetchItemsRequestParams, FetchItemsResponse } from 'utilities/ajax'
import { Product } from 'NewApplication/types'

const fetchPaginatedProducts = (path: string, params: FetchItemsRequestParams): FetchItemsResponse<Product> => fetchPaginated(path, params)

export { fetchPaginatedProducts }
