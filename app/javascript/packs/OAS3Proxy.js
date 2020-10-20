const NO_CACHE_HEADERS = {
  'Cache-Control': 'no-cache'
}

const proxiedRequest = (req) => {
  if (originHttps()) {
    req.url = forceHttpsProtocol(req.url)
  }
  const linkElement = createLinkElement(req.url)
  req.originalUrl = req.url
  console.log(`[ApiDocsProxy] incoming url ${req.url}`)
  // let method = req.method
  if (!sameOrigin(linkElement)) {
    if (!req.method) {
      req.method = req.type || 'POST' // fallback to POST
    }
    req.url = locationOrigin() + '/api_docs/proxy' + '?_=' + new Date().getTime() // cache buster
    console.log(`[ApiDocsProxy] proxying ${req.originalUrl}`)
    $.extend(req.headers, NO_CACHE_HEADERS, apiDocsHeaders(req, linkElement))
  }
  // result = httpClient.execute(obj)
  if (!sameOrigin(linkElement)) {
    req.url = req.originalUrl
  }

  return {
    ...req
  }
}

const createLinkElement = function (url) {
  const linkElement = window.document.createElement('a')
  linkElement.href = url
  return linkElement
}

const sameOrigin = function (linkElement) {
  return desiredOrigin(linkElement) === locationOrigin()
}

const locationOrigin = function () {
  return window.top.location.origin
}

const desiredOrigin = function (linkElement) {
  var portPart
  if (linkElement.port === '443' && linkElement.protocol === 'https:') {
    portPart = ''
  } else {
    portPart = linkElement.port === '' ? '' : ':' + linkElement.port
  }
  return linkElement.protocol + '//' + linkElement.hostname + portPart
}

const apiDocsHeaders = function (req, linkElement) {
  return {
    'X-Apidocs-Method': req.method,
    'X-Apidocs-Path': apiDocsPath(linkElement),
    'X-Apidocs-Url': desiredOrigin(linkElement),
    'X-Apidocs-Query': linkElement.search.replace('?', '')
  }
}

const apiDocsPath = function (linkElement) {
  var pathname
  pathname = linkElement.pathname
  if (pathname.length > 0 && pathname.indexOf('/') !== 0) {
    pathname = '/' + pathname
  }
  return pathname
}

const forceHttpsProtocol = function (url) {
  return url.replace(/^http:\/\//i, 'https://')
}

const originHttps = function () {
  return window.top.location.protocol === 'https:'
}

export const proxyOAS3 = (req, activeDocsProxyDisabled) => {
  return activeDocsProxyDisabled ? req : proxiedRequest(req)
}
