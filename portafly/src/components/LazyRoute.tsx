import * as React from 'react'
import { RouteProps, Route } from 'react-router-dom'
import { Loading } from 'components'

export function LazyRoute({ path, exact, render }: RouteProps) {
  return (
    <React.Suspense fallback={<Loading />}>
      <Route path={path} exact={exact} render={render} />
    </React.Suspense>
  )
}
