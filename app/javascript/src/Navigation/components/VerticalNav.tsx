import { Nav, NavExpandable, NavItem, NavList, NavGroup, NavExpandableProps } from '@patternfly/react-core'
import { createReactWrapper } from 'utilities'
import 'Navigation/styles/VerticalNav.scss'
import type { Api } from 'Types'

type Item = {
  id: string,
  title: string,
  path?: string,
  target?: string,
  itemOutOfDateConfig?: boolean
};

type Section = Item & {
  items?: Item[],
  outOfDateConfig?: boolean
};

type Props = {
  sections: Section[],
  activeSection?: string,
  activeItem?: string,
  currentApi?: Api
};

const VerticalNav: React.FunctionComponent<Props> = ({
  sections,
  activeSection,
  activeItem,
  currentApi
}) => {
  const navSections = sections.map(({ id, title, path, items, outOfDateConfig }) => {
    return items
      ? <NavSection title={title} isSectionActive={id === activeSection} activeItem={activeItem} items={items} key={title} outOfDateConfig={outOfDateConfig}/>
      : <NavItem to={path} isActive={activeSection === id} key={title}>{title}</NavItem>
  })

  return (
    <div className="pf-c-page__sidebar-body">
      <Nav id="mainmenu" theme="dark">
        { currentApi ? (
          <NavGroup title={currentApi.name}>
            {navSections}
          </NavGroup>
        ) : (
          <NavList>
            {navSections}
          </NavList>
        )}
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

const NavSection: React.FunctionComponent<NavSectionProps> = ({ title, isSectionActive, activeItem, items, outOfDateConfig }) => {
  return (
    <NavExpandable title={title} isActive={isSectionActive} isExpanded={isSectionActive} className={outOfDateConfig ? 'outdated-config' : ''}>
      {items.map(({ id, title, path, target, itemOutOfDateConfig }) => (
        path
          ? <NavItem to={path} isActive={isSectionActive && activeItem === id} target={target} key={title} className={itemOutOfDateConfig ? 'outdated-config' : ''}>{title}</NavItem>
          : <NavGroup title={title} className='vertical-nav-label' key={title}></NavGroup>
      ))}
    </NavExpandable>
  )
}

const VerticalNavWrapper = (props: Props, containerId: string): void => createReactWrapper(<VerticalNav {...props} />, containerId)

export { VerticalNav, VerticalNavWrapper, Props }
