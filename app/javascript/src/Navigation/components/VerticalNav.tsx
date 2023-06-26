import {
  Nav,
  NavItem,
  NavList
} from '@patternfly/react-core'

import { NavSection } from 'Navigation/components/NavSection'
import { createReactWrapper } from 'utilities/createReactWrapper'

import type { Section } from 'Navigation/types'
import type { Api } from 'Types'

import './VerticalNav.scss'

interface Props {
  sections: Section[];
  activeSection?: string;
  activeItem?: string;
  currentApi?: Api;
}

const VerticalNav: React.FunctionComponent<Props> = ({
  sections,
  activeSection,
  activeItem,
  currentApi
}) => {
  const navSections = sections.map(({ id, title, path, items, outOfDateConfig, target }) => items
    ? (
      <NavSection
        key={title}
        activeItem={activeItem}
        isSectionActive={id === activeSection}
        items={items}
        outOfDateConfig={outOfDateConfig}
        title={title}
      />
    ) : (
      <NavItem
        key={title}
        isActive={activeSection === id}
        target={target}
        to={path}
      >
        {title}
      </NavItem>
    )
  )

  return (
    <div className="pf-c-page__sidebar-body">
      {currentApi && <div className="pf-c-nav__current-api">{currentApi.name}</div>}
      <Nav id="mainmenu">
        <NavList>{navSections}</NavList>
      </Nav>
    </div>
  )
}

// eslint-disable-next-line react/jsx-props-no-spreading
const VerticalNavWrapper = (props: Props, containerId: string): void => { createReactWrapper(<VerticalNav {...props} />, containerId) }

export type { Props }
export { VerticalNav, VerticalNavWrapper }
