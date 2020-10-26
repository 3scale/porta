// @flow

import React, { useState, useRef } from 'react'

import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { useClickOutside } from 'utilities/useClickOutside'

import 'Navigation/styles/ContextSelector.scss'

import type { Menu } from 'Types'

type Props = {
  activeMenu: Menu,
  audienceLink: string,
  settingsLink: string,
  productsLink: string,
  backendsLink: string
}

const DASHBOARD_PATH = '/p/admin/dashboard'

const ContextSelector = ({ activeMenu, audienceLink, settingsLink, productsLink, backendsLink }: Props) => {
  const [isOpen, setIsOpen] = useState(false)
  const ref = useRef(null)
  useClickOutside(ref, () => setIsOpen(false))

  function getClassNamesForMenu (menu: Menu): string {
    const isDashboardSelected = menu === 'dashboard' && activeMenu === 'dashboard'
    const isAudienceSelected = menu === 'audience' && (['buyers', 'finance', 'cms', 'site'].indexOf(activeMenu) !== -1)
    const isProductsSelected = menu === 'products' && (['serviceadmin', 'monitoring', 'products'].indexOf(activeMenu) !== -1)
    const isBackendsSelected = menu === 'backend_api' && (['backend_api', 'backend_apis'].indexOf(activeMenu) !== -1)
    const isSettingsSelected = menu === 'account' && (['account', 'personal', 'active_docs'].indexOf(activeMenu) !== -1)

    if (isDashboardSelected || isAudienceSelected || isProductsSelected || isBackendsSelected || isSettingsSelected) {
      return 'PopNavigation-link current-context'
    }

    return 'PopNavigation-link'
  }

  return (
    <div className="PopNavigation PopNavigation--context" ref={ref}>
      <a className="PopNavigation-trigger" href="#context-menu" title="Context Selector" onClick={() => setIsOpen(!isOpen)}>
        <ActiveMenuTitle activeMenu={activeMenu} />
      </a>
      {isOpen && (
        <ul id="context-menu" className="PopNavigation-list">
          <li className="PopNavigation-listItem">
            <a className={getClassNamesForMenu('dashboard')} href={DASHBOARD_PATH}>
              <i className='fa fa-home' />Dashboard
            </a>
          </li>
          {audienceLink && (
            <li className="PopNavigation-listItem">
              <a className={getClassNamesForMenu('audience')} href={audienceLink}>
                <i className='fa fa-bullseye' />Audience
              </a>
            </li>
          )}
          <li className="PopNavigation-listItem">
            <a className={getClassNamesForMenu('products')} href={productsLink}>
              <i className='fa fa-cubes' />Products
            </a>
          </li>
          <li className="PopNavigation-listItem">
            <a className={getClassNamesForMenu('backend_api')} href={backendsLink}>
              <i className='fa fa-cube' />Backends
            </a>
          </li>
          <li className="PopNavigation-listItem">
            <a className={getClassNamesForMenu('account')} href={settingsLink}>
              <i className='fa fa-cog' />Account Settings
            </a>
          </li>
        </ul>
      )}
    </div >
  )
}

const ContextSelectorWrapper = (props: Props, containerId: string) => createReactWrapper(<ContextSelector {...props} />, containerId)

export { ContextSelector, ContextSelectorWrapper }
