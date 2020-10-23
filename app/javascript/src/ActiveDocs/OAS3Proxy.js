// @flow

import {
  SwaggerRequest,
  Headers
} from 'Types/SwaggerTypes'

const NO_CACHE_HEADERS = {
  'Cache-Control': 'no-cache'
}

const proxiedRequest = (req: SwaggerRequest): SwaggerRequest => {
  const requestUrl = new URL(req.url)

  if (originHttps()) {
    req.url = forceHttpsProtocol(req.url)
  }

  if (!sameOrigin(requestUrl)) {
    req.url = locationOrigin() + '/api_docs/proxy' + '?_=' + new Date().getTime()
    req.headers = Object.assign(req.headers, NO_CACHE_HEADERS, apiDocsHeaders(req, requestUrl))
  }

  return {
    ...req
  }
}

const sameOrigin = (requestUrl: URL): boolean => desiredOrigin(requestUrl) === locationOrigin()

const locationOrigin = (): string => window.top.location.origin

const desiredOrigin = (requestUrl: URL): string => {
  const portPart = requestUrl.port === '443' && requestUrl.protocol === 'https:'
    ? ''
    : requestUrl.port === '' ? '' : ':' + requestUrl.port

  return requestUrl.protocol + '//' + requestUrl.hostname + portPart
}

const apiDocsHeaders = (req: SwaggerRequest, requestUrl: URL): Headers => (
  {
    'X-Apidocs-Method': req.method,
    'X-Apidocs-Path': apiDocsPath(requestUrl),
    'X-Apidocs-Url': desiredOrigin(requestUrl),
    'X-Apidocs-Query': requestUrl.search.replace('?', '')
  }
)

const apiDocsPath = (requestUrl: URL): string => {
  const pathname = requestUrl.pathname
  return pathname.length > 0 && pathname.indexOf('/') !== 0
    ? `/${pathname}`
    : pathname
}

const forceHttpsProtocol = (url: string): string => url.replace(/^http:\/\//i, 'https://')

const originHttps = (): boolean => window.top.location.protocol === 'https:'

export const proxyOAS3 = (req: SwaggerRequest): SwaggerRequest => req.loadSpec
  ? req
  : proxiedRequest(req)
