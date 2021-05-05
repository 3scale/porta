// @flow

import { useEffect } from 'react'

// $FlowFixMe[signature-verification-failure]
const useClickOutside = (ref, cb) => {
  useEffect(() => {
    /**
    * Alert if clicked on outside of element
    */
    function handleClickOutside (event) {
      if (ref.current && !ref.current.contains(event.target)) {
        cb()
      }
    }

    // $FlowFixMe[speculation-ambiguous]
    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      // $FlowFixMe[speculation-ambiguous]
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [ref])
}

export { useClickOutside }
