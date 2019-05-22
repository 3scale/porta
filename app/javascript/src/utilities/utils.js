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

const fetchData = (url: string) => {
  return fetchPolyfill(url)
    .then((response) => {
      return response.json()
    })
    .then(data => data)
    .catch(error => {
      console.error(error)
    })
}

export {
  CSRFToken,
  fetchData
}
