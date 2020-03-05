import * as React from 'react'
import {
  SwitchProps,
  Switch,
  Route,
  useRouteMatch
} from 'react-router-dom'
import { NotFound } from 'components/NotFound'

export const SwitchWith404: React.FunctionComponent<SwitchProps> = ({
  children
}) => {
  const match = useRouteMatch()
  const defaultMatch = React.useMemo(
    () => match && <Route path={match.path} exact />,
    [match]
  )
  return (
    <Switch>
      {children}
      {/*
       * Default route that matches the parent route, to avoid showing a 404
       * for "junction" pages . See the "Dashboard" example.
       */}
      {defaultMatch}
      <Route>
        <NotFound />
      </Route>
    </Switch>
  )
}
