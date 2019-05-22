// @flow

import React from 'react'

type Props = {
  htmlFor: string,
  label: string,
  required?: boolean
}
const Label = (props: Props) => {
  const {htmlFor, label, required} = props
  return <label htmlFor={htmlFor}>{label}
    {required && <abbr title="required">*</abbr>}
  </label>
}

export {Label}
