import { useCallback, useEffect } from 'react'

const useConfirmToLeave = (unsaved: boolean): void => {
  const beforeUnloadHandler = useCallback((e: Event) => { e.preventDefault() }, [])

  useEffect(() => {
    if (unsaved) {
      window.addEventListener('beforeunload', beforeUnloadHandler)
    } else {
      window.removeEventListener('beforeunload', beforeUnloadHandler)
    }
  }, [unsaved])
}

export { useConfirmToLeave }
