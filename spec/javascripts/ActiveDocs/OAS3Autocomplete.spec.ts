import { autocompleteOAS3 } from 'ActiveDocs/OAS3Autocomplete'
import * as utils from 'utilities/fetchData'

const accountDataUrl = 'foo/bar'
const serviceEndpoint = 'foo/bar/serviceEndpoint'
const response = {
  ok: true,
  url: 'foo/bar.json',
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

const accountData = {
  status: 200,
  results: {
    user_keys: [{ name: 'Some App', value: '12345678' }]
  }
} as const

const fetchDataSpy = jest.spyOn(utils, 'fetchData')
fetchDataSpy.mockResolvedValue(accountData)

it('should inject servers to response body', () => {
  return autocompleteOAS3(response, accountDataUrl, serviceEndpoint).then(res => {
    expect(res.body.servers).toEqual([{ 'url': 'foo/bar/serviceEndpoint' }])
  })
})

it('should autocomplete fields with x-data-threescale-name property', () => {
  return autocompleteOAS3(response, accountDataUrl, serviceEndpoint).then(res => {
    const examplesFirstParam = res.body.paths['/'].get.parameters[0].examples
    const examplesSecondParam = res.body.paths['/'].get.parameters[1].examples

    expect(examplesFirstParam).toEqual([
      { summary: 'First user key from latest 5 applications', value: '-' },
      { summary: 'Some App', value: '12345678' }
    ])
    expect(examplesSecondParam).toBe(undefined)
  })
})
