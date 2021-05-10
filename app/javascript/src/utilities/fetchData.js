// @flow

import {fetch as fetchPolyfill} from 'whatwg-fetch'

export function fetchData<T> (url: string): Promise<T> {
  return fetchPolyfill(url)
    .then(response => {
      if (!response.ok) {
        throw new Error(response.statusText)
      }

      return response.json()
    })
}
