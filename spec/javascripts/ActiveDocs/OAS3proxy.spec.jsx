import { proxyOAS3 } from 'ActiveDocs/OAS3Proxy.js'

it('should return request url unchanged when loading spec', () => {
  const request = {
    loadSpec: true,
    url: 'http://www.example.com',
    credentials: 'same-origin',
    headers: {}
  }
  expect(proxyOAS3(request)).toEqual(request)
})

it('should return modified request url and headers when making http requests', () => {
  const request = {
    method: 'GET',
    url: 'http://www.example.com',
    credentials: 'same-origin',
    headers: {}
  }
  const modifiedRequest = proxyOAS3(request)
  const expectedHeaders = {
    'Cache-Control': 'no-cache',
    'X-Apidocs-Method': 'GET',
    'X-Apidocs-Path': '/',
    'X-Apidocs-Query': '',
    'X-Apidocs-Url': 'http://www.example.com'
  }
  expect(modifiedRequest.url).toEqual(expect.stringContaining('/api_docs/proxy?_='))
  expect(modifiedRequest.headers).toEqual(expectedHeaders)
})
