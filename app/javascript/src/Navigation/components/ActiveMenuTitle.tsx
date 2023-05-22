/* eslint-disable react/jsx-key */
import CubeIcon from '@patternfly/react-icons/dist/js/icons/cube-icon'
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon'
import BullseyeIcon from '@patternfly/react-icons/dist/js/icons/bullseye-icon'
import HomeIcon from '@patternfly/react-icons/dist/js/icons/home-icon'
import CogIcon from '@patternfly/react-icons/dist/js/icons/cog-icon'
import { Icon } from '@patternfly/react-core'

import type { Menu } from 'Types'
import type { FunctionComponent, ReactElement } from 'react'

import './ActiveMenuTitle.scss'

interface Props {
  activeMenu: Menu;
}

const ActiveMenuTitle: FunctionComponent<Props> = ({ activeMenu }) => {
  const getIconAndText: () => [ReactElement | undefined, string] = () => {
    switch (activeMenu) {
      case 'dashboard':
        return [<HomeIcon />, 'Dashboard']

      case 'personal':
      case 'account':
      case 'active_docs':
        return [<CogIcon />, 'Account Settings']

      case 'audience':
      case 'buyers':
      case 'finance':
      case 'cms':
      case 'site':
      case 'settings':
      case 'apis':
      case 'applications':
        return [<BullseyeIcon />, 'Audience']

      case 'serviceadmin':
      case 'monitoring':
      case 'products':
        return [<CubesIcon />, 'Products']

      case 'backend_api':
      case 'backend_apis':
        return [<CubeIcon />, 'Backends']

      case 'quickstarts':
        return [undefined, '--']

      default:
        return [undefined, '']
    }
  }

  const [icon, text] = getIconAndText()

  return (
    <span className="pf-c-context-selector__toggle-text">
      {icon && <Icon isInline className="header-context-selector__toggle-text-icon">{icon}</Icon>}
      {text}
    </span>
  )
}

export type { Props }
export { ActiveMenuTitle }
