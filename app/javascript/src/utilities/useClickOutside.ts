import { useEffect } from 'react'

const useClickOutside = (ref: React.MutableRefObject<HTMLElement | null>, cb: () => unknown): void => {
  useEffect(() => {
    /**
    * Alert if clicked on outside of element
    */
    function handleClickOutside (event: Event) {
      if (ref.current && !ref.current.contains(event.target as Node)) {
        cb()
      }
    }

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [ref])
}

export { useClickOutside }
