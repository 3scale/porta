// @flow

import { fetchPaginatedProducts } from 'NewApplication/data/Products'

import * as ajax from 'utilities/ajax'
const ajaxJSONSpy = jest.spyOn(ajax, 'ajaxJSON')
  .mockResolvedValue({
    json: () => ({ items: [], count: 100 })
  })

const path = '/products'

describe('fetchPaginatedProducts', () => {
  beforeEach(() => {
    ajaxJSONSpy.mockClear()
  })

  it('should fetch paginated products and total count', async () => {
    const opts = { page: 1, perPage: 10 }
    expect(await fetchPaginatedProducts(path, opts)).toEqual({
      items: expect.any(Array),
      count: expect.any(Number)
    })
    expect(ajaxJSONSpy).toHaveBeenCalledTimes(1)
    expect(ajaxJSONSpy).toHaveBeenCalledWith('/products?page=1&per_page=10&sort=updated_at&direction=desc', { method: 'GET' })
  })

  it('should filter by query', async () => {
    const opts = { page: 1, perPage: 10, query: 'some query' }
    await fetchPaginatedProducts(path, opts)
    expect(ajaxJSONSpy).toHaveBeenCalledTimes(1)
    expect(ajaxJSONSpy).toHaveBeenCalledWith(expect.stringContaining('search%5Bquery%5D=some+query&utf8=%E2%9C%93'), { method: 'GET' })

    delete opts.query
    await fetchPaginatedProducts(path, opts)
    expect(ajaxJSONSpy).toHaveBeenCalledTimes(2)
    expect(ajaxJSONSpy).not.toHaveBeenCalledWith(expect.stringContaining('search[query]=some query&utf8=✓'))
  })
})
