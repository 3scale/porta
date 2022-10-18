import 'core-js/es6/map'
import 'core-js/es6/set'

import type { FunctionComponent } from 'react'
import type { Menu } from 'Types'

import './ActiveMenuTitle.scss'

type Props = {
  activeMenu: Menu
}

const ActiveMenuTitle: FunctionComponent<Props> = ({ activeMenu }) => {
  const getIconAndText: () => [string, string] = () => {
    switch (activeMenu) {
      case 'dashboard':
        return ['fa-home', 'Dashboard']

      case 'personal':
      case 'account':
      case 'active_docs':
        return ['fa-cog', 'Account Settings']

      case 'audience':
      case 'buyers':
      case 'finance':
      case 'cms':
      case 'site':
      case 'settings':
      case 'apis':
      case 'applications':
        return ['fa-bullseye', 'Audience']

      case 'serviceadmin':
      case 'monitoring':
      case 'products':
        return ['fa-cubes', 'Products']

      case 'backend_api':
      case 'backend_apis':
        return ['fa-cube', 'Backends']

      case 'quickstarts': // FIXME: ContextSelector should probably hide or something
        return ['', '--']

      default:
        return ['', '']
    }
  }

  const [icon, text] = getIconAndText()

  return (
    <>
      <span className="pf-c-context-selector__toggle-text">
        <i className={`fa ${icon}` + ' header-context-selector__toggle-text-icon'} />
        {text}
      </span>
      <i className="fa fa-chevron-down  pf-c-context-selector__toggle-icon" />
    </>
  )
}

export { ActiveMenuTitle, Props }
