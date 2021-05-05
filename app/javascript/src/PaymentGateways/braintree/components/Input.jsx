// @flow

import React from 'react'
import type { Node } from 'react'
import type { InputProps } from 'PaymentGateways'

const Input = (props: InputProps): Node => (
  <input
    {...props}
    className="col-md-6 form-control"
    type="text"
  />
)

export { Input }
