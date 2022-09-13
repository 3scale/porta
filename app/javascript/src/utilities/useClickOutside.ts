import { useEffect } from 'react'

const useClickOutside = (ref: any, cb: any) => {
  useEffect(() => {
    /**
    * Alert if clicked on outside of element
    */
    function handleClickOutside (event: any) {
      if (ref.current && !ref.current.contains(event.target)) {
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
