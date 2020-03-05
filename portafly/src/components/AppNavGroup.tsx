import * as React from 'react'
import { NavGroup } from '@patternfly/react-core'
import { AppNavItem, IAppNavItemProps } from 'components/AppNavItem'

export interface IAppNavGroupProps {
  title: string
  items: Array<IAppNavItemProps | undefined>
}

export const AppNavGroup: React.FunctionComponent<IAppNavGroupProps> = ({
  title,
  items
}) => (
  <NavGroup title={title}>
    {items.map((i) => (
      <AppNavItem title={i?.title} to={i?.to} exact={i?.exact} key={i?.title} />
    ))}
  </NavGroup>
)
