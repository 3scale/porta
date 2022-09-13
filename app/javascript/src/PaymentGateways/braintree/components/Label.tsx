import React from 'react'
import type { ReactNode } from 'react'
import type { LabelProps } from 'PaymentGateways'

const Label = (
  {
    htmlFor,
    label,
    required
  }: LabelProps
): Node => <label
  htmlFor={htmlFor}
  className="col-md-4 control-label"
>
  {`${label}${required ? ' *' : ''}`}
</label>

export { Label }
