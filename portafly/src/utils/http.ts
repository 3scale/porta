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

const craftRequest = (path: string, params: URLSearchParams) => {
  const authToken = getToken()

  const url = new URL(`${process.env.REACT_APP_API_HOST || '/'}${path}?${params.toString()}`)
  url.searchParams.append('access_token', authToken as string)

  return new Request(
    url.toString(),
    {
      headers: { Accept: 'application/json' }
    }
  )
}

export { fetchData, craftRequest }
