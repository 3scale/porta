// @flow

import { fetchPaginatedProducts } from 'NewApplication/data/Products'
import * as ajax from 'utilities/ajax'

const getJsonSpy = jest.spyOn(ajax, 'getJSON')
  .mockResolvedValue({
    json: () => ({ items: [], count: 100 })
  })

const path = '/products'

describe('fetchPaginatedProducts', () => {
  beforeEach(() => {
    getJsonSpy.mockClear()
  })

  it('should fetch paginated products', async () => {
    const opts = { page: 1, perPage: 10 }
    expect(await fetchPaginatedProducts(path, opts)).toEqual({
      items: [],
      count: 100
    })
    expect(getJsonSpy).toHaveBeenCalledTimes(1)
  })

  it('should return the total count', async () => {
    const opts = { page: 1, perPage: 10 }
    expect(await fetchPaginatedProducts(path, opts)).toEqual({
      items: [],
      count: 100
    })
    expect(getJsonSpy).toHaveBeenCalledTimes(1)
  })

  it('should filter by query', async () => {
    const opts = { page: 1, perPage: 10, query: 'some query' }
    expect(await fetchPaginatedProducts(path, opts)).toEqual({
      items: [],
      count: 100
    })
    expect(getJsonSpy).toHaveBeenCalledTimes(1)
  })
})
