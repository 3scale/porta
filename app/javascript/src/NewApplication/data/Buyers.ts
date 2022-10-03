import { fetchPaginated, FetchItemsRequestParams, FetchItemsResponse } from 'utilities/ajax'
import { Buyer } from 'NewApplication/types'

const fetchPaginatedBuyers = (path: string, params: FetchItemsRequestParams): FetchItemsResponse<Buyer> => fetchPaginated(path, params)

export { fetchPaginatedBuyers }
