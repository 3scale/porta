// @flow

import * as React from 'react'

import type { ThunkAction } from 'Policies/types'

type Props = {
  type: 'add' | 'cancel',
  onClick: () => ThunkAction,
  children?: React.Node
}

const getIcon = type => {
  switch (type) {
    case 'add':
      return 'fa fa-plus-circle'
    case 'cancel':
      return 'fa fa-times-circle'
  }
}

const getClass = type => {
  switch (type) {
    case 'add':
      return 'PolicyChain-addPolicy'
    case 'cancel':
      return 'PolicyChain-addPolicy--cancel'
  }
}

const HeaderButton = ({ type, onClick, children }: Props) => (
  <div className={getClass(type)} onClick={onClick}>
    <i className={getIcon(type)} />{children}
  </div>
)

export { HeaderButton }
