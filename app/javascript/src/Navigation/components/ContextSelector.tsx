import { useRef, useState } from 'react'

import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'
import { createReactWrapper } from 'utilities/createReactWrapper'
import { useClickOutside } from 'utilities/useClickOutside'

import type { FunctionComponent } from 'react'
import type { Menu } from 'Types'

import './ContextSelector.scss'

interface Props {
  activeMenu: Menu;
  audienceLink?: string;
  settingsLink: string;
  productsLink: string;
  backendsLink: string;
}

const DASHBOARD_PATH = '/p/admin/dashboard'

const ContextSelector: FunctionComponent<Props> = ({
  activeMenu,
  audienceLink,
  settingsLink,
  productsLink,
  backendsLink
}) => {
  const [isOpen, setIsOpen] = useState(false)
  const ref = useRef(null)
  useClickOutside(ref, () => { setIsOpen(false) })

  function getClassNamesForMenu (menu: Menu): string {
    const isDashboardSelected = menu === 'dashboard' && activeMenu === 'dashboard'
    const isAudienceSelected = menu === 'audience' && (['buyers', 'finance', 'cms', 'site'].includes(activeMenu))
    const isProductsSelected = menu === 'products' && (['serviceadmin', 'monitoring', 'products'].includes(activeMenu))
    const isBackendsSelected = menu === 'backend_api' && (['backend_api', 'backend_apis'].includes(activeMenu))
    const isSettingsSelected = menu === 'account' && (['account', 'personal', 'active_docs'].includes(activeMenu))

    if (isDashboardSelected || isAudienceSelected || isProductsSelected || isBackendsSelected || isSettingsSelected) {
      return 'pf-c-context-selector__menu-list-item current-context'
    }

    return 'pf-c-context-selector__menu-list-item'
  }

  return (
    <div className={`pf-c-context-selector header-context-selector ${isOpen ? ' pf-m-expanded' : ''}`} data-quickstart-id="context-selector" ref={ref}>
      <a className="pf-c-context-selector__toggle pf-m-plain pf-m-text" title="Context Selector" onClick={() => { setIsOpen(!isOpen) }}>
        <ActiveMenuTitle activeMenu={activeMenu} />
      </a>
      {isOpen && (
        <div className="pf-c-context-selector__menu">
          <ul className="pf-c-context-selector__menu-list" id="context-menu">
            <li>
              <a className={getClassNamesForMenu('dashboard')} href={DASHBOARD_PATH}>
                <i className="fa fa-home header-context-selector__item-icon" />Dashboard
              </a>
            </li>
            {!!audienceLink && (
              <li>
                <a className={getClassNamesForMenu('audience')} href={audienceLink}>
                  <i className="fa fa-bullseye header-context-selector__item-icon" />Audience
                </a>
              </li>
            )}
            <li>
              <a className={getClassNamesForMenu('products')} href={productsLink}>
                <i className="fa fa-cubes header-context-selector__item-icon" />Products
              </a>
            </li>
            <li>
              <a className={getClassNamesForMenu('backend_api')} href={backendsLink}>
                <i className="fa fa-cube header-context-selector__item-icon" />Backends
              </a>
            </li>
            <li>
              <a className={getClassNamesForMenu('account')} href={settingsLink}>
                <i className="fa fa-cog header-context-selector__item-icon" />Account Settings
              </a>
            </li>
          </ul>
        </div>
      )}
    </div >
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ContextSelectorWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ContextSelector {...props} />, containerId) }

export type { Props }
export { ContextSelector, ContextSelectorWrapper }
