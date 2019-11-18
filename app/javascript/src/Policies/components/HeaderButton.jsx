// @flow

import * as React from 'react'

import type { ThunkAction } from 'Policies/types'

type Props = {
  type: 'add' | 'cancel',
  onClick: () => ThunkAction,
  children?: React.Node
}

const classNames = {
  add: 'PolicyChain-addPolicy',
  cancel: 'PolicyChain-addPolicy--cancel'
}

const icons = {
  add: 'fa fa-plus-circle',
  cancel: 'fa fa-times-circle'
}

const HeaderButton = ({ type, onClick, children }: Props) => (
  <div className={classNames[type]} onClick={onClick}>
    <i className={icons[type]} />{children}
  </div>
)

export { HeaderButton }
