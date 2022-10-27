import { Button } from '@patternfly/react-core'
import { PlusIcon, TimesIcon } from '@patternfly/react-icons'

import type { FunctionComponent } from 'react'
import type { ThunkAction } from 'Policies/types/Actions'

type ButtonType = 'add' | 'cancel'
interface Props {
  type: ButtonType;
  onClick: () => ThunkAction;
  children?: React.ReactNode;
}

const classNames: Record<ButtonType, string> = {
  add: 'PolicyChain-addPolicy',
  cancel: 'PolicyChain-addPolicy--cancel'
}

const HeaderButton: FunctionComponent<Props> = ({
  type,
  onClick,
  children
}) => (
  <Button
    className={classNames[type]}
    icon={<Icon type={type} />}
    iconPosition="left"
    variant="link"
    onClick={onClick}
  >
    {children}
  </Button>
)

// eslint-disable-next-line react/no-multi-comp -- FIXME: move to its own file
const Icon: FunctionComponent<{ type: ButtonType }> = ({ type }) => (
  type === 'add' ? <PlusIcon /> : <TimesIcon />
)

export { HeaderButton }
