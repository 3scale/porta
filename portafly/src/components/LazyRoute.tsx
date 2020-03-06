import * as React from 'react'
import {RouteProps, Route} from 'react-router-dom'
import {Loading} from 'components/Loading'

export interface IDynamicImportProps extends RouteProps {
  getComponent: () => Promise<{ default: React.ComponentType }>
}

export function LazyRoute({getComponent, ...props}: IDynamicImportProps) {
  const LazyComponent = React.useMemo(() => React.lazy(getComponent), [
    getComponent,
  ])
  return (
    <Route {...props}>
      <React.Suspense fallback={<Loading/>}>
        <LazyComponent/>
      </React.Suspense>
    </Route>
  )
}
