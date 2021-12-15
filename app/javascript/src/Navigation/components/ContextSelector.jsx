// @flow

import * as React from 'react'

import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'
import { createReactWrapper, useClickOutside } from 'utilities'

import 'Navigation/styles/ContextSelector.scss'

import type { Menu } from 'Types'

type Props = {
  activeMenu: Menu,
  audienceLink: string,
  settingsLink: string,
  productsLink: string,
  backendsLink: string,
  resourcesLink: string
}

const DASHBOARD_PATH = '/p/admin/dashboard'

const ContextSelector = ({ activeMenu, audienceLink, settingsLink, productsLink, backendsLink, resourcesLink }: Props): React.Node => {
  /*
  activeMenu: "backend_apis"
  audienceLink: "/buyers/accounts"
  backendsLink: "/p/admin/backend_apis"
  productsLink: "/apiconfig/services"
  settingsLink: "/p/admin/account"
  */
  const [isOpen, setIsOpen] = React.useState(false)
  const ref = React.useRef(null)
  useClickOutside(ref, () => setIsOpen(false))

  function getClassNamesForMenu (menu: Menu): string {
    const isDashboardSelected = menu === 'dashboard' && activeMenu === 'dashboard'
    const isAudienceSelected = menu === 'audience' && (['buyers', 'finance', 'cms', 'site'].indexOf(activeMenu) !== -1)
    const isProductsSelected = menu === 'products' && (['serviceadmin', 'monitoring', 'products'].indexOf(activeMenu) !== -1)
    const isBackendsSelected = menu === 'backend_api' && (['backend_api', 'backend_apis'].indexOf(activeMenu) !== -1)
    const isSettingsSelected = menu === 'account' && (['account', 'personal', 'active_docs'].indexOf(activeMenu) !== -1)
    const isResourcesSelected = menu === 'resources' && activeMenu === 'resources'

    if (isDashboardSelected || isAudienceSelected || isProductsSelected || isBackendsSelected || isSettingsSelected || isResourcesSelected) {
      return 'pf-c-context-selector__menu-list-item current-context'
    }

    return 'pf-c-context-selector__menu-list-item'
  }

  return (
    <div className={`pf-c-context-selector header-context-selector ${isOpen ? ' pf-m-expanded' : ''}`} ref={ref}>
      <a className="pf-c-context-selector__toggle " title="Context Selector" onClick={() => setIsOpen(!isOpen)}>
        <ActiveMenuTitle activeMenu={activeMenu} />
      </a>
      {isOpen && (
        <div className="pf-c-context-selector__menu">
          <ul id="context-menu" className="pf-c-context-selector__menu-list" style={{
            '--pf-c-context-selector__menu-list--MaxHeight': '15rem'
          }}>
            <li>
              <a className={getClassNamesForMenu('dashboard')} href={DASHBOARD_PATH}>
                <i className='fa fa-home header-context-selector__item-icon' />Dashboard
              </a>
            </li>
            {audienceLink && (
              <li>
                <a className={getClassNamesForMenu('audience')} href={audienceLink}>
                  <i className='fa fa-bullseye header-context-selector__item-icon' />Audience
                </a>
              </li>
            )}
            <li>
              <a className={getClassNamesForMenu('products')} href={productsLink}>
                <i className='fa fa-cubes header-context-selector__item-icon' />Products
              </a>
            </li>
            <li>
              <a className={getClassNamesForMenu('backend_api')} href={backendsLink}>
                <i className='fa fa-cube header-context-selector__item-icon' />Backends
              </a>
            </li>
            <li>
              <a className={getClassNamesForMenu('account')} href={settingsLink}>
                <i className='fa fa-cog header-context-selector__item-icon' />Account Settings
              </a>
            </li>
            <li>
              <a className={getClassNamesForMenu('resources')} href={resourcesLink}>
                <i className='fa fa-cog header-context-selector__item-icon' />Resources
              </a>
            </li>
          </ul>
        </div>
      )}
    </div >
  )
}

const ContextSelectorWrapper = (props: Props, containerId: string): void => createReactWrapper(<ContextSelector {...props} />, containerId)

export { ContextSelector, ContextSelectorWrapper }
