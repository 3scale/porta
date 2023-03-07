import { autocompleteInterceptor } from 'ActiveDocs/OAS3Autocomplete'
import * as utils from 'utilities/fetchData'

const specUrl = 'foo/bar.json'
const apiUrl = 'foo/bar/api-url'
const accountDataUrl = 'foo/bar'
const serviceEndpoint = 'foo/bar/serviceEndpoint'
const specResponse = {
  ok: true,
  url: specUrl,
  status: 200,
  statusText: 'OK',
  headers: {},
  text: 'foo',
  data: 'bar',
  body: {
    paths: {
      '/': {
        'get': {
          parameters: [
            {
              name: 'user_key',
              in: 'query',
              description: 'Your API access key',
              required: true,
              'x-data-threescale-name': 'user_keys',
              schema: {
                'type': 'string'
              }
            },
            {
              name: 'another_param',
              in: 'query',
              description: 'Not autocomplete this param',
              schema: {
                'type': 'string'
              }
            }
          ]
        }
      }
    }
  },
  obj: {}
}
const apiResponse = {
  ...specResponse,
  url: apiUrl,
  body: {
    contents: {}
  }
}

const accountData = {
  status: 200,
  results: {
    user_keys: [{ name: 'Some App', value: '12345678' }]
  }
} as const

const fetchDataSpy = jest.spyOn(utils, 'fetchData')
fetchDataSpy.mockResolvedValue(accountData)

it('should inject servers to OpenAPI spec', () => {
  return autocompleteInterceptor(specResponse, specUrl, accountDataUrl, serviceEndpoint).then(res => {
    expect(res.body.servers).toEqual([{ 'url': 'foo/bar/serviceEndpoint' }])
  })
})

it('should not inject servers to API calls responses', () => {
  return autocompleteInterceptor(apiResponse, specUrl, accountDataUrl, serviceEndpoint).then(res => {
    expect(res.body.servers).toBe(undefined)
  })
})

it('should autocomplete fields of OpenAPI spec with x-data-threescale-name property', () => {
  return autocompleteInterceptor(specResponse, specUrl, accountDataUrl, serviceEndpoint).then(res => {
    const examplesFirstParam = res.body.paths['/'].get.parameters[0].examples
    const examplesSecondParam = res.body.paths['/'].get.parameters[1].examples

    expect(examplesFirstParam).toEqual([
      { summary: 'First user key from latest 5 applications', value: '-' },
      { summary: 'Some App', value: '12345678' }
    ])
    expect(examplesSecondParam).toBe(undefined)
  })
})
