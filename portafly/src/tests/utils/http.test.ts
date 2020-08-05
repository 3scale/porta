import { craftRequest, fetchData, postData } from 'utils/http'

const authToken = 'LeSuperSecretToken'
const requestParams = (path = '/planets') => ({
  authToken,
  path
})

describe('craftRequest', () => {
  it('should throw when API_HOST is invalid', () => {
    process.env.REACT_APP_API_HOST = 'localhost'
    expect(() => craftRequest(requestParams())).toThrow()

    process.env.REACT_APP_API_HOST = '/wrong'
    expect(() => craftRequest(requestParams())).toThrow()
  })

  it('should craft the correct url provided API_HOST is valid', () => {
    const targetURL = 'http://starwars.db/planets?'

    process.env.REACT_APP_API_HOST = 'http://starwars.db'
    expect(craftRequest(requestParams()).url).toEqual(targetURL)

    process.env.REACT_APP_API_HOST = 'http://starwars.db/'
    expect(craftRequest(requestParams()).url).toEqual(targetURL)

    process.env.REACT_APP_API_HOST = 'http://starwars.db'
    expect(craftRequest(requestParams()).url).toEqual(targetURL)

    process.env.REACT_APP_API_HOST = 'http://starwars.db/'
    expect(craftRequest(requestParams()).url).toEqual(targetURL)
  })

  it('should craft a valid url when API_HOST is unset', () => {
    delete process.env.REACT_APP_API_HOST
    expect(craftRequest(requestParams()).url).toEqual('/planets?')
  })

  it('should include query params', () => {
    const { url } = craftRequest({
      authToken,
      path: '/planets/tatooine/search',
      params: new URLSearchParams({
        name: 'Anakin',
        last_name: 'Skywalker'
      })
    })
    expect(url).toContain('name=Anakin')
    expect(url).toContain('last_name=Skywalker')
  })

  it('should not include "undefined" in the URL when no params', () => {
    const { url } = craftRequest({ authToken, path: '/planets' })
    expect(url).not.toContain('undefined')
  })
})

describe('fetchData', () => {
  const planets = ['Tatooine', 'Jakku', 'Hoth']

  it('should fetch data', async () => {
    global.fetch = jest.fn(() => Promise.resolve({
      ok: true,
      json: () => Promise.resolve(planets)
    }))

    const request = craftRequest(requestParams())
    const res = await fetchData(request)

    expect(res).toEqual(planets)
  })

  it('should throw anything other than 200 status', () => {
    global.fetch = jest.fn(() => Promise.resolve({
      ok: false,
      statusText: 'Not Found'
    }))

    const request = craftRequest(requestParams())
    return fetchData(request)
      .catch((err: Error) => expect(err.message).toBe('Not Found'))
  })
})

describe('postData', () => {
  it('should throw validation errors as an error', async () => {
    global.fetch = jest.fn(() => Promise.resolve({
      status: 422,
      json: () => Promise.resolve({ errors: {} })
    }))

    const request = craftRequest(requestParams('planets/new'))
    const formData = new FormData()

    return postData(request, formData)
      .catch((err: Error) => expect(err).toMatchObject({ validationErrors: expect.anything() }))
  })

  it('should throw anything but 201 or 422', () => {
    global.fetch = jest.fn(() => Promise.resolve({
      status: 404,
      statusText: 'Not Found'
    }))

    const request = craftRequest(requestParams('planets/new'))
    const formData = new FormData()

    return postData(request, formData)
      .catch((err: Error) => expect(err.message).toBe('Not Found'))
  })

  it('should not throw 201', async () => {
    global.fetch = jest.fn(() => Promise.resolve({
      status: 201,
      json: () => Promise.resolve('ok')
    }))

    const request = craftRequest(requestParams('planets/new'))
    const formData = new FormData()

    const res = await postData(request, formData)
    expect(res).toBe('ok')
  })
})
