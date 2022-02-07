// @flow

/*
Usually we would bring in quick starts components from '@patternfly/quickstarts',
but those depend on the consumer versions of '@patternfly/react-core'.
Since 3scale's version of react-core is older than what we need ('>=4.115.2'),
we can instead use `@patternfly/quickstarts/dist/quickstarts-full.es` which bundles the react-core components
the library depends on.
*/

import * as React from 'react'
import { createReactWrapper } from 'utilities'
import {
  QuickStartContainer,
  useLocalStorage,
  QuickStartCatalogPage
} from '@patternfly/quickstarts/dist/quickstarts-full.es'
import resources from 'quickstarts'

const QuickStartsContext = ({ children, ...props }) => {
  const resourcesContainer = document.getElementById('quick-starts-resources')
  const onResourcesPage = Boolean(resourcesContainer)
  React.useEffect(() => {
    const qsContainer = document.querySelector(
      '.pfext-quick-start-drawer__body'
    )
    const wrapperContainer = document.getElementById('wrapper')
    if (onResourcesPage) {
      // move the #quick-starts-resources-inner element (which contains the resource page elements)
      // into the #quick-starts-resources element which is part of the route layout (app/views/provider/admin/resources/show.html.slim)
      const innerResourcesContainer = document.getElementById(
        'quick-starts-resources-inner'
      )
      resourcesContainer.after(innerResourcesContainer)
      // then move the whole #wrapper into the quick starts container
      qsContainer.after(wrapperContainer)
    } else if (qsContainer) {
      // move the whole #wrapper into the quick starts container
      qsContainer.after(wrapperContainer)
    }
  }, [])

  const [quickStarts] = React.useState(resources)
  const [activeQuickStartID, setActiveQuickStartID] = useLocalStorage(
    'quickstartId',
    ''
  )
  const [allQuickStartStates, setAllQuickStartStates] = useLocalStorage(
    'quickstarts',
    {}
  )

  const drawerProps = {
    quickStarts,
    activeQuickStartID,
    allQuickStartStates,
    setActiveQuickStartID,
    setAllQuickStartStates,
    showCardFooters: false,
    loading: false,
    language: 'en',
    useLegacyHeaderColors: true
  }

  return (
    <QuickStartContainer {...drawerProps}>
      <div style={{ display: 'none' }}>test</div>
      {onResourcesPage && (
        <div id="quick-starts-resources-inner">
          <QuickStartCatalogPage
            showFilter
            title="Quick starts"
            hint="Learn how to create, import, and run applications with step-by-step instructions and tasks."
          />
        </div>
      )}
    </QuickStartContainer>
  )
}

const QuickStartsContextWrapper = (props, containerId) =>
  createReactWrapper(<QuickStartsContext {...props} />, containerId)

export { QuickStartsContext, QuickStartsContextWrapper }
