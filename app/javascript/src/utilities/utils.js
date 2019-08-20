// @flow
import {fetch as fetchPolyfill} from 'whatwg-fetch'
import 'core-js/es6/promise'
import React from 'react'

function CSRFToken ({win = window}: {win?: Window}) {
  const getMetaContent = meta => win.document.head.querySelector(`meta[name~=${meta}][content]`).content

  try {
    return (
      <input
        name={getMetaContent('csrf-param')}
        value={getMetaContent('csrf-token')}
        type='hidden'
      />
    )
  } catch (error) {
    console.error(error)
    return (
      <input
        name={null}
        value={null}
        type='hidden'
      />
    )
  }
}

const fetchData = <T>(url: string): Promise<T> => {
  return fetchPolyfill(url)
    .then(response => {
      if (!response.ok) {
        throw new Error(response.statusText)
      }

      return response.json()
    })
}

export {
  CSRFToken,
  fetchData
}
