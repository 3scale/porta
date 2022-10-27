/* eslint-disable @typescript-eslint/naming-convention */
import { ajax, ajaxJSON, fetchPaginated } from 'utilities/ajax'

const mockedFetch = jest.fn()
global.fetch = mockedFetch

beforeEach(() => { mockedFetch.mockClear() })

describe('#ajax', () => {
  it('should make a request with the correct options', () => {
    const params = new URLSearchParams()

    void ajax('url', {
      method: 'GET',
      body: params
    })

    expect(mockedFetch).toHaveBeenCalledWith('url', {
      method: 'GET',
      body: params,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'X-CSRF-Token': ''
      },
      signal: undefined
    })
  })
})

describe('#ajaxJSON', () => {
  it('should make a request with the correct options', () => {
    const params = new URLSearchParams()

    void ajaxJSON('url', {
      method: 'POST',
      body: params
    })

    expect(mockedFetch).toHaveBeenCalledWith('url', {
      method: 'POST',
      body: params,
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-Token': ''
      },
      signal: undefined
    })
  })
})

describe('#fetchPaginated', () => {
  const items = [{ id: 1, name: 'name' }]

  mockedFetch.mockResolvedValue({
    json: async () => Promise.resolve({ count: items.length, items: JSON.stringify(items) })
  })

  it('should make the proper request', () => {
    void fetchPaginated('url', { page: 1, perPage: 20 })
    expect(mockedFetch).toHaveBeenCalledWith('url?page=1&per_page=20', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-Token': ''
      },
      signal: undefined
    })
  })

  it('should make a search request', () => {
    void fetchPaginated('url', { page: 2, perPage: 10, query: 'foo' })
    expect(mockedFetch).toHaveBeenCalledWith('url?page=2&per_page=10&search%5Bquery%5D=foo&utf8=%E2%9C%93', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-Token': ''
      },
      signal: undefined
    })
  })

  it('should fetch some items', async () => {
    const res = await fetchPaginated('url', { page: 2, perPage: 10 })
    expect(mockedFetch).toHaveBeenCalledWith('url?page=2&per_page=10', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-Token': ''
      },
      signal: undefined
    })

    expect(res).toMatchObject({ count: items.length, items })
  })
})
