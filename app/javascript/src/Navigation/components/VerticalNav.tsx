import { Nav, NavExpandable, NavGroup, NavItem, NavList } from '@patternfly/react-core'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { NavExpandableProps } from '@patternfly/react-core'
import type { Api } from 'Types'

import './VerticalNav.scss'

type Item = {
  id: string,
  title: string,
  path?: string,
  target?: string,
  itemOutOfDateConfig?: boolean
}

type Section = Item & {
  items?: Item[],
  outOfDateConfig?: boolean
}

type Props = {
  sections: Section[],
  activeSection?: string,
  activeItem?: string,
  currentApi?: Api
}

const VerticalNav: React.FunctionComponent<Props> = ({
  sections,
  activeSection,
  activeItem,
  currentApi
}) => {
  const navSections = sections.map(({ id, title, path, items, outOfDateConfig }) => items
    ? <NavSection key={title} activeItem={activeItem} isSectionActive={id === activeSection} items={items} outOfDateConfig={outOfDateConfig} title={title} />
    : <NavItem key={title} isActive={activeSection === id} to={path}>{title}</NavItem>
  )

  return (
    <div className="pf-c-page__sidebar-body">
      <Nav id="mainmenu" theme="dark">
        {currentApi
          ? <NavGroup title={currentApi.name}>{navSections}</NavGroup>
          : <NavList>{navSections}</NavList>}
      </Nav>
    </div>
  )
}

type NavSectionProps = {
  title: NavExpandableProps['title'],
  isSectionActive: NavExpandableProps['isActive'],
  activeItem: Props['activeItem'],
  items: Item[],
  outOfDateConfig: Section['outOfDateConfig']
}

// eslint-disable-next-line react/no-multi-comp
const NavSection: React.FunctionComponent<NavSectionProps> = ({ title, isSectionActive, activeItem, items, outOfDateConfig }) => (
  <NavExpandable className={outOfDateConfig ? 'outdated-config' : ''} isActive={isSectionActive} isExpanded={isSectionActive} title={title}>
    {items.map(({ id, title, path, target, itemOutOfDateConfig }) => path
      ? <NavItem key={title} className={itemOutOfDateConfig ? 'outdated-config' : ''} isActive={isSectionActive && activeItem === id} target={target} to={path}>{title}</NavItem>
      : <NavGroup key={title} className="vertical-nav-label" title={title} />
    )}
  </NavExpandable>
)

// eslint-disable-next-line react/jsx-props-no-spreading
const VerticalNavWrapper = (props: Props, containerId: string): void => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper, Props }
