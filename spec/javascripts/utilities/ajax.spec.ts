import { ajax, ajaxJSON, fetchPaginated } from 'utilities/ajax'

const fetch = jest.fn()
global.fetch = fetch

beforeEach(() => { fetch.mockClear() })

describe('#ajax', () => {
  it('should make a request with the correct options', () => {
    const params = new URLSearchParams()

    ajax('url', {
      method: 'GET',
      body: params
    })

    expect(fetch).toHaveBeenCalledWith('url', {
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

    ajaxJSON('url', {
      method: 'POST',
      body: params
    })

    expect(fetch).toHaveBeenCalledWith('url', {
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

  fetch.mockResolvedValue({
    json: () => Promise.resolve({ count: items.length, items: JSON.stringify(items) })
  })

  it('should make the proper request', () => {
    fetchPaginated('url', { page: 1, perPage: 20 })
    expect(fetch).toHaveBeenCalledWith('url?page=1&per_page=20', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-Token': ''
      },
      signal: undefined
    })
  })

  it('should make a search request', () => {
    fetchPaginated('url', { page: 2, perPage: 10, query: 'foo' })
    expect(fetch).toHaveBeenCalledWith('url?page=2&per_page=10&search%5Bquery%5D=foo&utf8=%E2%9C%93', {
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
    expect(fetch).toHaveBeenCalledWith('url?page=2&per_page=10', {
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
