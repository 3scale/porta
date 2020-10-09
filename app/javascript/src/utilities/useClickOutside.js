import { useEffect } from 'react'

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

    document.addEventListener('mousedown', handleClickOutside)
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [ref])
}

export { useClickOutside }
