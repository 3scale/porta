import React from 'react'
import type { ReactNode } from 'react'
import type { InputProps } from 'PaymentGateways'

const Input = (
  {
    id,
    required = false,
    name,
    value,
    onChange
  }: InputProps
): Node => <input
  id={id}
  required={required}
  name={name}
  value={value}
  onChange={onChange}
  className="col-md-6 form-control"
  type="text"
/>

export { Input }
