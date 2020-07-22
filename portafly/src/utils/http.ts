import { getToken } from 'utils'

interface HttpResponse<T> extends Response {
  parsedBody?: T
}

const fetchData = async <T>(request: Request): Promise<T> => {
  const response: HttpResponse<T> = await fetch(request)
  try {
    response.parsedBody = await response.json()
  } catch (ex) {
    throw new Error(`The request ${request} didn't return a valid body`)
  }

  if (!response.ok) {
    throw new Error(response.statusText)
  }
  return response.parsedBody as T
}

const getStringUrl = (path: string, params: URLSearchParams) => {
  const host = process.env.REACT_APP_API_HOST
  // REACT_APP_API_HOST will be undefined in Openshift and URL is not compatible with relative paths
  const url = host ? new URL(path, host) : path
  return `${url.toString()}?${params.toString()}`
}

const craftRequest = (path: string, params = new URLSearchParams()) => {
  const authToken = getToken()
  params.append('access_token', authToken as string)

  return new Request(
    getStringUrl(path, params),
    {
      headers: { Accept: 'application/json' }
    }
  )
}

export { fetchData, craftRequest }
