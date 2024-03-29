import { autocompleteRequestInterceptor } from 'ActiveDocs/OAS3Autocomplete'

import type { Request as SwaggerUIRequest, Response as SwaggerUIResponse } from 'swagger-ui'
import type { AccountDataResponse } from 'Types/SwaggerTypes'

const specUrl = 'https://provider.3scale.test/foo/bar.json'
const apiUrl = 'https://some.api.domain/foo/bar/api-url'
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

const accountData: AccountDataResponse = {
  status: '200',
  results: {
    user_keys: [
      { name: 'Some App', value: '12345678' },
      { name: 'Another App', value: '' }
    ]
  }
}

describe('autocompleteRequestInterceptor', () => {
  describe('when the request is fetching OpenAPI spec', () => {
    let request: SwaggerUIRequest = { loadSpec: true }
    request = autocompleteRequestInterceptor(request, accountData, serviceEndpoint)

    it('should update the response interceptor', () => {
      expect(request.responseInterceptor).toBeDefined()
    })

    it('response interceptor should inject servers to the spec', async () => {
      const res: SwaggerUIResponse = await request.responseInterceptor(specResponse, accountDataUrl, serviceEndpoint)
      expect(res.body.servers).toEqual([{ 'url': 'foo/bar/serviceEndpoint' }])
    })

    it('response interceptor should autocomplete fields of OpenAPI spec with x-data-threescale-name property', async () => {
      const res: SwaggerUIResponse = await request.responseInterceptor(specResponse, accountDataUrl, serviceEndpoint)
      const examplesFirstParam = res.body.paths['/'].get.parameters[0].examples
      const examplesSecondParam = res.body.paths['/'].get.parameters[1].examples

      expect(examplesFirstParam).toEqual([
        { summary: 'First user key from latest 5 applications', value: '-' },
        { summary: 'Some App - 12345678', value: '12345678' },
        { summary: 'Another App', value: '' }
      ])
      expect(examplesSecondParam).toBe(undefined)
    })
  })

  describe('when the request is fetching API call response', () => {
    const originalInterceptor = jest.fn((res: SwaggerUIRequest) => { return res })
    let request: SwaggerUIRequest = { responseInterceptor: originalInterceptor }
    request = autocompleteRequestInterceptor(request, accountData, serviceEndpoint)

    it('should not update the response interceptor', () => {
      expect(request.responseInterceptor).toEqual(originalInterceptor)
    })

    it('should prevent injecting servers to the response', async () => {
      const res: SwaggerUIResponse = await request.responseInterceptor(apiResponse, accountDataUrl, serviceEndpoint)
      expect(res.body.servers).toBe(undefined)
    })
  })
})
