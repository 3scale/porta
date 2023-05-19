import {
  NavExpandable,
  NavItem,
  NavGroup,
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
    {items.map(({ id, title, path, target, itemOutOfDateConfig }) => path
      ? (
        <NavItem
          key={title}
          className={itemOutOfDateConfig ? 'outdated-config' : ''}
          isActive={isSectionActive && activeItem === id}
          target={target}
          to={path}
        >
          {title}
        </NavItem>
      )
      : title ? <NavGroup key={title} title={title} /> : <NavItemSeparator key="separator" />
    )}
  </NavExpandable>
)

export type { Props }
export { NavSection }
