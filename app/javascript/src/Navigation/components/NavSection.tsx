import {
  NavExpandable,
  NavItem,
  NavItemSeparator
} from '@patternfly/react-core'

import type { NavExpandableProps } from '@patternfly/react-core'
import type { Section, Item } from 'Navigation/types'

interface Props {
  title: NavExpandableProps['title'];
  isSectionActive: NavExpandableProps['isActive'];
  activeItem?: string;
  items: Item[];
  outOfDateConfig: Section['outOfDateConfig'];
}

const NavSection: React.FunctionComponent<Props> = ({
  title: navSectionTitle,
  isSectionActive,
  activeItem,
  items,
  outOfDateConfig
}) => (
  <NavExpandable
    className={outOfDateConfig ? 'outdated-config' : ''}
    isActive={isSectionActive}
    isExpanded={isSectionActive}
    title={navSectionTitle}
  >
    {items.map(({ id, title, path, target, itemOutOfDateConfig, subItems }) => (subItems && title)
      ? (
        <NavExpandable
          key={title}
          isActive={isSectionActive && subItems.some(s => s.id === activeItem)}
          isExpanded={isSectionActive && subItems.some(s => s.id === activeItem)}
          title={title}
        >
          {subItems.map(sub => (
            <NavItem
              key={sub.id}
              isActive={isSectionActive && activeItem === sub.id}
              target={sub.target}
              to={sub.path}
            >
              {sub.title}
            </NavItem>
          ))}
        </NavExpandable>
      ) : title ? (
        <NavItem
          key={title}
          className={itemOutOfDateConfig ? 'outdated-config' : ''}
          isActive={isSectionActive && activeItem === id}
          target={target}
          to={path}
        >
          {title}
        </NavItem>
      ) : <NavItemSeparator key={id} />
    )}
  </NavExpandable>
)

export type { Props }
export { NavSection }
