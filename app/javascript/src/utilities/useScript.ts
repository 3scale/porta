import { useEffect } from 'react'

const useScript = (url: string, cb: (ev: Event) => void): void => {
  useEffect(() => {
    const script = document.createElement('script')

    script.src = url
    script.async = true
    script.addEventListener('load', cb)

    document.body.appendChild(script)

    return () => {
      document.body.removeChild(script)
    }
  }, [])
}

export { useScript }
