import { useState } from 'react'
import {
  Dropdown,
  DropdownItem,
  DropdownToggle,
  Icon
} from '@patternfly/react-core'
import CubeIcon from '@patternfly/react-icons/dist/js/icons/cube-icon'
import CubesIcon from '@patternfly/react-icons/dist/js/icons/cubes-icon'
import BullseyeIcon from '@patternfly/react-icons/dist/js/icons/bullseye-icon'
import HomeIcon from '@patternfly/react-icons/dist/js/icons/home-icon'
import CogIcon from '@patternfly/react-icons/dist/js/icons/cog-icon'

import { ActiveMenuTitle } from 'Navigation/components/ActiveMenuTitle'
import { createReactWrapper } from 'utilities/createReactWrapper'

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

  // TODO: move this to menu_helper.rb
  function isMenuDisabled (menu: string): boolean {
    const isDashboardSelected = menu === 'Dashboard' && activeMenu === 'dashboard'
    const isAudienceSelected = menu === 'Audience' && (['buyers', 'finance', 'cms', 'site'].includes(activeMenu))
    const isProductsSelected = menu === 'Products' && (['serviceadmin', 'monitoring', 'products'].includes(activeMenu))
    const isBackendsSelected = menu === 'Backends' && (['backend_api', 'backend_apis'].includes(activeMenu))
    const isSettingsSelected = menu === 'Account Settings' && (['account', 'personal', 'active_docs'].includes(activeMenu))

    return isDashboardSelected || isAudienceSelected || isProductsSelected || isBackendsSelected || isSettingsSelected
  }

  const dropdownItems = [
    { title: 'Dashboard', href: DASHBOARD_PATH, icon: <HomeIcon /> },
    { title: 'Audience', href: audienceLink, icon: <BullseyeIcon /> },
    { title: 'Products', href: productsLink, icon: <CubesIcon /> },
    { title: 'Backends', href: backendsLink, icon: <CubeIcon /> },
    { title: 'Account Settings', href: settingsLink, icon: <CogIcon /> }
  ].map(({ title, href, icon }) => (
    <DropdownItem key={title} href={href} isDisabled={isMenuDisabled(title)}>
      <Icon isInline className="header-context-selector__item-icon">{icon}</Icon>{title}
    </DropdownItem>
  ))

  return (
    <Dropdown
      isPlain
      data-quickstart-id="context-selector"
      dropdownItems={dropdownItems}
      isOpen={isOpen}
      toggle={(
        <DropdownToggle aria-label="Context selector toggle" onToggle={setIsOpen}>
          <ActiveMenuTitle activeMenu={activeMenu} />
        </DropdownToggle>
      )}
    />
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const ContextSelectorWrapper = (props: Props, containerId: string): void => { createReactWrapper(<ContextSelector {...props} />, containerId) }

export type { Props }
export { ContextSelector, ContextSelectorWrapper }
