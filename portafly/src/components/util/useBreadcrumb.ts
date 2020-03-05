import * as React from 'react'
import { AppLayoutContext } from 'components/AppLayout'

export function useBreadcrumb(breadcrumb: React.ReactElement) {
  const context = React.useContext(AppLayoutContext)

  React.useEffect(() => {
    context.setBreadcrumb(breadcrumb)
    return () => {
      context.setBreadcrumb(null)
    }
  }, [context, breadcrumb])
}
