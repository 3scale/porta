import React from 'react'

const Label = ({ htmlFor, label, required }: { htmlFor: string, label: string, required: boolean }) => (
  <label
    htmlFor={htmlFor}
    className="col-md-4 control-label"
  >{`${label} ${required ? '*' : ''}`}
  </label>
)

export { Label }
