/* eslint-disable @typescript-eslint/no-throw-literal */
import { getToken } from 'utils'

export type ValidationException = {
  validationErrors: ValidationErrors
}

export type ValidationErrors = Record<string, string[]>

// Anything else than a 200 should be considered an error.
const fetchData = async <T>(request: Request): Promise<T> => {
  const response = await fetch(request)

  if (!response.ok) {
    throw new Error(response.statusText)
  }

  return await response.json() as T
}

// Watch for validation errors (422) and throw then in an error. Other than 201 is unexpected and
// should be considered an error as well
const postData = async <T>(request: Request, formData: FormData): Promise<T | any> => {
  const body = Array.from(formData)
    .reduce((acc, [key, value]) => acc.concat(`&${key}=${value}`), '')

  const response = await fetch(request, { method: 'POST', body })

  if (response.status === 422) {
    const responseBody = await response.json()
    throw { validationErrors: responseBody.errors } as ValidationException
  }

  if (response.status === 201) {
    const created = await response.json() as T

    return created
  }

  throw new Error(response.statusText)
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
      headers: {
        Accept: 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded'
      }
    }
  )
}

export { fetchData, postData, craftRequest }
