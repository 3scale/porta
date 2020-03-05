import * as React from 'react'
import { useRouteMatch } from 'react-router-dom'
import { NavExpandable } from '@patternfly/react-core'
import { AppNavItem, IAppNavItemProps } from 'components/AppNavItem'

export interface IAppNavExpandableProps {
  title: string
  to: string
  items: Array<IAppNavItemProps | undefined>
}

export const AppNavExpandable: React.FunctionComponent<IAppNavExpandableProps> = ({
  title,
  to,
  items
}) => {
  const match = useRouteMatch({
    path: to
  })
  const isActive = !!match
  return (
    <NavExpandable title={title} isActive={isActive} isExpanded={isActive}>
      {items.map((item, j) => (
        // FIXME: each app-nav-item should have a fixed ID, using title? or j is just a dirty trick
        <AppNavItem title={item?.title} to={item?.to} key={item?.title || j} />
      ))}
    </NavExpandable>
  )
}
