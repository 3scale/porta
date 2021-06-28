// @flow

import { fetchPaginatedBuyers } from 'NewApplication/data/Buyers'
import * as ajax from 'utilities/ajax'

const getJsonSpy = jest.spyOn(ajax, 'getJSON')
  .mockResolvedValue({
    json: () => ({ items: [], count: 100 })
  })

const path = '/buyers'

describe('fetchPaginatedBuyers', () => {
  beforeEach(() => {
    getJsonSpy.mockClear()
  })

  it('should fetch paginated buyers and the total count', async () => {
    const opts = { page: 1, perPage: 10 }
    expect(await fetchPaginatedBuyers(path, opts)).toMatchObject({
      items: expect.any(Array),
      count: expect.any(Number)
    })
    expect(getJsonSpy).toHaveBeenCalledTimes(1)
    expect(getJsonSpy).toHaveBeenCalledWith('/buyers?page=1&per_page=10&sort=created_at&direction=desc')
  })

  it('should filter by query', async () => {
    const opts = { page: 1, perPage: 10, query: 'some query' }
    await fetchPaginatedBuyers(path, opts)
    expect(getJsonSpy).toHaveBeenCalledWith(expect.stringContaining('search%5Bquery%5D=some+query&utf8=%E2%9C%93'))
    expect(getJsonSpy).toHaveBeenCalledTimes(1)

    delete opts.query
    await fetchPaginatedBuyers(path, opts)
    expect(getJsonSpy).not.toHaveBeenCalledWith(expect.stringContaining('search[query]=some query&utf8=✓'))
    expect(getJsonSpy).toHaveBeenCalledTimes(2)
  })
})
