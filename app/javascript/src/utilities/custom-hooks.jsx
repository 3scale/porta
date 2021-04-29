// @flow
/* eslint-disable flowtype/no-weak-types */

import { useEffect } from 'react'

export const useSearchInputEffect = (
  searchInputRef: {| current: null | React$ElementRef<any> |},
  searchCallback: (term?: string) => void
): void => useEffect(() => {
  if (searchInputRef.current) {
    searchInputRef.current.addEventListener('input', ({ inputType }) => {
      if (!inputType) searchCallback()
    })
  }
}, [searchInputRef.current])
