import React, { FunctionComponent } from 'react'
import { Button } from '@patternfly/react-core'
import { PlusIcon, TimesIcon } from '@patternfly/react-icons'
import { ThunkAction } from 'Policies/types/Actions'

type ButtonType = 'add' | 'cancel'
type Props = {
  type: ButtonType,
  onClick: () => ThunkAction,
  children?: React.ReactNode
};

const classNames: Record<ButtonType, string> = {
  add: 'PolicyChain-addPolicy',
  cancel: 'PolicyChain-addPolicy--cancel'
}

const Icon: FunctionComponent<{ type: ButtonType }> = ({ type }) => (
  type === 'add' ? <PlusIcon/> : <TimesIcon/>
)

const HeaderButton: FunctionComponent<Props> = ({
  type,
  onClick,
  children
}) => <Button
  className={classNames[type]}
  variant="link"
  icon={<Icon type={type}/>}
  iconPosition="left"
  onClick={onClick}
>
  {children}
</Button>

export { HeaderButton }
