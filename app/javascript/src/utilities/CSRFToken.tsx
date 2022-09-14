import * as React from 'react'

type Props = {
  win?: Window
}

const CSRFToken = ({ win = window }: Props) => {
  function getMetaContent (metaName: string) {
    const meta = win.document.querySelector<HTMLMetaElement>(`head > meta[name~=${metaName}][content]`)
    return meta ? meta.content : undefined
  }

  return (
    <input
      name={getMetaContent('csrf-param')}
      value={getMetaContent('csrf-token')}
      type='hidden'
    />
  )
}

export { CSRFToken }
