// @flow

import * as React from 'react'
import { Button } from '@patternfly/react-core'
import { PlusIcon, TimesIcon } from '@patternfly/react-icons'

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

const Icon = ({ type }) => (
  type === 'add' ? <PlusIcon/> : <TimesIcon/>
)

const HeaderButton = ({ type, onClick, children }: Props): React.Node => (
  <Button
    className={classNames[type]}
    variant="link"
    icon={<Icon type={type}/>}
    iconPosition="left"
    onClick={onClick}
  >
    {children}
  </Button>
)

export { HeaderButton }
