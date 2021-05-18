// @flow

import { useEffect } from 'react'

type OnSearch = (term?: string) => void
type InputRef = { current: null | React$ElementRef<typeof HTMLInputElement> }

/**
* Custom React hook to use with input fields of type search
* It receives a React reference and attach all necessary hooks and events in order to
* have search on typing. Search event is triggered on 'Enter' pressed.
*/
export const useSearchInputEffect = (inputRef: InputRef, onSearch: OnSearch): void => useEffect(() => {
  const listenToClearButton = ({ inputType }: InputEvent) => {
    if (!inputType) onSearch()
  }

  const listenToKeyDown = ({ key }: KeyboardEvent) => {
    if (key === 'Enter' && inputRef.current) onSearch(inputRef.current.value)
  }

  if (inputRef.current) {
    const { current } = inputRef

    // When the 'clear' button is clicked, inputType is undefined
    current.addEventListener('input', listenToClearButton)

    // Search when 'Enter' key pressed
    current.addEventListener('keydown', listenToKeyDown)
  }

  // Remove all listener on component unmount
  return () => {
    if (inputRef.current) {
      const { current } = inputRef
      current.removeEventListener('input', listenToClearButton)
      current.removeEventListener('keydown', listenToKeyDown)
    }
  }
}, [inputRef])
