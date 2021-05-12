// @flow

import React from 'react'
import type { Node } from 'react'
import type { ListItemProps } from 'PaymentGateways'

const ListItem = ({ id, children }: ListItemProps): Node => {
  return (
    <li
      id={id}
      className="string optional form-group"
    >
      {children}
    </li>
  )
}

export { ListItem }
